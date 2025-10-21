[English](./FAQ.md) | Español

# 💬 Preguntas Frecuentes de ddubsOS para v2.5.8

- **Fecha:** 17 de septiembre de 2025

## Relacionado con ddubsOS

### ¿Cómo compilo por host vs por perfil?

- Por host (nuevo, preferido):
  - sudo nixos-rebuild switch --flake .#<host>
- Por perfil (legado, aún disponible):
  - sudo nixos-rebuild switch --flake .#<profile> # amd | intel | nvidia |
    nvidia-laptop | vm

Consulta también: docs/upgrade-from-2.4.md

### ¿Qué indicadores tiene ahora el instalador?

- ./install-ddubsos.sh --host <nombre> --profile
  <amd|intel|nvidia|nvidia-laptop|vm> --build-host --non-interactive
- --host/--profile preseleccionan valores; --build-host compila el destino
  .#<host>; --non-interactive acepta valores por defecto sin preguntas.

### ¿Cómo agrego/elimino/renombro hosts con zcli?

- Agregar: zcli add-host <nombre> [perfil]
- Eliminar: zcli del-host <nombre>
- Renombrar: zcli rename-host <antiguo> <nuevo>
- Establecer solo el host en flake: zcli hostname set <nombre>
- Actualizar host y perfil en flake: zcli update-host [nombre] [perfil]

### Paso a paso: migrar una VM a objetivos por host (ejemplo: ddubsos-vm)

