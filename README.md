# ⚡ LynxNodes para iOS — App Nativa para Pterodactyl

Aplicación nativa para **iOS (iPhone)** desarrollada en **Swift + SwiftUI** (iOS 17+ / iOS 26 Liquid Glass Ready) bajo arquitectura modular **MVVM**.

Diseñada especialmente para gestionar servidores de Pterodactyl alojados en **[https://panel.lynxnodes.es/](https://panel.lynxnodes.es/)** con una identidad visual **Negro Obsidiana y Amarillo Oro (Lynx Amber & OLED Black)**, materiales translúcidos de refracción, barra de navegación flotante estilo cápsula y **cero estética genérica de IA**.

---

## 🔒 1. Política de Seguridad y API Key (Zero Hardcode)

> [!IMPORTANT]
> **Ninguna clave de API está pregrabada ni expuesta en el código fuente.**

- **Entrada manual por el usuario:** Al abrir la aplicación por primera vez se te solicitará tu **Client API Key** (`ptlc_...`), la cual generas desde tu cuenta del panel:
  - Ruta en el panel: `Account` > `API Credentials` > `Create API Key`.
- **Almacenamiento local en Keychain:** Tu clave se guarda de manera cifrada exclusivamente en el **Keychain nativo del iPhone** (`kSecClassGenericPassword`), fuera de `UserDefaults` y nunca en texto plano.
- **Acceso Directo y Privado:** Las peticiones viajan directamente desde tu iPhone a `https://panel.lynxnodes.es/` con los headers oficiales:
  ```http
  Authorization: Bearer <TU_API_KEY_EN_KEYCHAIN>
  Accept: Application/vnd.pterodactyl.v1+json
  ```
- **Gestión desde Ajustes:** En la pestaña **Ajustes** puedes ver tu clave enmascarada (`ptlc_••••••••abcd`), actualizarla cuando quieras o pulsar **Desconectar Cuenta** para purgarla completamente del Keychain.
- **Protección Biométrica:** Opción integrada para exigir **Face ID / Touch ID** cada vez que abras la aplicación.

---

## 🎨 2. Diseño Visual: Negro y Amarillo Lynx (Liquid Glass)

- **Fondo Negro OLED:** Contraste absoluto en `#08080A` que ahorra batería en pantallas Super Retina XDR y ofrece una apariencia oscura impecable.
- **Acentos Amarillo Lynx:** Detalles en oro y ámbar luminoso (`#F5B700`, `#FFD133`) en botones de acción, métricas destacadas e indicadores de estado.
- **Efecto Liquid Glass (iOS 26 Style):** Tarjetas con materiales `.ultraThinMaterial`, brillo especular superior en degradado de agua/cristal y bordes de refracción de `0.8pt`.
- **Menú Flotante (Floating Tab Bar):** Cápsula flotante translúcida inferior con selección animada por resorte (`spring`) y respuesta táctil háptica suave (`UIImpactFeedbackGenerator`).
- **Iconografía Vectorial Propia:** Set de iconos vectoriales limpios (SVG) en `Assets.xcassets/Icons` con trazo uniforme de estilo Apple nativo (cero emojis de texto y cero estridencias).

---

## 📱 3. Icono Oficial de la Aplicación (`Icono.jpg`)

La app ya tiene configurado el archivo **`Icono.jpg`** de alta resolución de la raíz del proyecto dentro de:

```
LynxNodes/Resources/Assets.xcassets/AppIcon.appiconset/
```

Se han generado automáticamente todas las densidades de píxeles oficiales de iOS (desde `20x20` hasta `1024x1024` para App Store y Marketing) con interpolación Lanczos para que el icono se vea nítido y sin deformaciones en la pantalla de inicio de tu iPhone.

---

## 🚀 4. Cómo Compilar y Descargar el `.ipa` en GitHub Actions

El proyecto incluye el workflow automatizado en [`.github/workflows/build-ipa.yml`](file:///.github/workflows/build-ipa.yml).

### Pasos para obtener tu archivo `.ipa`:

1. **Sube este repositorio a tu GitHub:**
   ```bash
   git init
   git add .
   git commit -m "feat: LynxNodes native iOS app"
   git remote add origin https://github.com/TU_USUARIO/LynxNodes-iOS.git
   git push -u origin main
   ```

2. **Ejecución automática:**
   - Ve a la pestaña **Actions** en tu repositorio de GitHub.
   - El workflow `Compilar IPA LynxNodes` se ejecutará automáticamente en un entorno `macos-14` con `xcodebuild`.
   - También puedes lanzarlo manualmente pulsando **Run workflow**.

3. **Descargar el archivo `.ipa`:**
   - Una vez finalizado (tarda ~2-3 minutos), entra en la ejecución del workflow.
   - En la sección **Artifacts** inferior, haz clic en **`LynxNodes-iOS-IPA`**.
   - Se descargará un archivo ZIP que contiene directamente **`LynxNodes.ipa`**.

---

## 📲 5. Instalación del `.ipa` en tu iPhone

Puedes instalar el archivo `.ipa` generado mediante cualquiera de estos métodos habituales:

- **TrollStore (Recomendado si tu versión de iOS es compatible):** Instala directamente el `.ipa` de forma permanente sin límite de 7 días.
- **AltStore / SideStore:** Instala el `.ipa` desde tu ordenador o vía WiFi usando tu Apple ID gratuito.
- **Sideloadly (Windows / Mac):** Conecta el iPhone por USB, arrastra el archivo `LynxNodes.ipa`, introduce tu Apple ID y pulsa *Start*.
- **Scarlet / Esign:** Para instalación directa desde el propio dispositivo.

---

## 🧩 6. Estructura y Arquitectura del Código

El proyecto está organizado siguiendo el patrón **MVVM** limpio:

```
LynxNodes/
├── App/
│   ├── LynxNodesApp.swift             # Entrypoint @main y ciclo de vida de la app
│   └── AppEnvironment.swift           # Estado global observable (sesión, favoritos)
│
├── Core/
│   ├── Network/
│   │   ├── PterodactylAPI.swift       # Cliente REST async/await (https://panel.lynxnodes.es)
│   │   ├── PterodactylWebSocket.swift # Conexión en tiempo real con Wings (Consola/Métricas)
│   │   ├── NetworkError.swift         # Gestión de errores HTTP (401, 403, 404, 429, 500)
│   │   └── ANSIParser.swift           # Parser nativo de colores ANSI para la consola
│   ├── Security/
│   │   ├── KeychainManager.swift      # Almacenamiento seguro de la API Key en Keychain
│   │   └── BiometricAuthManager.swift # Autenticación biométrica con Face ID / Touch ID
│   └── Haptics/
│       └── HapticFeedback.swift       # Motor de respuesta háptica suave
│
├── Models/
│   ├── Server.swift                   # Modelo de servidor y límites de recursos
│   ├── ServerStats.swift              # Métricas en vivo (CPU %, RAM, Disco, Red, Uptime)
│   ├── FileItem.swift                 # Archivos y carpetas con detección de tipo
│   └── WebSocketEvent.swift           # Protocolo de eventos de Wings
│
├── ViewModels/
│   ├── AuthViewModel.swift            # Verificación inicial de API Key y conexión
│   ├── DashboardViewModel.swift       # Resumen de estado (online/offline) y recursos
│   ├── ServerListViewModel.swift      # Buscador en tiempo real y filtrado
│   ├── ServerConsoleViewModel.swift   # Buffer de logs, auto-scroll y órdenes de energía
│   ├── ServerFilesViewModel.swift     # Navegación por carpetas, editor, renombrar, borrar
│   └── SettingsViewModel.swift        # Ajustes de URL, Keychain y Face ID
│
├── Views/
│   ├── Onboarding/
│   │   └── LoginView.swift            # Pantalla de bienvenida y test de conexión
│   ├── MainTabView.swift              # Coordinador de pestañas y Tab Bar flotante
│   ├── Dashboard/
│   │   └── DashboardView.swift        # Pestaña "Inicio" con tarjetas de resumen
│   ├── Servers/
│   │   ├── ServerListView.swift       # Pestaña "Servidores" con buscador
│   │   ├── ServerCardView.swift       # Tarjeta individual Liquid Glass
│   │   ├── ServerDetailView.swift     # Panel de control (Consola + Archivos)
│   │   └── Subviews/
│   │       ├── ConsoleView.swift      # Consola interactiva con envío de comandos
│   │       └── PowerControlsView.swift# Botones Start, Restart, Stop, Kill con confirmación
│   ├── Files/
│   │   ├── DirectFilesTabView.swift   # Pestaña "Archivos" con selector rápido
│   │   ├── FilesBrowserView.swift     # Explorador de archivos con breadcrumbs
│   │   ├── FileEditorView.swift       # Editor de texto/código integrado
│   │   └── FileRowView.swift          # Fila de archivo con menú contextual
│   └── Settings/
│       ├── SettingsView.swift         # Pestaña "Ajustes"
│       └── BiometricLockView.swift    # Capa de bloqueo con Face ID
│
├── Components/
│   ├── Theme.swift                    # Paleta oficial Negro & Amarillo Oro
│   ├── LiquidGlassModifier.swift      # Efecto cristal translúcido con refracción
│   ├── GlassCard.swift                # Tarjeta Liquid Glass reutilizable
│   ├── FloatingTabBar.swift           # Menú inferior flotante con animación spring
│   ├── StatusBadge.swift              # Indicador LED de estado
│   ├── MetricBar.swift                # Barra de métricas minimalista
│   ├── CustomIcons.swift              # Renderizador de iconos vectoriales Apple
│   ├── SkeletonLoader.swift           # Animaciones de carga shimmer
│   └── BreadcrumbsView.swift          # Barra de navegación por directorios
│
└── Resources/
    ├── Info.plist                     # Configuración de permisos Face ID y bundles
    └── Assets.xcassets/
        ├── AppIcon.appiconset/        # Iconos generados a partir de Icono.jpg
        ├── AccentColor.colorset/      # Color de acento Amarillo Oro (#F5B700)
        └── Icons/                     # Set de iconos vectoriales SVG limpios
```

---

## 🌟 7. Resumen de Funcionalidades

| Sección | Características |
|---|---|
| **Inicio (Casita)** | Resumen en tiempo real (En línea, Iniciando, Apagados), servidores favoritos con acceso rápido, y total de RAM / Almacenamiento asignado. |
| **Servidores** | Lista reactiva con buscador instantáneo, filtrado por estado, nodo del servidor y panel de control por pestañas. |
| **Consola Wings** | WebSocket con auto-reconexión, visualizador de logs con colores ANSI, auto-scroll inteligente con pausa, botón de copiar y campo para enviar comandos. |
| **Control de Energía** | Botones de Encender, Reiniciar, Apagar y Forzar Apagado con diálogos de confirmación de seguridad. |
| **Gestor de Archivos** | Navegación por rutas (breadcrumbs), explorador completo, visor y editor integrado de texto/código (`.json`, `.yml`, `.env`, `.txt`, etc.), creación de carpetas, renombrado y borrado. |
| **Ajustes** | Edición de la URL del panel, visualización enmascarada y cambio de API Key, bloqueo biométrico por Face ID, tamaño de fuente de la consola y cierre seguro de sesión. |

---

*Desarrollado para la infraestructura de servidores de [panel.lynxnodes.es](https://panel.lynxnodes.es/).*
