import Foundation

/// Cliente de red principal para interactuar con la API Client de Pterodactyl.
final class PterodactylAPI {
    static let shared = PterodactylAPI()
    
    static let defaultBaseUrl = "https://panel.lynxnodes.es"
    private let baseUrlKey = "lynxnodes_panel_base_url"
    
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20.0
        configuration.timeoutIntervalForResource = 60.0
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Configuración de URL Base
    
    var baseUrl: String {
        get {
            let saved = UserDefaults.standard.string(forKey: baseUrlKey)
            if let saved = saved, !saved.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return cleanUrl(saved)
            }
            return Self.defaultBaseUrl
        }
        set {
            UserDefaults.standard.set(cleanUrl(newValue), forKey: baseUrlKey)
        }
    }
    
    private func cleanUrl(_ url: String) -> String {
        var clean = url.trimmingCharacters(in: .whitespacesAndNewlines)
        if clean.hasSuffix("/") {
            clean.removeLast()
        }
        if !clean.hasPrefix("http://") && !clean.hasPrefix("https://") {
            clean = "https://" + clean
        }
        return clean
    }
    
    // MARK: - Generador de Peticiones con Headers Pterodactyl
    
    private func makeRequest(
        path: String,
        method: String = "GET",
        queryItems: [URLQueryItem]? = nil,
        body: Data? = nil,
        contentType: String = "application/json",
        customApiKey: String? = nil,
        customBaseUrl: String? = nil
    ) throws -> URLRequest {
        let hostUrl = customBaseUrl ?? self.baseUrl
        guard var components = URLComponents(string: hostUrl + path) else {
            throw NetworkError.invalidURL
        }
        
        if let queryItems = queryItems, !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Application/vnd.pterodactyl.v1+json", forHTTPHeaderField: "Accept")
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        let apiKey = customApiKey ?? KeychainManager.shared.getApiKey()
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            throw NetworkError.missingApiKey
        }
        
        request.setValue("Bearer \(apiKey.trimmingCharacters(in: .whitespacesAndNewlines))", forHTTPHeaderField: "Authorization")
        
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
    
    private func executeRequest(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.connectionFailed
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                return (data, httpResponse)
            case 401:
                throw NetworkError.unauthorized
            case 403:
                throw NetworkError.forbidden
            case 404:
                throw NetworkError.notFound
            case 429:
                throw NetworkError.rateLimited
            case 500...599:
                let errorMsg = extractErrorMessage(from: data)
                throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: errorMsg)
            default:
                let errorMsg = extractErrorMessage(from: data)
                throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: errorMsg)
            }
        } catch let err as NetworkError {
            throw err
        } catch {
            throw NetworkError.connectionFailed
        }
    }
    
    private func extractErrorMessage(from data: Data) -> String? {
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let errors = json["errors"] as? [[String: Any]],
           let firstError = errors.first,
           let detail = firstError["detail"] as? String {
            return detail
        }
        return String(data: data, encoding: .utf8)
    }
    
    // MARK: - Métodos de la API
    
    /// Valida la conexión inicial con el servidor y la clave proporcionada
    func validateConnection(baseUrl: String, apiKey: String) async throws -> [Server] {
        let request = try makeRequest(
            path: "/api/client",
            method: "GET",
            customApiKey: apiKey,
            customBaseUrl: cleanUrl(baseUrl)
        )
        
        let (data, _) = try await executeRequest(request)
        
        do {
            let decoded = try JSONDecoder().decode(PterodactylServerListResponse.self, from: data)
            let rawServers = decoded.data.map { $0.attributes }
            return rawServers
        } catch {
            throw NetworkError.decodingError("El formato de respuesta no coincide con Pterodactyl.")
        }
    }
    
    /// Obtiene la lista de servidores del cliente
    func getServers() async throws -> [Server] {
        let request = try makeRequest(path: "/api/client")
        let (data, _) = try await executeRequest(request)
        let decoded = try JSONDecoder().decode(PterodactylServerListResponse.self, from: data)
        return decoded.data.map { $0.attributes }
    }
    
    /// Obtiene el estado y recursos en tiempo real de un servidor (GET /api/client/servers/{id}/resources)
    func getServerResources(id: String) async throws -> ServerResourceAttributes {
        let request = try makeRequest(path: "/api/client/servers/\(id)/resources")
        let (data, _) = try await executeRequest(request)
        let decoded = try JSONDecoder().decode(PterodactylResourcesResponse.self, from: data)
        return decoded.attributes
    }
    
    /// Obtiene la lista completa de servidores y concurrentemente consulta el estado real (/resources) de cada uno
    func getServersWithResources() async throws -> [Server] {
        let servers = try await getServers()
        guard !servers.isEmpty else { return [] }
        
        return await withTaskGroup(of: (String, ServerState, ResourceUsage?).self, returning: [Server].self) { group in
            for server in servers {
                group.addTask {
                    do {
                        let res = try await self.getServerResources(id: server.id)
                        let state = ServerState(rawValue: res.currentState.lowercased()) ?? .unknown
                        return (server.id, state, res.resources)
                    } catch {
                        return (server.id, .offline, nil)
                    }
                }
            }
            
            var resourceMap: [String: (ServerState, ResourceUsage?)] = [:]
            for await (id, state, resources) in group {
                resourceMap[id] = (state, resources)
            }
            
            return servers.map { server in
                var updated = server
                if let (state, resources) = resourceMap[server.id] {
                    updated.currentState = state
                    updated.currentResources = resources
                }
                return updated
            }
        }
    }
    
    /// Obtiene información detallada de un servidor específico
    func getServerDetails(id: String) async throws -> Server {
        let request = try makeRequest(path: "/api/client/servers/\(id)")
        let (data, _) = try await executeRequest(request)
        let decoded = try JSONDecoder().decode(PterodactylServerDetailResponse.self, from: data)
        return decoded.attributes
    }
    
    /// Obtiene las credenciales para la conexión WebSocket (Wings)
    func getWebSocketToken(id: String) async throws -> WebSocketTokenData {
        let request = try makeRequest(path: "/api/client/servers/\(id)/websocket")
        let (data, _) = try await executeRequest(request)
        let decoded = try JSONDecoder().decode(WebSocketTokenResponse.self, from: data)
        return decoded.data
    }
    
    /// Envía una señal de energía al servidor
    func sendPowerAction(id: String, signal: PowerSignal) async throws {
        let payload = ["signal": signal.rawValue]
        let body = try JSONSerialization.data(withJSONObject: payload)
        let request = try makeRequest(
            path: "/api/client/servers/\(id)/power",
            method: "POST",
            body: body
        )
        _ = try await executeRequest(request)
    }
    
    // MARK: - Explorador y Editor de Archivos
    
    /// Lista los archivos en un directorio
    func listFiles(id: String, directory: String = "/") async throws -> [FileItem] {
        let queryItems = [URLQueryItem(name: "directory", value: directory)]
        let request = try makeRequest(
            path: "/api/client/servers/\(id)/files/list",
            queryItems: queryItems
        )
        let (data, _) = try await executeRequest(request)
        let decoded = try JSONDecoder().decode(PterodactylFileListResponse.self, from: data)
        
        // Ordenar: directorios primero por orden alfabético, luego archivos
        return decoded.data.map { $0.attributes }.sorted { a, b in
            if a.isDirectory != b.isDirectory {
                return a.isDirectory && !b.isDirectory
            }
            return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
        }
    }
    
    /// Descarga el contenido en texto plano de un archivo
    func getFileContents(id: String, filePath: String) async throws -> String {
        let queryItems = [URLQueryItem(name: "file", value: filePath)]
        let request = try makeRequest(
            path: "/api/client/servers/\(id)/files/contents",
            queryItems: queryItems,
            contentType: "text/plain"
        )
        let (data, _) = try await executeRequest(request)
        guard let content = String(data: data, encoding: .utf8) else {
            throw NetworkError.decodingError("No se pudo decodificar el archivo como texto UTF-8.")
        }
        return content
    }
    
    /// Escribe/Guarda el contenido de un archivo
    func writeFileContents(id: String, filePath: String, content: String) async throws {
        let queryItems = [URLQueryItem(name: "file", value: filePath)]
        guard let body = content.data(using: .utf8) else {
            throw NetworkError.custom("Error de codificación al guardar archivo.")
        }
        let request = try makeRequest(
            path: "/api/client/servers/\(id)/files/write",
            method: "POST",
            queryItems: queryItems,
            body: body,
            contentType: "text/plain"
        )
        _ = try await executeRequest(request)
    }
    
    /// Crea una nueva carpeta
    func createFolder(id: String, root: String, folderName: String) async throws {
        let payload: [String: Any] = [
            "root": root,
            "name": folderName
        ]
        let body = try JSONSerialization.data(withJSONObject: payload)
        let request = try makeRequest(
            path: "/api/client/servers/\(id)/files/create-folder",
            method: "POST",
            body: body
        )
        _ = try await executeRequest(request)
    }
    
    /// Renombra un archivo o carpeta
    func renameFile(id: String, root: String, from: String, to: String) async throws {
        let payload: [String: Any] = [
            "root": root,
            "files": [
                ["from": from, "to": to]
            ]
        ]
        let body = try JSONSerialization.data(withJSONObject: payload)
        let request = try makeRequest(
            path: "/api/client/servers/\(id)/files/rename",
            method: "PUT",
            body: body
        )
        _ = try await executeRequest(request)
    }
    
    /// Elimina uno o más archivos / carpetas
    func deleteFiles(id: String, root: String, fileNames: [String]) async throws {
        let payload: [String: Any] = [
            "root": root,
            "files": fileNames
        ]
        let body = try JSONSerialization.data(withJSONObject: payload)
        let request = try makeRequest(
            path: "/api/client/servers/\(id)/files/delete",
            method: "POST",
            body: body
        )
        _ = try await executeRequest(request)
    }
    
    /// Obtiene el historial real de actividad del servidor
    func getServerActivity(id: String) async throws -> [ActivityLogData] {
        let request = try makeRequest(path: "/api/client/servers/\(id)/activity")
        let (data, _) = try await executeRequest(request)
        let response = try JSONDecoder().decode(ActivityLogResponse.self, from: data)
        return response.data
    }
    
    /// Obtiene la lista real de subusuarios con acceso al servidor
    func getServerSubusers(id: String) async throws -> [SubuserData] {
        let request = try makeRequest(path: "/api/client/servers/\(id)/users")
        let (data, _) = try await executeRequest(request)
        let response = try JSONDecoder().decode(SubusersResponse.self, from: data)
        return response.data
    }
}