Este ejemplo asume que tienes una VM que actualmente compila con objetivos de
perfil (por ejemplo, .#vm) y quieres empezar a usar el nuevo objetivo por host
manteniendo el legado disponible.

1. Cambia a la rama de refactor

- git switch ddubos-refactor

Importante (usuarios v2.4): La primera reconstrucción debe ser con
nixos-rebuild, no con zcli

- En Stable v2.4 el zcli instalado no es compatible con el refactor. Después de
  cambiar de rama, ejecuta una reconstrucción con tu objetivo de perfil actual
  para instalar el zcli actualizado.
  - Ejemplo: sudo nixos-rebuild switch --flake .#vm
- Después de esa reconstrucción inicial, ya puedes usar zcli y los objetivos por
  host.

2. Asegura que exista una carpeta de host para la VM

- Si ya existe: hosts/ddubsos-vm
- Si no, crea la plantilla desde el default (y opcionalmente elige un perfil):
  - zcli add-host ddubsos-vm vm
  - Edita hosts/ddubos-vm/variables.nix según necesites (browser, terminal,
    stylixImage, etc.).

3. Apunta el host/perfil del flake a este host de la VM

- zcli update-host ddubsos-vm vm
  - Esto actualiza host = "ddubsos-vm" y profile = "vm" en flake.nix.

4. Reconstruye usando el objetivo por host (nuevo camino)

- sudo nixos-rebuild switch --flake .#ddubsos-vm
  - Todavía puedes usar el perfil legado: sudo nixos-rebuild switch --flake .#vm

> **Nota:** Hyprpanel es la opción predeterminada. La primera vez que inicies
> sesión, tardará entre 30 segundos y un minuto en cargarse, ya que está leyendo
> un archivo JSON muy grande. SUPER + Enter para abrir una terminal o SUPER + D
> para lanzar el menú de aplicaciones.

**⌨ ¿Ónde puedo ver los atajos de teclado de Hyprland?**

- SUPER + SHIFT + K abre el visor interactivo **qs-keybinds** con todos los atajos
- Navega atajos de Hyprland, Emacs, Kitty, WezTerm y Yazi con búsqueda en tiempo real
- Haz clic en cualquier atajo para copiarlo al portapapeles con notificación
- El icono de "teclas" en el lado derecho de la waybar también abrirá este menú.

<details>
<summary><strong>🖥️ ZCLI: ¿Qué es y cómo lo uso?</strong></summary>
<div style="margin-left: 20px;">

La utilidad `zcli` (v1.1.0) es una herramienta de línea de comandos diseñada
para simplificar la gestión de tu entorno ddubsOS. Proporciona un conjunto
completo de comandos con opciones avanzadas para la gestión del sistema,
configuración del host, tareas de mantenimiento, gestión de Doom Emacs y control
del servidor de monitoreo Glances.

Novedades en v1.1.0:

- Staging interactivo antes de reconstruir/actualizar
  - Los comandos de reconstrucción listan archivos sin rastrear/no preparados
    con índices; elige números o 'all' para agregarlos, o Enter para omitir.
  - Nuevas banderas:
    - `--no-stage` para omitir el aviso
    - `--stage-all` para preparar todo automáticamente
  - Nuevo comando: `zcli stage [--all]` para ejecutar el selector sin
    reconstruir

Novedades en v1.0.4:

- Edición de ajustes con validación, copias de seguridad y --dry-run
  - `zcli settings set <attr> <valor> [--dry-run]`
  - Valida `browser`/`terminal` contra listas soportadas; valida rutas para
    `stylixImage`, `waybarChoice`, `animChoice`
  - Descubrimiento: `zcli settings --list-browsers`,
    `zcli settings --list-terminals`
- Resumen de apps por host: `zcli hosts-apps` para listar paquetes específicos
  del host
- Comodidad: `zcli upgrade` como alias de `zcli update`

Para usarla, abre una terminal y escribe `zcli` seguido de uno de los comandos
que se enumeran a continuación. También puedes usar indicadores avanzados para
un mayor control:

### 🚀 **Comandos Principales:**

- `rebuild`: Reconstruye la configuración del sistema NixOS.
- `rebuild-boot`: Reconstruye y activa en el próximo arranque (más seguro para
  cambios importantes).
- `update`: Actualiza el flake y reconstruye el sistema.
- `cleanup`: Limpia las generaciones antiguas del sistema (especifica el número
  a conservar).
- `list-gens`: Lista las generaciones de usuario y del sistema.
- `trim`: Recorta los sistemas de archivos para mejorar el rendimiento de los
  SSD.
- `diag`: Crea un informe de diagnóstico del sistema, guardado en `~/diag.txt`.

### 🏠 **Gestión del Host:**

- `update-host`: Establece automáticamente el host y el perfil en `flake.nix`
  con detección de GPU.
- **Perfiles de GPU**: `amd`, `intel`, `nvidia`, `nvidia-laptop`, `vm`.

### ⚙️ **Opciones Avanzadas (v1.1.0):**

- `--dry, -n`: Muestra lo que se haría sin ejecutarlo (modo de prueba).
- `--ask, -a`: Pide confirmación antes de proceder con las operaciones.
- `--cores N`: Limita las operaciones de compilación a N núcleos de CPU (útil
  para VMs).
- `--verbose, -v`: Habilita la salida detallada para registros de operaciones
  detallados.
- `--no-nom`: Deshabilita nix-output-monitor para una salida más limpia.
- `--no-stage`: Omite el aviso de staging (no prepara nada antes de compilar).
- `--stage-all`: Prepara automáticamente todos los archivos sin rastrear/no
  preparados antes de compilar.

### 📚 **Ayuda:**

- `help`: Muestra un mensaje de ayuda completo con todas las opciones.

```text
Utilidad CLI de ddubsOS -- versión 1.1.0

Uso: zcli [comando] [opciones]

Comandos:
  cleanup         - Limpia las generaciones antiguas del sistema. Puede especificar un número a conservar.
  diag            - Crea un informe de diagnóstico del sistema.
                    (Nombre de archivo: homedir/diag.txt)
  list-gens       - Lista las generaciones de usuario y del sistema.
  rebuild         - Reconstruye la configuración del sistema NixOS.
  rebuild-boot    - Reconstruye y establece como predeterminado de arranque (se activa en el próximo reinicio).
  trim            - Recorta los sistemas de archivos para mejorar el rendimiento de los SSD.
  update          - Actualiza el flake y reconstruye el sistema.
  stage [--all]   - Prepara (staging) cambios de forma interactiva (o usar --all) antes de reconstruir.
  update-host     - Establece automáticamente el host y el perfil en flake.nix.
                    (Opcional: zcli update-host [hostname] [profile])

Opciones para los comandos rebuild, rebuild-boot y update:
  --dry, -n       - Muestra lo que se haría sin hacerlo
  --ask, -a       - Pide confirmación antes de proceder
  --cores N       - Limita la compilación a N núcleos (útil para VMs)
  --verbose, -v   - Muestra una salida detallada
  --no-nom        - No usa nix-output-monitor
  --no-stage      - Omite el aviso de staging (no prepara nada)
  --stage-all     - Prepara automáticamente todos los archivos sin rastrear/no preparados antes de compilar

Doom Emacs:
  doom install    - Instala Doom Emacs usando el script get-doom.
  doom status     - Comprueba si Doom Emacs está instalado.
  doom remove     - Elimina la instalación de Doom Emacs.
  doom update     - Actualiza Doom Emacs (ejecuta doom sync).

Servidor Glances:
  glances start   - Inicia el servidor de monitoreo glances.
  glances stop    - Detiene el servidor de monitoreo glances.
  glances restart - Reinicia el servidor de monitoreo glances.
  glances status  - Muestra el estado del servidor glances y las URL de acceso.
  glances logs    - Muestra los registros del servidor glances.

  help            - Muestra este mensaje de ayuda.

~
❯

ej: 
>zcli rebuild-boot --cores 4 
>zcli rebuild
>zcli rebuild --verbose --ask
```

</div>
</details>

## Principales Atajos de Teclado de Hyprland

A continuación se muestran los atajos de teclado para Hyprland, formateados para
una fácil referencia.

**📂 ¿É qué son las aplicaciones de selección rápida (qs-keybinds, qs-cheatsheets, qs-docs)?**

ddubsOS incluye tres potentes aplicaciones Qt6 QML para acceso rápido a ayuda y documentación:

### qs-keybinds (SUPER + SHIFT + K)
- **Visor interactivo de atajos** con búsqueda y filtrado en tiempo real
- **Soporte multi-modo**: Hyprland, Emacs, Kitty, WezTerm, Yazi y Cheatsheets
- **Funcionalidad de copia**: Haz clic en cualquier atajo para copiarlo al portapapeles con notificación
- **Filtrado por categorías**: Navega por categorías de aplicaciones y submodos
- **Categorías codificadas por color**: Organización visual con etiquetas de categorías temáticas

### qs-cheatsheets (SUPER + SHIFT + C)
- **Navegador integral de chuletas** para herramientas y aplicaciones
- **Soporte multi-idioma**: Documentación en inglés y español
- **Categorías de archivos**: emacs, hyprland, kitty, wezterm, yazi, nixos
- **Visualización de contenido en tiempo real**: Selecciona archivos y ve el contenido inmediatamente
- **Funcionalidad de búsqueda**: Filtra a través del contenido de las chuletas

### qs-docs (SUPER + SHIFT + D)
- **Visor de documentación técnica** para documentación de ddubsOS
- **Navegación inteligente de archivos**: Lee desde la estructura de directorios `~/ddubsos/docs/`
- **Guías de arquitectura**: Documentación detallada del sistema y guías de desarrollo
- **Multi-idioma**: Documentación técnica tanto en inglés como en español
- **Herramientas de navegación**: Búsqueda inteligente a través de archivos de documentación

**Las tres aplicaciones incluyen:**
- Interfaz Qt6 QML moderna con diseño consistente
- Reglas de ventana de Hyprland para flotación y centrado
- Atajos de teclado (ESC para cerrar, teclas de flecha para navegación)
- Integración de flujo de trabajo profesional

## Lanzamiento de Aplicaciones

- `$modifier + Return` → Lanzar `kitty`
- `$modifier + Shift + Return` → Lanzar `rofi-launcher`
- `$modifier + Shift + W` → Abrir `web-search`
- `$modifier + Alt + W` → Abrir `wallsetter`
- `$modifier + Shift + N` → Ejecutar `swaync-client -rs`
- `$modifier + W` → Lanzar `Google Chrome`
- `$modifier + Y` → Abrir `kitty` con `yazi`
- `$modifier + E` → Abrir `emopicker9000`
- `$modifier + S` → Tomar una captura de pantalla
- `$modifier + D` → Abrir `Discord`
- `$modifier + O` → Lanzar `OBS Studio`
- `$modifier + C` → Ejecutar `hyprpicker -a`
- `$modifier + G` → Abrir `GIMP`
- `$modifier + V` → Mostrar historial del portapapeles a través de `cliphist`
- `$modifier + T` → Alternar terminal con `pypr`
- `$modifier + M` → Abrir `pavucontrol`

## Gestión de Ventanas

- `$modifier + Q` → Matar ventana activa
- `$modifier + P` → Alternar pseudo mosaico
- `$modifier + Shift + I` → Alternar modo de división
- `$modifier + F` → Alternar pantalla completa
- `$modifier + Shift + F` → Alternar modo flotante
- `$modifier + Alt + F` → Alternar Pantalla Completa 1
- `$modifier + SPACE` → Flotar ventana actual
- `$modifier + Shift + SPACE` → Flotar todas las ventanas

## Movimiento de Ventanas

- `$modifier + Shift + ← / → / ↑ / ↓` → Mover ventana
  izquierda/derecha/arriba/abajo
- `$modifier + Shift + H / L / K / J` → Mover ventana
  izquierda/derecha/arriba/abajo
- `$modifier + Alt + ← / → / ↑ / ↓` → Intercambiar ventana
  izquierda/derecha/arriba/abajo
- `$modifier + Alt + 43 / 46 / 45 / 44` → Intercambiar ventana
  izquierda/derecha/arriba/abajo

## Movimiento de Foco

- `$modifier + ← / → / ↑ / ↓` → Mover foco izquierda/derecha/arriba/abajo
- `$modifier + H / L / K / J` → Mover foco izquierda/derecha/arriba/abajo

## Espacios de Trabajo

- `$modifier + 1-10` → Cambiar al espacio de trabajo 1-10
- `$modifier + Shift + Space` → Mover ventana al espacio de trabajo especial
- `$modifier + Space` → Alternar espacio de trabajo especial
- `$modifier + Shift + 1-10` → Mover ventana al espacio de trabajo 1-10
- `$modifier + Control + → / ←` → Cambiar espacio de trabajo adelante/atrás

## Ciclado de Ventanas

- `Alt + Tab` → Ciclar a la siguiente ventana
- `Alt + Tab` → Traer ventana activa al frente

</details>

<details>
<summary><strong>❄ ¿Por qué creaste ddubsOS?</strong></summary>

<div style="margin-left: 20px;">

- Estaba interesado en NixOS pero no sabía por dónde empezar.
- Encontré el proyecto ZaneyOS y me proporcionó una configuración estable y
  funcional.
- Al igual que ZaneyOS, ddubsOS no pretende ser una distro.
- Es mi configuración de trabajo, la comparto `tal cual`.
- ddubsOS tiene características que no encajaban con el diseño de Zaney.
- El nombre `ZaneyOS` es una broma interna entre amigos.
- Así que llamé a mi fork "ddubsOS".
- La intención es que esta configuración se pueda usar como sistema principal.
- Desarrollar software, jugar a través de Steam, etc.
- Mi esperanza es que sea útil y que la modifiques para que se ajuste a tus
  necesidades.
- Esa es la clave. Hazla tuya.
- Crea un fork de ddubsOS y luego modifícalo.
- Si encuentras un problema y lo solucionas, o proporcionas una nueva
  característica, por favor compártela.
- ddubsOS/ZaneyOS no son distros. En este momento no hay planes de crear una ISO
  de instalación.

</div>
</details>

<details>
<summary><strong>🖼️ Ajustes y configuración</strong></summary>

<div style="margin-left: 20px;">

<details>
<summary><strong>💫 ¿Cómo cambio el prompt de Starship?</strong></summary>

- Ve a `~/ddubsOS/hosts/HOSTNAME/`
- Edita `variables.nix`
- Busca la línea que empieza con `starshipChoice`
- Establécela a una de las configuraciones disponibles y reconstruye con
  `zcli rebuild`

Opciones disponibles:

- `../../modules/home/cli/starship.nix` (predeterminado)
- `../../modules/home/cli/starship-1.nix`
- `../../modules/home/cli/starship-rbmcg.nix`

Ejemplo:

```nix path=null start=null
# Establecer el prompt de Starship
starshipChoice = ../../modules/home/cli/starship.nix;
#starshipChoice = ../../modules/home/cli/starship-1.nix;
#starshipChoice = ../../modules/home/cli/starship-rbmcg.nix;
```

</details>

<div style="margin-left: 20px;">

<details>
<summary><strong>🌐 ¿Cómo cambio la waybar?</strong></summary>

- 📂 Ve a `~/ddubsos/hosts/HOSTNAME/`
- ✏️ Edita el archivo `variables.nix`
- 🔎 Encuentra la línea que comienza con `waybarChoice`
- 🔄 Cambia el nombre a uno de los archivos disponibles
- `waybar-simple.nix`, `waybar-nerodyke.nix`, `waybar-curved.nix`, o
  `waybar-ddubs.nix`
- 💾 Guarda el archivo y sal
- ⚡ Necesitas hacer una reconstrucción para que el cambio sea efectivo
- Ejecuta `fr` "flake rebuild" para iniciar el proceso de reconstrucción

```json
# Establecer Waybar
# Incluye alternativas como waybar-simple.nix, waybar-curved.nix y waybar-ddubs.nix
waybarChoice = ../../modules/home/waybar/waybar-ddubs.nix;
```

</details>

<details>
<summary><strong>🎛️ ¿Cómo cambio entre HyprPanel y Waybar?</strong></summary>

- 📂 Ve a `~/ddubsOS/hosts/HOSTNAME/`
- ✏️ Edita el archivo `variables.nix`
- 🔎 Encuentra la línea que comienza con `panelChoice`
- 🔄 Cambia el valor a `"hyprpanel"` o `"waybar"`
- 💾 Guarda el archivo y sal
- ⚡ Reconstruye con `zcli rebuild` para aplicar los cambios

```nix
# Elección de Panel - establece "hyprpanel" o "waybar"
panelChoice = "hyprpanel";
# o
panelChoice = "waybar";
```

**Opciones Disponibles:**

- `"hyprpanel"` - Panel moderno con características y widgets avanzados
- `"waybar"` - Barra tradicional con módulos personalizables

</details>

<details>
<summary><strong>📊 ¿Cómo habilito el servidor de monitoreo Glances?</strong></summary>

- 📂 Ve a `~/ddubsOS/hosts/HOSTNAME/`
- ✏️ Edita el archivo `variables.nix`
- 🔎 Encuentra la línea `enableGlances = false;`
- ✅ Cámbiala a `enableGlances = true;`
- 💾 Guarda el archivo y sal
- ⚡ Reconstruye con `zcli rebuild` para aplicar los cambios
- 🌐 Accede a la interfaz web en `http://localhost:61210`

```nix
# Servidor Glances - establece en true para habilitar el servidor web de glances
enableGlances = true;
```

**Características:**

- 📈 Panel de monitoreo del sistema en tiempo real
- 🌐 Interfaz web accesible desde cualquier dispositivo en tu red
- 📊 Monitoreo de CPU, memoria, disco, red y procesos
- 🛠️ Comandos de gestión: `glances-server start/stop/restart/status`

</details>

<details>
<summary><strong>📝 ¿Cómo habilito VSCode o Helix?</strong></summary>

- 📂 Ve a `~/ddubsOS/hosts/HOSTNAME/`
- ✏️ Edita el archivo `variables.nix`
- 🔎 Encuentra la sección "Opciones de Editor"
- ✅ Cambia el editor deseado de `false` a `true`
- 💾 Guarda el archivo y sal
- ⚡ Reconstruye con `zcli rebuild` para aplicar los cambios

```nix
# Opciones de Editor - establece en true para habilitar
enableEvilhelix = true;   # Habilitar evil-helix (Helix con atajos de teclado estilo Vim)
enableVscode = false;     # Mantener VSCode deshabilitado
```

**Opciones de Editor Disponibles:**

- `enableEvilhelix` - Editor Evil Helix con atajos de teclado estilo Vim y
  características modernas
- `enableVscode` - Visual Studio Code con extensiones y personalizaciones

**Notas:**

- Ambos editores están deshabilitados por defecto para mantener el sistema
  mínimo
- Puedes habilitar ambos editores en el mismo host si lo deseas
- Doom Emacs y Neovim siempre están disponibles y no necesitan estas variables

</details>

<details>
<summary><strong>🖥️ ¿Cómo habilito/deshabilito las terminales opcionales?</strong></summary>

- 📂 Ve a `~/ddubsOS/hosts/HOSTNAME/`
- ✏️ Edita el archivo `variables.nix`
- 🔎 Encuentra la sección "Opciones de Terminal"
- ✅ Cambia la terminal deseada de `false` a `true`
- 💾 Guarda el archivo y sal
- ⚡ Reconstruye con `zcli rebuild` para aplicar los cambios

```nix
# Opciones de Terminal - establece en true para habilitar
enableAlacritty = true;   # Habilitar terminal acelerada por GPU Alacritty
enableTmux = false;       # Habilitar multiplexor de terminal Tmux
enablePtyxis = false;     # Habilitar terminal de GNOME Ptyxis
```

**Opciones de Terminal Disponibles:**

- `enableAlacritty` - Emulador de terminal rápido acelerado por GPU escrito en
  Rust
- `enableTmux` - Multiplexor de terminal para gestionar múltiples sesiones de
  terminal
- `enablePtyxis` - Emulador de terminal moderno de GNOME con características
  avanzadas

**Terminales Principales (Siempre Disponibles):**

- **Ghostty** - Terminal moderna con excelente rendimiento y características
- **Kitty** - Emulador de terminal basado en GPU con soporte gráfico avanzado
- **Foot** - Emulador de terminal ligero para Wayland
- **WezTerm** - Emulador de terminal multiplataforma acelerado por GPU

**Notas:**

- Las terminales opcionales están deshabilitadas por defecto para mantener el
  sistema mínimo
- Puedes habilitar múltiples terminales en el mismo host si lo deseas
- Las terminales principales siempre están disponibles y no requieren estas
  variables
- Habilitar terminales solo afecta a los paquetes instalados, no al
  comportamiento del sistema

</details>

<details>
<summary><strong>🖥️ ¿Cómo habilito las GUIs opcionales de DE/WM?</strong></summary>

- 📂 Ve a `~/ddubsOS/hosts/HOSTNAME/`
- ✏️ Edita el archivo `variables.nix`
- 🔎 Encuentra la sección "Opciones de Entorno de Escritorio"
- ✅ Cambia el DE/WM deseado de `false` a `true`
- 💾 Guarda el archivo y sal
- ⚡ Reconstruye con `zcli rebuild` para aplicar los cambios

```nix
# Opciones de Entorno de Escritorio - establece en true para habilitar
gnomeEnable = false;      # Entorno de escritorio GNOME
bspwmEnable = true;       # Gestor de ventanas de mosaico BSPWM
dwmEnable = false;        # Gestor de ventanas suckless DWM
wayfireEnable = false;    # Compositor Wayland Wayfire
```

**Opciones de Entorno de Escritorio Disponibles:**

- `gnomeEnable` - Entorno de escritorio GNOME completo con todas las
  aplicaciones y servicios
- `bspwmEnable` - Gestor de Ventanas de Partición de Espacio Binario (WM de
  mosaico ligero)
- `dwmEnable` - Gestor de Ventanas Dinámico de las herramientas suckless (WM de
  mosaico mínimo)
- `wayfireEnable` - Compositor Wayland Wayfire con efectos y plugins

**Notas:**

- Todos los entornos de escritorio están deshabilitados por defecto (Hyprland es
  el DE principal)
- Habilita solo un entorno de escritorio a la vez para evitar conflictos
- Estas son opciones adicionales junto con la configuración predeterminada de
  Hyprland
- Cada DE/WM viene con su propio conjunto de aplicaciones y configuraciones

</details>

<details>
<summary><strong>🕒 ¿Cómo cambio la zona horaria?</strong></summary>

1. En el archivo, `~/ddubsOS/modules/core/system.nix`
2. Edita la línea: `time.timeZone = "America/New_York";`
3. Guarda el archivo y reconstruye usando el alias `fr`.

</details>

<details>
<summary><strong>🖥️ ¿Cómo cambio la configuración del monitor?</strong></summary>

La configuración de monitores está en:
`~/ddubsOS/hosts/<HOSTNAME>/variables.nix`

Con la migración a monitorv2, usa la lista estructurada `hyprMonitorsV2` al
final de ese archivo. La variable heredada `extraMonitorSettings` (cadena con
`monitor = ...`) sigue disponible por compatibilidad y ejemplos, pero se
prefiere v2.

Pasos rápidos

- Busca el bloque hyprMonitorsV2 al final de variables.nix de tu host
- Agrega o edita salidas allí
- Reconstruye: `zcli rebuild` (o alias `fr`)
- Verifica: `hyprctl monitors`

Monitor único (v2)

```nix
hyprMonitorsV2 = [
  {
    output = "eDP-1";
    mode = "1920x1080@60";
    position = "0x0";   # o "auto"
    scale = 1;
    enabled = true;      # establece false para deshabilitar
  }
];
```

Dos monitores lado a lado (v2)

```nix
hyprMonitorsV2 = [
  {
    output = "DP-1";
    mode = "2560x1440@144";
    position = "0x0";
    scale = 1;
    transform = 0;       # 0=normal, 1=90, 2=180, 3=270, 4..7=volteados
    enabled = true;
  }
  {
    output = "HDMI-A-1";
    mode = "1920x1080@60";
    position = "2560x0"; # a la derecha de DP-1
    scale = 1.25;
    transform = 0;
    enabled = true;
  }
];
```

Ejemplo de espejo (v2)

```nix
hyprMonitorsV2 = [
  { output = "eDP-1"; mode = "1920x1080@60"; position = "0x0"; scale = 1; enabled = true; }
  { output = "HDMI-A-1"; mirror = "eDP-1"; enabled = true; }
];
```

Notas

- enabled activa/desactiva una salida sin quitar su bloque
- transform: 0=normal, 1=90, 2=180, 3=270, 4=volteado, 5=volteado-90,
  6=volteado-180, 7=volteado-270
- La cadena heredada permanece al final de variables.nix (comentada); los VMs
  incluyen un Virtual-1 por defecto

Descubrir nombres y modos

- Ejecuta `hyprctl monitors` para listar salidas, modos disponibles,
  escala/transformación actual, etc.

Asistente GUI (opcional)

- Herramientas como `nwg-displays` pueden ayudarte a descubrir la disposición;
  copia los ajustes a hyprMonitorsV2 después

Más detalles: consulta docs/outline-move-monitorsv2-way-displays.md y la página
de Monitors de Hyprland.

</details>

<details>
<summary><strong>🚀 ¿Cómo agrego aplicaciones a ddubsOS?</strong></summary>

### Hay dos opciones. Una para todos los hosts que tienes, otra para un host específico.

1. Para que las aplicaciones se incluyan en todos los hosts definidos, edita el
   archivo `~/ddubsOS/modules/core/packages.nix`.

Hay una sección que comienza con: `environment.systemPackages = with pkgs;`

Seguida de una lista de paquetes. Estos son necesarios para ddubsOS.

Sugerimos que agregues un comentario al final de los nombres de los paquetes.
Luego agrega tus paquetes.

```text
    ...
    virt-viewer
    wget
    ###  Mis Aplicaciones ### 
    bottom
    dua
    emacs-nox
    fd
    gping
    lazygit
    lunarvim
    luarocks
    mission-center
    ncdu
    nvtopPackages.full
    oh-my-posh
    pyprland
    shellcheck
    multimarkdown
    nodejs_23
    ugrep
    zoxide
  ];
}
```

2. Para aplicaciones que solo estarán en un host específico.

Edita el `host-packages.nix` asociado con ese host.
`~/ddubsOS/hosts/<HOSTNAME>/host-packages.nix`

La parte del archivo que necesitas editar se ve así:

```nix
{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    audacity
    discord
    nodejs
    obs-studio
  ];
}
```

Puedes agregar paquetes adicionales, o por ejemplo cambiar `discord` a
`discord-canary` para obtener la versión beta de Discord pero solo en este host.

</details>

<details>

<summary><strong>📥 Agregué los nombres de los paquetes, ¿ahora cómo los instalo?</strong></summary>

- Usa el alias `fr`, Flake Rebuild.

Si la reconstrucción se completa con éxito, se creará una nueva generación con
tus paquetes agregados.

</details>

<details>
<summary><strong>🔄 ¿Cómo actualizo los paquetes que ya he instalado?</strong></summary>

- Usa el alias `fu`, Flake Update. Esto buscará paquetes actualizados, los
  descargará e instalará.

</details>

<details>
<summary><strong>⚙️ Hice un cambio en mi configuración de ddubsOS, ¿cómo lo activo?</strong></summary>

- Usa el alias `fr`, Flake Rebuild. Si **creaste un archivo nuevo**, ten en
  cuenta que necesitarás ejecutar un comando `git add .` en la carpeta de
  ddubsOS. Si tiene éxito, se generará una nueva generación con tus cambios.
  Podría ser necesario cerrar sesión o reiniciar dependiendo de lo que hayas
  cambiado.

</details>

<details>

<summary><strong>🔠 ¿Qué fuentes están disponibles en NixOS?</strong></summary>

```nix
{pkgs, ...}: {
  fonts = {
    packages = with pkgs; [
      dejavu_fonts
      fira-code
      fira-code-symbols
      font-awesome
      hackgen-nf-font
      ibm-plex
      inter
      jetbrains-mono
      material-icons
      maple-mono.NF
      minecraftia
      nerd-fonts.im-writing
      nerd-fonts.blex-mono
      noto-fonts
      noto-fonts-emoji
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-monochrome-emoji
      powerline-fonts
      roboto
      roboto-mono
      symbola
      terminus_font
      # Fuentes NERD 
      nerd-fonts.0xproto
      nerd-fonts._3270
      nerd-fonts.agave
      nerd-fonts.anonymice
      nerd-fonts.arimo
      nerd-fonts.aurulent-sans-mono
      nerd-fonts.bigblue-terminal
      nerd-fonts.bitstream-vera-sans-mono
      nerd-fonts.blex-mono
      nerd-fonts.caskaydia-cove
      nerd-fonts.caskaydia-mono
      nerd-fonts.code-new-roman
      nerd-fonts.comic-shanns-mono
      nerd-fonts.commit-mono
      nerd-fonts.cousine
      nerd-fonts.d2coding
      nerd-fonts.daddy-time-mono
      nerd-fonts.departure-mono
      nerd-fonts.dejavu-sans-mono
      nerd-fonts.droid-sans-mono
      nerd-fonts.envy-code-r
      nerd-fonts.fantasque-sans-mono
      nerd-fonts.fira-code
      nerd-fonts.fira-mono
      nerd-fonts.geist-mono
      nerd-fonts.go-mono
      nerd-fonts.gohufont
      nerd-fonts.hack
      nerd-fonts.hasklug
      nerd-fonts.heavy-data
      nerd-fonts.hurmit
      nerd-fonts.im-writing
      nerd-fonts.inconsolata
      nerd-fonts.inconsolata-go
      nerd-fonts.inconsolata-lgc
      nerd-fonts.intone-mono
      nerd-fonts.iosevka
      nerd-fonts.iosevka-term
      nerd-fonts.iosevka-term-slab
      nerd-fonts.jetbrains-mono
      nerd-fonts.lekton
      nerd-fonts.liberation
      nerd-fonts.lilex
      nerd-fonts.martian-mono
      nerd-fonts.meslo-lg
      nerd-fonts.monaspace
      nerd-fonts.monofur
      nerd-fonts.monoid
      nerd-fonts.mononoki
      nerd-fonts.mplus
      nerd-fonts.noto
      nerd-fonts.open-dyslexic
      nerd-fonts.overpass
      nerd-fonts.profont
      nerd-fonts.proggy-clean-tt
      nerd-fonts.recursive-mono
      nerd-fonts.roboto-mono
      nerd-fonts.shure-tech-mono
      nerd-fonts.sauce-code-pro
      nerd-fonts.space-mono
      nerd-fonts.symbols-only
      nerd-fonts.terminess-ttf
      nerd-fonts.tinos
      nerd-fonts.ubuntu
      nerd-fonts.ubuntu-mono
      nerd-fonts.ubuntu-sans
      nerd-fonts.victor-mono
      nerd-fonts.zed-mono

    ];
  };
}
```

</details>

<details>
<summary><strong>🐧 ¿Cómo puedo configurar un kernel diferente en un host específico?</strong></summary>

1. Tienes que editar el archivo `hardware.nix` para ese host en
   `~/ddubsOS/hosts/HOSTNAME/hardware.nix` y anular el predeterminado.
2. Cerca de la parte superior encontrarás esta sección del archivo
   `hardware.nix`.

```nix
boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "rtsx_usb_sdmmc"];
boot.initrd.kernelModules = [];
boot.kernelModules = ["kvm-intel"];
boot.extraModulePackages = [];
```

3. Agrega la anulación. Por ejemplo, para establecer el kernel en 6.12.

- `boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_12;`

4. El código actualizado debería verse así:

```nix
boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "rtsx_usb_sdmmc"];
boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_12;
boot.initrd.kernelModules = [];
boot.kernelModules = ["kvm-intel"];
boot.extraModulePackages = [];
```

5. Usa el alias de comando `fr` para crear una nueva generación y reinicia para
   que surta efecto.

</details>

<details>

<summary><strong>🐧 ¿Cuáles son las principales opciones de Kernel en NixOS?</strong></summary>
NixOS ofrece varios tipos de kernel principales para satisfacer diferentes necesidades y preferencias. A continuación se presentan las opciones disponibles, excluyendo versiones específicas del kernel:

1. **`linuxPackages`**
   - El kernel estable predeterminado, generalmente una versión LTS (Soporte a
     Largo Plazo). LTS en 25.05 (warbler) es 6.12.x. Los kernels más antiguos,
     6.6.x, 6.8.x no son compatibles.

2. **`linuxPackages_latest`**
   - El último kernel de la línea principal, que puede incluir características
     más nuevas pero podría ser menos estable.

3. **`linuxPackages_zen`**
   - Un kernel optimizado para el rendimiento con parches destinados a mejorar
     la capacidad de respuesta y la interactividad. Comúnmente utilizado por
     jugadores y usuarios de escritorio.

4. **`linuxPackages_hardened`**
   - Un kernel centrado en la seguridad con parches de endurecimiento
     adicionales para una mayor protección.

5. **`linuxPackages_rt`**
   - Un kernel en tiempo real diseñado para aplicaciones de baja latencia y
     sensibles al tiempo, como la producción de audio o la robótica.

6. **`linuxPackages_libre`**
   - Un kernel despojado de firmware y controladores propietarios, que se
     adhiere a los principios del software libre.

7. **`linuxPackages_xen_dom0`**
   - Un kernel diseñado para ejecutarse como el host (dom0) en entornos de
     virtualización Xen.

8. **`linuxPackages_mptcp`**
   - Un kernel con soporte para Multipath TCP, útil para escenarios de red
     avanzados.

</details>

</details>

<details>
<summary><strong>📷 v4l2loopback falla al compilar con el kernel CachyOS (clang). ¿Cómo lo soluciono?</strong></summary>

- Síntoma: gcc no encontrado o errores de argumentos no usados de clang al
  compilar v4l2loopback contra el kernel Cachy/clang; la fase de instalación
  puede intentar compilar una utilidad de usuario y fallar.
- Solución: ddubsOS fuerza la toolchain LLVM para compilar el módulo e instala
  solo el módulo del kernel, omitiendo la utilidad. Consulta el documento con la
  solución exacta:
  - docs/Cachy-kernel-v4l2loopback-build-issues.md

</details>

<details>
<summary><strong>🗑️ Tengo generaciones más antiguas que quiero eliminar, ¿cómo puedo hacerlo?</strong></summary>

- El alias `ncg` de NixOS Clean Generations eliminará **TODAS** las generaciones
  excepto la más actual. Asegúrate de haber arrancado desde esa generación antes
  de usar este alias. También hay un programa que eliminará las generaciones más
  antiguas automáticamente con el tiempo.

</details>

</details>

<details>
<summary><strong>📝 ¿Cómo cambio el nombre de host?</strong></summary>

Para cambiar el nombre de host, hay varios pasos y tendrás que reiniciar para
que el cambio sea efectivo.

1. Copia el directorio del host que deseas renombrar a un directorio con el
   nuevo nombre.

- `cp -rpv ~/ddubsOS/hosts/OLD-HOSTNAME ~/ddubsOS/hosts/NEW-HOSTNAME`

2. Edita el archivo `~/ddubsOS/flake.nix`. Cambia la línea:

- `host = "NEW-HOSTNAME"`

3. En el directorio `~/ddubsOS` ejecuta `git add .` _La reconstrucción fallará
   con un error de 'archivo no encontrado' si olvidas este paso._

4. Usa el alias `fr` para crear una nueva generación con el nuevo nombre de
   host. Debes reiniciar para que el cambio sea efectivo.

</details>
</details>

<details>
<summary><strong>❄️ ¿Cómo deshabilito el copo de nieve giratorio al inicio?</strong></summary>

1. Edita el archivo `~/ddubsOS/modules/core/boot.nix`.
2. Busca:

```nix
};
 plymouth.enable = true;
};
```

3. Cámbialo a `false`
4. Ejecuta el alias de comando `fr` para crear una nueva generación.

</details>

</details>

<details>
<summary><strong>💻 ¿Cómo configuro mi portátil híbrido con GPUs Intel/NVIDIA?</strong></summary>
1. Ejecuta el script `install-ddubsOS.sh` y selecciona la plantilla `nvidia-laptop` o, si lo configuras manualmente, establece la plantilla en el `flake.nix` en `nvidia-prime`.

2. En el archivo `~/ddubsOS/hosts/HYBRID-HOST/variables.nix` necesitarás
   establecer los ID de PCI para las GPUs Intel y NVIDIA. Consulta
   [esta página](https://nixos.wiki/wiki/Nvidia) para ayudarte a determinar esos
   valores.

3. Una vez que hayas configurado todo correctamente, usa el alias `fr` de Flake
   Rebuild para crear una nueva generación.

4. En el archivo `~/ddubsOS/modules/home/hyprland/config.nix` hay una
   configuración de ENV `"AQ_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1"`. Esto
   establece las GPUs primaria y secundaria. Usando la información del enlace
   anterior, es posible que tengas que cambiar el orden de estos valores.

</details>

<details>
<summary><strong>🤖 OpenWebUI + Ollama - Infraestructura de IA/LLM</strong></summary>

**Disponible solo en sistemas NVIDIA** - Esta infraestructura de IA/LLM
proporciona inferencia de modelos de lenguaje locales con una interfaz web
moderna.

### 🚀 **Inicio Rápido**

1. **Accede a la Interfaz Web**
   - Abre tu navegador y ve a `http://localhost:3000`
   - La interfaz estará disponible después de la reconstrucción del sistema en
     hosts NVIDIA

2. **Descarga tu Primer Modelo**
   - En OpenWebUI, haz clic en "Models" → "Pull a model from Ollama.com"
   - Intenta comenzar con `llama3.2:1b` para un modelo ligero
   - O usa la línea de comandos: `ollama-webui-manager models`

### 📊 **Uso del Script de Gestión**

El comando `ollama-webui-manager` proporciona un control completo:

```bash
# Comprobar el estado del sistema
ollama-webui-manager status

# Control del servicio
ollama-webui-manager start     # Iniciar servicios
ollama-webui-manager stop      # Detener servicios  
ollama-webui-manager restart   # Reiniciar servicios

# Monitoreo de registros
ollama-webui-manager logs           # Ver ambos registros de servicio
ollama-webui-manager logs ollama    # Solo registros de Ollama
ollama-webui-manager logs webui     # Solo registros de OpenWebUI

# Gestión de modelos
ollama-webui-manager models    # Listar modelos descargados

# Comprobaciones de estado
ollama-webui-manager test      # Probar la conectividad de la API

# Ayuda y documentación
ollama-webui-manager help      # Mostrar todos los comandos
```

### 🌐 **Puntos de Acceso**

- **Interfaz Web de OpenWebUI**: `http://localhost:3000`
  - Interfaz de chat moderna para interactuar con modelos de IA
  - Gestión y configuración de modelos
  - Historial de chat y gestión de conversaciones

- **API de Ollama**: `http://localhost:11434`
  - Acceso directo a la API para uso programático
  - Puntos finales REST para inferencia de modelos
  - Integración con herramientas de desarrollo

### 🎯 **Opciones de Configuración**

El servicio se puede personalizar en tu configuración de NixOS:

```nix
# En profiles/nvidia/default.nix o profiles/nvidia-laptop/default.nix
services.openwebui-ollama = {
  enable = true;
  openwebuiPort = 3000;    # Puerto de la interfaz web (predeterminado: 3000)
  ollamaPort = 11434;      # Puerto de la API (predeterminado: 11434)
  dataDir = "/var/lib/openwebui-ollama";  # Ubicación de almacenamiento de datos
  user = "openwebui";      # Usuario del servicio (predeterminado: openwebui)
  group = "openwebui";     # Grupo del servicio (predeterminado: openwebui)
};
```

### 🛠️ **Uso Avanzado**

**Comandos Directos de Docker** (si es necesario):

```bash
# Descargar modelos directamente
docker exec ollama ollama pull llama3.2:1b

# Listar contenedores en ejecución
docker ps | grep -E "(ollama|openwebui)"

# Comprobar registros de contenedores
docker logs ollama
docker logs openwebui
```

**Gestión del Servicio SystemD**:

```bash
# Comprobar el estado del servicio
sudo systemctl status ollama-docker.service
sudo systemctl status openwebui-docker.service

# Reinicio manual (usa el script de gestión en su lugar)
sudo systemctl restart ollama-docker.service
sudo systemctl restart openwebui-docker.service
```

### 📁 **Ubicación de Datos**

- **Modelos**: `/var/lib/openwebui-ollama/ollama/`
- **Datos de OpenWebUI**: `/var/lib/openwebui-ollama/openwebui/`
- **Configuración**: Gestionada a través de los archivos de configuración de
  NixOS

### ⚡ **Consejos de Rendimiento**

1. **Selección de Modelo**: Comienza con modelos más pequeños (parámetros de
   1B-3B) para probar
2. **Memoria de la GPU**: Monitorea el uso de VRAM con `nvidia-smi` al ejecutar
   modelos grandes
3. **Almacenamiento**: Los modelos pueden ser grandes (1GB-50GB+), asegúrate de
   tener suficiente espacio en disco
4. **Red**: Las descargas iniciales de modelos requieren una buena conexión a
   internet

### 🔧 **Solución de Problemas**

**Los servicios no se inician:**

```bash
# Comprobar estado y registros
ollama-webui-manager status
ollama-webui-manager logs

# Probar conectividad
ollama-webui-manager test

# Reiniciar servicios
ollama-webui-manager restart
```

**Los modelos no se cargan:**

- Asegúrate de que haya suficiente VRAM disponible
- Comprueba el espacio en disco para el almacenamiento de modelos
- Verifica que la descarga del modelo se haya completado con éxito

**La interfaz web no es accesible:**

- Confirma que los servicios se están ejecutando: `ollama-webui-manager status`
- Comprueba que el firewall permite el puerto 3000
- Intenta acceder a `http://localhost:3000` directamente

### 📖 **Modelos Populares para Probar**

#### **Para GPUs de 4GB (GTX 1650, RTX 3050, etc.)**

| Modelo           | Tamaño | Caso de Uso                                      |
| ---------------- | ------ | ------------------------------------------------ |
| `llama3.2:1b`    | ~1GB   | Chat rápido y ligero                             |
| `llama3.2:3b`    | ~3GB   | Mejor calidad, aún rápido                        |
| `phi3:mini`      | ~2GB   | Modelo eficiente de Microsoft                    |
| `phi3:3.8b`      | ~2.3GB | Phi3 mejorado con mejor razonamiento             |
| `qwen2:1.5b`     | ~1GB   | Modelo ligero de Alibaba                         |
| `gemma:2b`       | ~1.4GB | Modelo pequeño pero capaz de Google              |
| `tinyllama:1.1b` | ~637MB | Ultraligero para tareas básicas                  |
| `orca-mini:3b`   | ~1.9GB | Bueno para preguntas y respuestas y razonamiento |

#### **Para GPUs de 6GB (GTX 1660, RTX 3060, RTX 4060, etc.)**

| Modelo                 | Tamaño | Caso de Uso                                     |
| ---------------------- | ------ | ----------------------------------------------- |
| `llama3.2:3b`          | ~3GB   | Último modelo eficiente de Meta                 |
| `mistral:7b`           | ~4.1GB | Propósito general, alta calidad                 |
| `codellama:7b`         | ~3.8GB | Generación de código y ayuda en programación    |
| `phi3:medium`          | ~7.9GB | ⚠️ _Puede requerir cuantización_                |
| `neural-chat:7b`       | ~3.8GB | Modelo conversacional afinado de Intel          |
| `zephyr:7b-beta`       | ~4.1GB | Modelo de seguimiento de instrucciones          |
| `vicuna:7b`            | ~3.8GB | Fuertes habilidades conversacionales            |
| `orca-mini:7b`         | ~3.8GB | Modelo de Microsoft centrado en el razonamiento |
| `starling-lm:7b-alpha` | ~4.1GB | Modelo de chat de alta calidad                  |
| `openhermes:7b`        | ~3.8GB | Bueno para tareas creativas y analíticas        |

#### **Consejos de Uso de Memoria**

- **Modelos cuantizados** (que terminan en `-q4` o `-q8`) usan menos VRAM pero
  pueden tener una calidad ligeramente reducida
- **Deja 1-2GB de VRAM libres** para la sobrecarga del sistema y el
  procesamiento del contexto
- **Monitorea el uso** con `nvidia-smi` mientras ejecutas modelos
- **Prueba con ventanas de contexto más pequeñas** si encuentras errores de
  falta de memoria

**Nota**: Esta característica está disponible automáticamente en hosts que usan
los perfiles `nvidia` o `nvidia-laptop` después de reconstruir tu sistema con
`zcli rebuild`.

</details>

</div>

</details>

<details>
<summary><strong>🎨 Stylix</strong></summary>

<div style="margin-left: 20px;">

<details>
<summary>¿Cómo habilito o deshabilito Stylix?</summary>

- Para Habilitar:

1. Edita el archivo `~/ddubsOS/modules/core/stylix.nix`.
2. Comenta desde `base16Scheme` hasta el `};` después de `base0F`.

```nix
# Opciones de Estilo
  stylix = {
    enable = true;
    image = ../../wallpapers/Anime-girl-sitting-night-sky_1952x1120.jpg;
    #image = ../../wallpapers/Rainnight.jpg;
    #image = ../../wallpapers/zaney-wallpaper.jpg;
    #  base16Scheme = {
    #  base00 = "282936";
    #  base01 = "3a3c4e";
    #  base02 = "4d4f68";
    #  base03 = "626483";
    #  base04 = "62d6e8";
    #  base05 = "e9e9f4";
    #  base06 = "f1f2f8";
    #  base07 = "f7f7fb";
    #  base08 = "ea51b2";
    #  base09 = "b45bcf";
    #  base0A = "00f769";
    #  base0B = "ebff87";
    #  base0C = "a1efe4";
    #  base0D = "62d6e8";
    #  base0E = "b45bcf";
    #  base0F = "00f769";
    #};
    polarity = "dark";
    opacity.terminal = 1.0;
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };
```

3. Selecciona la imagen que quieres que Stylix use para la paleta de colores.
4. Ejecuta el alias de comando `fr` para crear una nueva generación con este
   esquema de colores.

- Para deshabilitar, descomenta:

1. Edita el archivo `~/ddubsOS/modules/core/stylix.nix`.
2. Descomenta desde `base16Scheme` hasta el `};` después de `base0F`.

```nix
 base16Scheme = {
  base00 = "282936";
  base01 = "3a3c4e";
  base02 = "4d4f68";
  base03 = "626483";
  base04 = "62d6e8";
  base05 = "e9e9f4";
  base06 = "f1f2f8";
  base07 = "f7f7fb";
  base08 = "ea51b2";
  base09 = "b45bcf";
  base0A = "00f769";
  base0B = "ebff87";
  base0C = "a1efe4";
  base0D = "62d6e8";
  base0E = "b45bcf";
  base0F = "00f769";
};
```

3. Ejecuta el alias de comando `fr` para construir una nueva generación con el
   drácula predeterminado o establece tus propios colores personalizados.

</details>

<details>
 <summary>¿Cómo cambio la imagen que Stylix usa para el tema?</summary>

1. Edita el archivo `~/ddubsOS/hosts/HOSTNAME/varibles.nix`.
2. Cambia el `stylixImage =` al nombre de archivo que quieres usar. Los fondos
   de pantalla están en `~/ddubsOS/wallpapers`.

```nix
# Establecer Imagen de Stylix
stylixImage = ../../wallpapers/AnimeGirlNightSky.jpg;
```

</details>

</div>

</details>

<details>
<summary><strong>🌃 Fondos de Pantalla</strong></summary>

<div style="margin-left: 20px;">

<details>
<summary><strong>¿Cómo agrego más fondos de pantalla?</strong></summary>

- Los fondos de pantalla se almacenan en el directorio `~/ddubsOS/wallpapers`.
- Simplemente copia los nuevos a ese directorio.

</details>

<details>

<summary><strong>¿Cómo cambio el fondo?</strong></summary>

- SUPER + ALT + W seleccionará un nuevo fondo.
- También puedes usar `waypaper` para seleccionar fondos de pantalla o
  seleccionar otra carpeta.

</details>

<details>

<summary><strong>¿Cómo puedo establecer un temporizador para cambiar el fondo de pantalla automáticamente?</strong></summary>

1. Edita el archivo `~/ddubsOS/modules/home/hyprland/config.nix`.
2. Comenta la línea `sleep 1.5 && swww img ...`
3. Agrega una nueva línea después de esa con `sleep 1 && wallsetter`.

```json
settings = {
     exec-once = [
       "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
       "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
       "killall -q swww;sleep .5 && swww init"
       "killall -q waybar;sleep .5 && waybar"
       "killall -q swaync;sleep .5 && swaync"
       "nm-applet --indicator"
       "lxqt-policykit-agent"
       "pypr &"
       #"sleep 1.5 && swww img /home/${username}/Pictures/Wallpapers/zaney-wallpaper.jpg"
       "sleep 1 && wallsetter"
     ];
```

4. Ejecuta el alias de comando `fr` para crear una nueva generación.
5. Necesitarás cerrar sesión o reiniciar para que el cambio sea efectivo.

</details>

<details>

<summary><strong>¿Cómo cambio el intervalo en que cambia el fondo de pantalla?</strong></summary>

1. Edita el archivo `~/ddubsOS/modules/home/scripts/wallsetter`.
2. Cambia el valor de `TIMEOUT =`. Está en segundos.
3. Ejecuta el alias de comando `fr` para crear una nueva generación.
4. Necesitarás cerrar sesión o reiniciar para que el cambio sea efectivo.

</details>

</div>

</details>

<details>
<summary><strong>⬆ ¿Cómo actualizo ddubsOS?</strong></summary>

<div style="margin-left: 20px;">

<details>
<summary>Para versiones v1.0+</summary>

1. Primero, haz una copia de seguridad de tu directorio `ddubsOS` existente.

- `cp -rpv ~/ddubsOS ~/Backup-ZaneyOS`

_Cualquier cambio que hayas hecho en la configuración de ddubsOS deberá
rehacerse._

2. En el directorio `ddubsOS` ejecuta `git stash && git pull`.

3. Copia de vuelta tu(s) host(s) creado(s) previamente.

- `cp -rpv ~/Backup-ZaneyOS/hosts/HOSTNAME  ~/ddubsOS/hosts`

4. Si no usaste el host `default` durante tu instalación inicial.

- Entonces no copies el host `default` de tu copia de seguridad. El nuevo host
  predeterminado podría tener actualizaciones o correcciones que necesitarás
  para el próximo host que crees.**
- Entonces tendrás que comparar manualmente tu copia de seguridad con la nueva
  plantilla de host `default` actualizada, y potencialmente fusionar los cambios
  y sobrescribir tu archivo `hardware.nix` en el archivo
  `~/ddubsOS/hosts/default/hardware.nix`.**

5. En el directorio `ddubsOS` ejecuta `git add .` cuando hayas terminado de
   copiar tu(s) host(s).

6. Para cualquier otro cambio que hayas hecho. Por ejemplo: atajos de teclado de
   hyprland, configuración de waybar, si agregaste paquetes adicionales al
   archivo `modules/packages.nix`. Esos tendrás que fusionarlos manualmente de
   nuevo en la nueva versión.

</details>

</div>

</details>

</div>

<details><summary><strong>📂 Diseño de ddubsOS v2.x</strong></summary>

<div style="margin-left: 25px;">

#### 📂 ~/ddubsOS

```text
 .
├──  cheatsheets                  # Chuletas y referencias rápidas
├──  docs                         # Documentación y guías del proyecto
├──  features                     # Módulos de funciones de zcli (en tiempo de ejecución)
│   ├── diag.sh
│   ├── doom.sh
│   ├── generations.sh
│   ├── glances.sh
│   ├── hosts.sh
│   ├── rebuild.sh
│   ├── settings.sh
│   └── trim.sh
├──  hosts                        # Configuraciones por host
│   ├── asus
│   ├── bubo
│   ├── ddubsos-vm
│   ├── default                    # Plantilla para nuevos hosts
│   ├── explorer
│   ├── ixas
│   ├── macbook
│   ├── mini-intel
│   ├── pegasus
│   ├── prometheus
│   └── xps15
├──  img                          # Imágenes usadas en la documentación
├──  lib                          # Bibliotecas compartidas de zcli
│   ├── args.sh
│   ├── common.sh
│   ├── nix.sh
│   ├── sys.sh
│   └── validate.sh
├──  modules                      # Módulos de NixOS/Home Manager
│   ├──  core
│   ├──  drivers
│   └── 󱂵 home
│       ├──  cli
│       ├──  editors
│       ├──  gui
│       ├──  hyprland
│       ├──  hyprpanel
│       ├──  scripts              # incluye zcli.nix (dispatcher)
│       ├──  shells
│       ├──  terminals
│       ├──  waybar
│       ├──  wlogout
│       ├──  yazi
│       └──  zsh
├──  myscripts-repo               # Scripts personales
├──  profiles                     # Perfiles de hardware/GPU
├──  wallpapers                   # Repositorio de fondos de pantalla
├── flake.nix
└── flake.lock
```

</div>

</details>

## 🧰 Misceláneos

<details>
<summary><strong>📚 ¿Cuál es la diferencia entre los diseños Master y Dwindle?</strong></summary>

<div style="margin-left: 20px;">
<br>

**1. Diseño Master**

- El diseño **Master** divide el espacio de trabajo en dos áreas principales:
  - Un **área maestra** para la ventana principal, que ocupa una porción más
    grande de la pantalla.
  - Un **área de pila** para todas las demás ventanas, que se organizan en
    mosaico en el espacio restante.
- Este diseño es ideal para flujos de trabajo en los que deseas centrarte en una
  única ventana principal mientras mantienes las demás accesibles.

**2. Diseño Dwindle**

- El diseño **Dwindle** es un diseño de mosaico basado en un árbol binario:
  - Cada nueva ventana divide el espacio disponible dinámicamente, alternando
    entre divisiones horizontales y verticales.
  - Las divisiones se determinan por la relación de aspecto del contenedor
    principal (p. ej., divisiones más anchas horizontalmente, divisiones más
    altas verticalmente).
- Este diseño es más dinámico y distribuye el espacio de manera más uniforme
  entre todas las ventanas.

---

**Cómo Verificar el Diseño Actual**

Para comprobar qué diseño está activo actualmente, usa el comando `hyprctl`:

`hyprctl getoption general:layout`

</details>
</div>

</details>

<details>
<summary><strong>📦 ¿Cuáles son los atajos de teclado de Yazi y cómo puedo cambiarlos?</strong></summary>

<div style="margin-left: 20px;"> <br>

El archivo de configuración de Yazi se encuentra en
`~/ddubsos/modules/home/yazi.nix`

Yazi se configura como VIM y los movimientos de VIM

El mapa de teclas está en el archivo `~/ddubsos/modules/home/yazi/keymap.toml`

</div>
</details>

<details>

<summary><strong>❄ ¿Error al iniciar Yazi?</strong></summary>

<div style="margin-left: 20px;">

```text
yazi
Error: El tiempo de ejecución de Lua falló

Causado por:
    error de tiempo de ejecución: [string "git"]:133: intento de indexar un valor nulo (global 'THEME')
    rastreo de pila:
        [C]: en el metamétodo 'index'
        [string "git"]:133: en la función 'git.setup'
        [C]: en el método 'setup'
        [string "init.lua"]:2: en el fragmento principal
    rastreo de pila:
        [C]: en el método 'setup'
        [string "init.lua"]:2: en el fragmento principal
```

- Para resolverlo, ejecuta `ya pack -u` en una terminal. Reinicia `yazi`.

</div>
</details>

## 🖥️ Terminales

<details>
<summary><strong>🐱 Kitty</strong></summary>

<details>

<summary>Mi cursor en Kitty es "inestable" y salta. ¿Cómo lo arreglo?</summary>

- Esa característica se llama "cursor_trail" en el archivo
  `~/ddubsOS/modules/home/kitty.nix`.

1. Edita ese archivo y cambia `cursor_trail 1` a `cursor_trail 0` o comenta esa
   línea.
2. Usa el alias de comando `fr` para crear una nueva generación con el cambio.

</details>

<details>
 <summary>¿Cuáles son los atajos de teclado de Kitty y cómo puedo cambiarlos?</summary>

Los atajos de Kitty se configuran en `~/ddubsOS/modules/home/kitty.nix`

Los predeterminados son:

```text
    # Portapapeles
    map ctrl+shift+v        paste_from_selection
    map shift+insert        paste_from_selection

    # Desplazamiento
    map ctrl+shift+up        scroll_line_up
    map ctrl+shift+down      scroll_line_down
    map ctrl+shift+k         scroll_line_up
    map ctrl+shift+j         scroll_line_down
    map ctrl+shift+page_up   scroll_page_up
    map ctrl+shift+page_down scroll_page_down
    map ctrl+shift+home      scroll_home
    map ctrl+shift+end       scroll_end
    map ctrl+shift+h         show_scrollback

    # Gestión de ventanas
    map alt+n               new_window_with_cwd      #Abre una nueva ventana en el directorio actual
    #map alt+n               new_os_window           #Abre una nueva ventana en el directorio $HOME
    map alt+w               close_window
    map ctrl+shift+enter    launch --location=hsplit
    map ctrl+shift+s        launch --location=vsplit
    map ctrl+shift+]        next_window
    map ctrl+shift+[        previous_window
    map ctrl+shift+f        move_window_forward
    map ctrl+shift+b        move_window_backward
    map ctrl+shift+`        move_window_to_top
    map ctrl+shift+1        first_window
    map ctrl+shift+2        second_window
    map ctrl+shift+3        third_window
    map ctrl+shift+4        fourth_window
    map ctrl+shift+5        fifth_window
    map ctrl+shift+6        sixth_window
    map ctrl+shift+7        seventh_window
    map ctrl+shift+8        eighth_window
    map ctrl+shift+9        ninth_window
    map ctrl+shift+0        tenth_window

    # Gestión de pestañas
    map ctrl+shift+right    next_tab
    map ctrl+shift+left     previous_tab
    map ctrl+shift+t        new_tab
    map ctrl+shift+q        close_tab
    map ctrl+shift+l        next_layout
    map ctrl+shift+.        move_tab_forward
    map ctrl+shift+,        move_tab_backward

    # Misceláneos
    map ctrl+shift+up      increase_font_size
    map ctrl+shift+down    decrease_font_size
    map ctrl+shift+backspace restore_font_size
```

</details>
</details>

<details>

<summary><strong>🇼 WezTerm</strong></summary>

<div style="margin-left: 20px;">

<details>

<summary>¿Cómo habilito WezTerm?</summary>

Edita el archivo `/ddubsOS/modules/home/wezterm.nix`. Cambia `enable = false` a
`enable = true;`. Guarda el archivo y reconstruye zaneyos con el comando `fr`.

```
{pkgs, ...}: {
  programs.wezterm = {
    enable = false;
    package = pkgs.wezterm;
  };
```

</details>

<details>
 <summary>¿Cuáles son los atajos de teclado de WezTerm y cómo puedo cambiarlos?</summary>

Los atajos de WezTerm se configuran en `~/ddubsOS/modules/home/wezterm.nix`

Los predeterminados son:

```text
ALT es la tecla META definida para WezTerm
  -- Gestión de pestañas
ALT + t                 Abrir nueva pestaña
ALT + w                 Cerrar pestaña actual
ALT + n                 Mover a la siguiente pestaña
ALT + p                 Mover a la pestaña anterior 
  -- Gestión de paneles
ALT + v                 Crear división vertical
ALT + h                 Crear división horizontal
ALT + q                 Cerrar panel actual
   -- Navegación de paneles (moverse entre paneles con ALT + Flechas)
ALT + Flecha Izquierda  Mover al panel -- Izquierda
ALT + Flecha Derecha    Mover al panel -- Derecha
ALT + Flecha Abajo      Mover al panel -- Abajo
ALT + Flecha Arriba     Mover al panel -- Arriba
```

</details>
</div>
</details>

<details>
<summary><strong>👻 Ghostty</strong></summary>

<div style="margin-left: 20px;">

<details>
<summary>¿Cómo habilito la terminal ghostty?</summary>

1. Edita el archivo `~/ddubsOS/modules/home/ghostty.nix`.
2. Cambia `enable = true;`
3. Ejecuta el alias de comando `fr` para crear una nueva generación.

</details>

<details>

<summary>¿Cómo cambio el tema de ghostty?</summary>

1. Edita el archivo `~/ddubsOS/modules/home/ghostty.nix`.
2. Hay varios temas de ejemplo incluidos pero comentados.

```text
#theme = Aura
theme = Dracula
#theme = Aardvark Blue
#theme = GruvboxDarkHard
```

3. Comenta `Dracula` y descomenta uno de los otros o agrega uno de los muchos
   temas de ghostty.

</details>

<details>
<summary>¿Cuáles son los atajos de teclado predeterminados de ghostty?</summary>

```text
 # atajos de teclado
    keybind = alt+s>r=reload_config
    keybind = alt+s>x=close_surface

    keybind = alt+s>n=new_window

    # pestañas
    keybind = alt+s>c=new_tab
    keybind = alt+s>shift+l=next_tab
    keybind = alt+s>shift+h=previous_tab
    keybind = alt+s>comma=move_tab:-1
    keybind = alt+s>period=move_tab:1

    # cambio rápido de pestaña
    keybind = alt+s>1=goto_tab:1
    keybind = alt+s>2=goto_tab:2
    keybind = alt+s>3=goto_tab:3
    keybind = alt+s>4=goto_tab:4
    keybind = alt+s>5=goto_tab:5
    keybind = alt+s>6=goto_tab:6
    keybind = alt+s>7=goto_tab:7
    keybind = alt+s>8=goto_tab:8
    keybind = alt+s>9=goto_tab:9

    # división
    keybind = alt+s>\=new_split:right
    keybind = alt+s>-=new_split:down

    keybind = alt+s>j=goto_split:bottom
    keybind = alt+s>k=goto_split:top
    keybind = alt+s>h=goto_split:left
    keybind = alt+s>l=goto_split:right

    keybind = alt+s>z=toggle_split_zoom

    keybind = alt+s>e=equalize_splits
```

</details>
</div>
</details>

## 🪧 Temas generales relacionados con NixOS

<details>
<summary><strong>❄ ¿Qué son los Flakes en NixOS?</strong></summary>

<div style="margin-left: 20px;">

**Flakes** son una característica del gestor de paquetes Nix que simplifica y
estandariza cómo se gestionan las configuraciones, dependencias y paquetes. Si
estás familiarizado con herramientas como `package.json` en JavaScript o
`Cargo.toml` en Rust, los flakes cumplen un propósito similar en el ecosistema
de Nix.

#### Características Clave de los Flakes:

1. **Fijar Dependencias**:
   - Los Flakes bloquean las versiones de las dependencias en un archivo
     `flake.lock`, asegurando la reproducibilidad en todos los sistemas.

2. **Estandarizar Configuraciones**:
   - Usan un archivo `flake.nix` para definir cómo construir, ejecutar o
     desplegar un proyecto o sistema, haciendo que las configuraciones sean más
     predecibles.

3. **Mejorar la Usabilidad**:
   - Los Flakes simplifican el intercambio y la reutilización de configuraciones
     en diferentes sistemas o proyectos al proporcionar una estructura
     consistente.

En esencia, los flakes ayudan a gestionar las configuraciones de NixOS o los
proyectos basados en Nix de una manera más portátil y fiable.

</div>

</details>

<details>
<summary><strong>🏡 ¿Qué es NixOS Home Manager?</strong></summary>

**Home Manager** es una herramienta poderosa en el ecosistema de Nix que te
permite gestionar de forma declarativa las configuraciones y entornos
específicos del usuario. Con Home Manager, puedes agilizar la configuración de
dotfiles, ajustes de shell, aplicaciones y paquetes del sistema para tu perfil
de usuario.

### Características Clave de Home Manager:

1. **Configuración Declarativa**:
   - Define todos tus ajustes y preferencias en un único archivo `home.nix`, lo
     que facilita el seguimiento, el intercambio y la replicación de tu
     configuración.

2. **Soporte Multidistribución**:
   - Home Manager funciona no solo en NixOS, sino también en otras
     distribuciones de Linux y macOS, lo que te permite estandarizar las
     configuraciones en todos los dispositivos.

3. **Gestión del Entorno de Usuario**:
   - Gestiona aplicaciones, variables de entorno, configuraciones de shell y
     más, todo aislado en tu perfil de usuario.

### ¿Por Qué Usar Home Manager?

Home Manager simplifica la gestión del sistema al ofrecer consistencia,
reproducibilidad y portabilidad. Ya sea que estés personalizando tu entorno de
desarrollo o compartiendo configuraciones entre máquinas, proporciona una forma
eficiente de adaptar tu experiencia de usuario.

</details>

<details>
<summary><strong>🏭 ¿Qué son las Compilaciones Atómicas?</strong></summary>

Las **compilaciones atómicas** en NixOS aseguran que cualquier cambio en el
sistema (como instalar software o actualizar la configuración) se aplique de una
manera segura y a prueba de fallos. Esto significa que una actualización del
sistema es completamente exitosa o no tiene ningún efecto, eliminando el riesgo
de un estado del sistema parcialmente aplicado o roto.

### Cómo Funcionan las Compilaciones Atómicas:

1. **Generación Inmutable del Sistema**:
   - Cada cambio de configuración crea una nueva "generación" del sistema,
     mientras que las anteriores permanecen intactas. Puedes volver fácilmente a
     una generación anterior si algo sale mal.

2. **Comportamiento Similar a una Transacción**:
   - Al igual que las transacciones de bases de datos, los cambios se aplican de
     forma atómica: o tienen éxito y se convierten en el nuevo sistema activo, o
     fallan y dejan el sistema actual sin cambios.

3. **Reversiones sin Problemas**:
   - En caso de errores o problemas, puedes reiniciar y seleccionar una
     generación anterior del sistema desde el menú de arranque para volver a un
     estado funcional.

### Beneficios de las Compilaciones Atómicas:

- **Fiabilidad**: Tu sistema siempre está en un estado consistente, incluso si
  un cambio de configuración falla.
- **Reproducibilidad**: La misma configuración siempre producirá el mismo estado
  del sistema, lo que facilita la depuración o la replicación.
- **Facilidad de Reversión**: Volver a una configuración funcional es tan simple
  como reiniciar y seleccionar la generación anterior.

### ¿Por Qué NixOS Usa Compilaciones Atómicas?

Esta característica es una piedra angular de la filosofía de diseño declarativa
y reproducible de NixOS, asegurando que la gestión del sistema sea predecible y
sin estrés.

</details>

<details>
<summary><strong>❓ Soy nuevo en NIXOS, ¿dónde puedo obtener más información?</strong></summary>

- [Guía de Configuración de NIXOS](https://www.youtube.com/watch?v=AGVXJ-TIv3Y&t=34s)
- [Canal de YouTube de VIMJOYER](https://www.youtube.com/@vimjoyer/videos)
- [Canal de YouTube de Librephoenix](https://www.youtube.com/@librephoenix)
- [Serie de 8 Videos sobre NIXOS](https://www.youtube.com/watch?v=QKoQ1gKJY5A&list=PL-saUBvIJzOkjAw_vOac75v-x6EzNzZq-)
- [Gran guía para NixOS y Flakes](https://nixos-and-flakes.thiscute.world/preface)

</details>

<details>
<summary><strong>🏤 ¿Dónde puedo obtener información sobre el uso de repositorios GIT?</strong></summary>

- [Gestión de la configuración de NIXOS con GIT](https://www.youtube.com/watch?v=20BN4gqHwaQ)
- [GIT para principiantes](https://www.youtube.com/watch?v=K6Q31YkorUE)
- [Cómo funciona GIT](https://www.youtube.com/watch?v=e9lnsKot_SQ)
- [Video detallado de 1 hora sobre GIT](https://www.youtube.com/watch?v=S7XpTAnSDL4&t=123s)

</details>
