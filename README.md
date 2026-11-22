# 🤖 SmartBot — Sistema de Control de Hosting para iOS

Aplicación nativa para **iOS (iPhone)** desarrollada en **Swift + SwiftUI** (iOS 17+ / Apple iOS 26 Liquid Glass) bajo arquitectura modular **MVVM**.

Diseñada para gestionar servidores de hosting con una identidad visual sobria y profesional: **Negro Puro, Azul Apple y Blanco (#000000 / #0A84FF / #FFFFFF)**, materiales translúcidos de refracción, menú inferior focal con deslizamiento líquido e indicador fluido, y **100% datos reales de la API (cero mocks o datos simulados)**.

---

## 🔒 1. Seguridad y Client API Key (Keychain de iOS)

> [!IMPORTANT]
> **Cero claves pregrabadas (Zero Hardcode).**

- **Entrada limpia:** Al abrir la aplicación por primera vez se te solicita tu **Client API Key** (`ptlc_...`), la cual se almacena exclusivamente en el **Keychain nativo de iOS** con aislamiento de hardware del Secure Enclave.
- **URL interna y protegida:** La URL del panel se gestiona de forma transparente y segura en segundo plano sin exponerla en la interfaz.
- **Protección Biométrica:** Soporte nativo para bloqueo con **Face ID / Touch ID**.

---

## 🎨 2. Identidad Visual: SmartBot (Negro, Azul y Blanco)

- **Fondos:** Negro absoluto y grafito profundo (`#000000` / `#0A0B0F`) con tarjetas en cristal oscuro translúcido (`#12141C`).
- **Acento Principal:** Azul Apple / SmartBot (`#0A84FF` / `#2563EB`) para botones principales, indicadores activos y selecciones.
- **Estados de Servidor:** Solo verde (`#30D158`) para *En línea*, ámbar (`#FFD60A`) para *Iniciando* y rojo (`#FF453A`) para *Apagado*.
- **Icono Oficial:** Integración completa de **`LogoSmart.png`** en todas las resoluciones oficiales de iOS en `AppIcon.appiconset` y en cabeceras de la aplicación.
- **Tab Bar Focal Liquid Glass:** Cápsula flotante con efecto `.ultraThinMaterial`, brillo especular e indicador líquido deslizable con `matchedGeometryEffect` y respuesta háptica. Se oculta automáticamente al entrar a la consola o editor.

---

## ⚡ 3. Funciones Principales (100% Datos Reales)

1. **Dashboard & Recursos en Vivo:**
   - Contadores reales calculados consultando `GET /api/client/servers/{id}/resources` en paralelo con `withTaskGroup`.
   - Uso real de CPU %, RAM consumida vs asignada y Disco consumido vs asignado.
2. **Consola en Tiempo Real (WebSocket Wings):**
   - Logs en vivo con parseo ANSI de colores.
   - Barra de escritura de comandos fija en `safeAreaInset` que sube con el teclado sin obstrucciones.
   - Controles de energía (Iniciar, Reiniciar, Apagar, Forzar) con confirmación segura.
3. **Explorador y Editor de Archivos:**
   - Navegación por carpetas, creación de directorios, renombrado y borrado.
   - Editor integrado de texto y código para `.env`, `.json`, `.yml`, etc.
4. **Historial de Actividad (`GET /activity`):**
   - Lista detallada de eventos reales (encendidos, reinicios, comandos, cambios en archivos) traducidos al español, usuario responsable y marca temporal.
5. **Usuarios con Acceso (`GET /users`):**
   - Subusuarios con acceso al servidor, estado de 2FA y lista desplegable de permisos otorgados.

---

## 📦 4. Compilación

Configurado con `xcodegen generate` y listo para compilar con **Codemagic** y **GitHub Actions** generando automáticamente el archivo `.ipa` sin firma para instalación directa mediante **Sideloadly**, TrollStore o AltStore.
