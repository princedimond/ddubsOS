[Español](./FAQ.es.md) | [English](./FAQ.md)

# 💬 Preguntas Frecuentes de ddubsOS v2.7.1

- **Fecha:** 5-Deciembre-2025

---

## 📖 Tabla de Contenidos

### [🔧 Sistema Principal](#-sistema-principal)

- [Construcción por Host vs Perfil](#construcción-por-host-vs-perfil)
- [Gestión de Hosts con zcli](#gestión-de-hosts-con-zcli)
- [Migración a Objetivos Basados en Host](#migración-a-objetivos-basados-en-host)
- [Banderas del Instalador](#banderas-del-instalador)
- [Utilidad de Línea de Comandos ZCLI](#utilidad-de-línea-de-comandos-zcli)

### [🪟 Entorno Hyprland](#-entorno-hyprland)

- [Atajos de Teclado y Ayuda Rápida](#atajos-de-teclado-y-ayuda-rápida)
- [Aplicaciones de Selección Rápida](#aplicaciones-de-selección-rápida-qs-keybinds-qs-cheatsheets-qs-docs)
- [Lanzamiento de Aplicaciones](#lanzamiento-de-aplicaciones)
- [Gestión de Ventanas](#gestión-de-ventanas)
- [Espacios de Trabajo y Navegación](#espacios-de-trabajo-y-navegación)
- [Diseños (Master vs Dwindle)](#diseños-master-vs-dwindle)

### [⚙️ Configuración y Ajustes](#-configuración-y-ajustes)

- [Prompt Starship](#prompt-starship)
- [Configuración de Waybar y Panel](#configuración-de-waybar-y-panel)
- [Opciones de Editor (VSCode/Helix)](#opciones-de-editor-vscodhelix)
- [Opciones de Terminal](#opciones-de-terminal)
- [Entornos de Escritorio](#entornos-de-escritorio)
- [Zona Horaria y Configuración del Sistema](#zona-horaria-y-configuración-del-sistema)
- [Configuración de Monitores](#configuración-de-monitores)
- [Gestión de Aplicaciones y Paquetes](#gestión-de-aplicaciones-y-paquetes)
- [Configuración del Kernel](#configuración-del-kernel)
- [Mantenimiento del Sistema](#mantenimiento-del-sistema)

### [🤖 Infraestructura de IA y LLM](#-infraestructura-de-ia-y-llm)

- [Configuración de OpenWebUI + Ollama](#configuración-de-openwebui--ollama)
- [Recomendaciones de Modelos](#recomendaciones-de-modelos)
- [Gestión y Solución de Problemas](#gestión-y-solución-de-problemas)

### [🎨 Temas y Apariencia](#-temas-y-apariencia)

- [Configuración de Stylix](#configuración-de-stylix)
- [Gestión de Fondos de Pantalla](#gestión-de-fondos-de-pantalla)

### [💻 Configuración de Terminal](#-configuración-de-terminal)

- [Terminal Kitty](#terminal-kitty)
- [Terminal WezTerm](#terminal-wezterm)
- [Terminal Ghostty](#terminal-ghostty)
- [Gestor de Archivos Yazi](#gestor-de-archivos-yazi)

### [🔄 Actualizaciones y Mantenimiento del Sistema](#-actualizaciones-y-mantenimiento-del-sistema)

- [Actualizar ddubsOS](#actualizar-ddubsos)

### [📋 Información del Proyecto](#-información-del-proyecto)

- [Acerca de ddubsOS](#acerca-de-ddubsos)
- [Estructura del Proyecto](#estructura-del-proyecto)

### [❄️ Fundamentos de NixOS](#-fundamentos-de-nixos)

- [Comprender Flakes](#comprender-flakes)
- [Home Manager](#home-manager)
- [Construcciones Atómicas](#construcciones-atómicas)
- [Recursos de Aprendizaje](#recursos-de-aprendizaje)

---

## 🔧 Sistema Principal

### Construcción por Host vs Perfil

**Por host** (nuevo enfoque preferido):

```bash
sudo nixos-rebuild switch --flake .#<host>
```

**Por perfil** (legacy, aún disponible):

```bash
sudo nixos-rebuild switch --flake .#<profile>  # amd | intel | nvidia | nvidia-laptop | vm
```

📖 Ver también: `docs/upgrade-from-2.4.md`

### Gestión de Hosts con zcli

| Comando                             | Descripción                         |
| ----------------------------------- | ----------------------------------- |
| `zcli add-host <name> [profile]`    | Agregar nueva configuración de host |
| `zcli del-host <name>`              | Eliminar configuración de host      |
| `zcli rename-host <old> <new>`      | Renombrar host existente            |
| `zcli hostname set <name>`          | Establecer solo host en flake       |
| `zcli update-host [name] [profile]` | Actualizar tanto host como perfil   |

### Migración a Objetivos Basados en Host

Ejemplo: migrar una VM de objetivos de perfil legacy al nuevo enfoque basado en
host

1. **Cambiar a la rama refactor**:

   ```bash
   git switch ddubos-refactor
   ```

   ⚠️ **Importante (usuarios v2.4)**: Primera reconstrucción con nixos-rebuild,
   no zcli

   ```bash
   sudo nixos-rebuild switch --flake .#vm  # Instalar zcli actualizado primero
   ```

2. **Asegurar que existe la carpeta host**:

   ```bash
   zcli add-host ddubsos-vm vm
   ```

   - Editar `hosts/ddubsos-vm/variables.nix` según sea necesario

3. **Apuntar flake al nuevo host**:

   ```bash
   zcli update-host ddubsos-vm vm
   ```

4. **Reconstruir con objetivo host**:
   ```bash
   sudo nixos-rebuild switch --flake .#ddubsos-vm
   ```

> **Nota**: Hyprpanel es el panel por defecto. El primer inicio de sesión tarda
> 30-60 segundos en cargar.\
> **SUPER + Enter** para terminal, **SUPER + D** para menú de aplicaciones.

### Banderas del Instalador

```bash
./install-ddubsos.sh --host <name> --profile <gpu> --build-host --non-interactive
```

- `--host/--profile`: Pre-seleccionar valores
- `--build-host`: Construir objetivo `.#<host>`
- `--non-interactive`: Aceptar valores por defecto sin prompts

### Utilidad de Línea de Comandos ZCLI

La utilidad `zcli` (v1.2.0) simplifica la gestión de ddubsOS.

#### 🚀 Comandos Principales

| Comando        | Descripción                                            |
| -------------- | ------------------------------------------------------ |
| `rebuild`      | Reconstruir configuración del sistema NixOS            |
| `rebuild-boot` | Reconstruir y activar en próximo reinicio (más seguro) |
| `update`       | Actualizar flake y reconstruir sistema                 |
| `cleanup`      | Limpiar generaciones antiguas del sistema              |
| `list-gens`    | Listar generaciones de usuario y sistema               |
| `trim`         | Recortar sistemas de archivos (rendimiento SSD)        |
| `diag`         | Crear reporte de diagnóstico (`~/diag.txt`)            |

#### 🏠 Gestión de Hosts

- `update-host`: Auto-establecer host y perfil con detección de GPU
- **Perfiles de GPU**: `amd`, `intel`, `nvidia`, `nvidia-laptop`, `vm`

#### ⚙️ Opciones Avanzadas (v1.2.0)

| Bandera         | Descripción                               |
| --------------- | ----------------------------------------- |
| `--dry, -n`     | Mostrar qué se haría (ejecución simulada) |
| `--ask, -a`     | Pedir confirmación                        |
| `--cores N`     | Limitar construcción a N núcleos de CPU   |
| `--verbose, -v` | Salida detallada                          |
| `--no-nom`      | Deshabilitar nix-output-monitor           |
| `--no-stage`    | Omitir prompt de staging                  |
| `--stage-all`   | Auto-stage todos los archivos             |

#### 🆕 Nuevo en v1.1.0: Staging Interactivo

- Los comandos de reconstrucción listan archivos sin seguimiento/sin stage
- Elegir números o 'all' para hacer stage, o presionar Enter para saltar
- Nuevo comando: `zcli stage [--all]`

#### 🔍 Gestión de Configuración (v1.0.4)

```bash
zcli settings set <attr> <value> [--dry-run]
zcli settings --list-browsers
zcli settings --list-terminals
```

#### 📊 Servidor Glances

| Comando           | Descripción                   |
| ----------------- | ----------------------------- |
| `glances start`   | Iniciar servidor de monitoreo |
| `glances stop`    | Detener servidor de monitoreo |
| `glances restart` | Reiniciar servidor            |
| `glances status`  | Mostrar estado y URLs         |
| `glances logs`    | Mostrar logs del servidor     |

#### Ejemplo de Uso

```bash
zcli rebuild-boot --cores 4
zcli rebuild --verbose --ask
zcli update
```

---

## 🪟 Entorno Hyprland

### Atajos de Teclado y Ayuda Rápida

**Visor Interactivo de Atajos de Teclado**:

- **SUPER + SHIFT + K** → Abre `qs-keybinds` con búsqueda en tiempo real
- Navegar atajos de teclado para Hyprland, Emacs, Kitty, WezTerm, Yazi
- Hacer clic en cualquier atajo para copiar al portapapeles
- También accesible a través del ícono "keys" en waybar

### Aplicaciones de Selección Rápida (qs-keybinds, qs-cheatsheets, qs-docs)

ddubsOS incluye tres poderosas aplicaciones Qt6 QML:

#### 🔑 qs-keybinds (SUPER + SHIFT + K)

- **Visor interactivo de atajos de teclado** con búsqueda en tiempo real
- **Soporte multi-modo**: Hyprland, Emacs, Kitty, WezTerm, Yazi
- **Funcionalidad de copiado**: Hacer clic para copiar con notificación
- **Filtrado por categorías**: Organización visual con insignias temáticas

#### 📚 qs-cheatsheets (SUPER + SHIFT + C)

- **Navegador completo de hojas de referencia**
- **Soporte multi-idioma**: Inglés y Español
- **Categorías**: emacs, hyprland, kitty, wezterm, yazi, nixos
- **Visualización de contenido en tiempo real** con búsqueda

#### 📖 qs-docs (SUPER + SHIFT + D)

- **Visor de documentación técnica**
- **Navegación inteligente**: Lee desde `~/ddubsos/docs/`
- **Guías de arquitectura**: Documentación del sistema
- **Multi-idioma**: Inglés y Español

Todas las aplicaciones tienen interfaz Qt6 QML moderna, ventanas flotantes y
atajos de teclado.

### Lanzamiento de Aplicaciones

| Atajo de Teclado         | Acción                             |
| ------------------------ | ---------------------------------- |
| `SUPER + Return`         | Lanzar terminal kitty              |
| `SUPER + Shift + Return` | Lanzar rofi-launcher               |
| `SUPER + D`              | Abrir Discord                      |
| `SUPER + W`              | Lanzar Google Chrome               |
| `SUPER + Y`              | Abrir gestor de archivos yazi      |
| `SUPER + S`              | Tomar captura de pantalla          |
| `SUPER + V`              | Mostrar historial del portapapeles |
| `SUPER + T`              | Alternar terminal pypr             |
| `SUPER + M`              | Abrir pavucontrol                  |

### Gestión de Ventanas

| Atajo de Teclado    | Acción                        |
| ------------------- | ----------------------------- |
| `SUPER + Q`         | Cerrar ventana activa         |
| `SUPER + F`         | Alternar pantalla completa    |
| `SUPER + Shift + F` | Alternar modo flotante        |
| `SUPER + P`         | Alternar pseudo tiling        |
| `SUPER + SPACE`     | Hacer flotante ventana actual |

### Espacios de Trabajo y Navegación

**Espacios de Trabajo**:

- `SUPER + 1-10` → Cambiar a espacio de trabajo 1-10
- `SUPER + Shift + 1-10` → Mover ventana a espacio de trabajo 1-10
- `SUPER + Control + ←/→` → Cambiar espacio de trabajo adelante/atrás

**Movimiento de Foco**:

- `SUPER + ←/→/↑/↓` o `SUPER + H/L/K/J` → Mover foco

**Movimiento de Ventana**:

- `SUPER + Shift + ←/→/↑/↓` o `SUPER + Shift + H/L/K/J` → Mover ventana

**Ciclo de Ventanas**:

- `Alt + Tab` → Ciclar a siguiente ventana

### Diseños (Master vs Dwindle)

**Diseño Master**:

- Divide el espacio de trabajo en **área master** (ventana principal) y **área
  de pila** (otras ventanas)
- Ideal para enfocar en una ventana principal única

**Diseño Dwindle**:

- Tiling basado en árbol binario con divisiones dinámicas
- Alterna entre divisiones horizontales y verticales
- Distribución de espacio más dinámica

Verificar diseño actual: `hyprctl getoption general:layout`

---

## ⚙️ Configuración y Ajustes

### Prompt Starship

1. Editar `~/ddubsOS/hosts/HOSTNAME/variables.nix`
2. Encontrar línea `starshipChoice`
3. Elegir de las opciones disponibles:

```nix
# Prompts Starship disponibles
starshipChoice = ../../modules/home/cli/starship.nix;        # por defecto
#starshipChoice = ../../modules/home/cli/starship-1.nix;
#starshipChoice = ../../modules/home/cli/starship-rbmcg.nix;
```

4. Ejecutar `zcli rebuild`

### Configuración de Waybar y Panel

#### Cambiar Entre HyprPanel y Waybar

1. Editar `~/ddubsOS/hosts/HOSTNAME/variables.nix`
2. Cambiar `panelChoice`:

```nix
# Elección de Panel
panelChoice = "hyprpanel";  # Panel moderno con características avanzadas
# o
panelChoice = "waybar";     # Barra tradicional con módulos personalizables
```

#### Selección de Tema Waybar

```nix
# Temas Waybar disponibles
waybarChoice = ../../modules/home/waybar/waybar-ddubs.nix;     # por defecto
#waybarChoice = ../../modules/home/waybar/waybar-simple.nix;
#waybarChoice = ../../modules/home/waybar/waybar-curved.nix;
#waybarChoice = ../../modules/home/waybar/waybar-nerodyke.nix;
```

### Opciones de Editor (VSCode/Helix)

Habilitar editores en `~/ddubsOS/hosts/HOSTNAME/variables.nix`:

```nix
# Opciones de Editor
enableEvilhelix = true;   # Helix con atajos estilo Vim
enableVscode = false;     # Visual Studio Code
```

**Notas**:

- Ambos deshabilitados por defecto para sistema mínimo
- Doom Emacs y Neovim siempre disponibles

### Opciones de Terminal

Habilitar terminales opcionales:

```nix
# Opciones de Terminal
enableAlacritty = true;   # Terminal Rust acelerado por GPU
enableTmux = false;       # Multiplexor de terminal
enablePtyxis = false;     # Terminal GNOME moderno
```

**Terminales Principales (Siempre Disponibles)**:

- **Ghostty**: Terminal moderno con excelente rendimiento
- **Kitty**: Terminal basado en GPU con gráficos avanzados
- **Foot**: Terminal Wayland ligero
- **WezTerm**: Terminal multiplataforma acelerado por GPU

### Entornos de Escritorio

Habilitar DEs/WMs opcionales:

```nix
# Opciones de Entorno de Escritorio
gnomeEnable = false;      # Escritorio GNOME completo
bspwmEnable = true;       # BSPWM tiling WM
dwmEnable = false;        # DWM suckless WM
wayfireEnable = false;    # Compositor Wayland Wayfire
```

**Notas**:

- Todos deshabilitados por defecto (Hyprland es principal)
- Habilitar solo uno a la vez para evitar conflictos

### Zona Horaria y Configuración del Sistema

Editar `~/ddubsOS/modules/core/system.nix`:

```nix
time.timeZone = "America/New_York";  # Cambiar a tu zona horaria
```

### Configuración de Monitores

Editar `~/ddubsOS/hosts/<HOSTNAME>/variables.nix` y usar la estructura
`hyprMonitorsV2`:

**Monitor Único**:

```nix
hyprMonitorsV2 = [
  {
    output = "eDP-1";
    mode = "1920x1080@60";
    position = "0x0";
    scale = 1;
    enabled = true;
  }
];
```

**Monitores Duales**:

```nix
hyprMonitorsV2 = [
  {
    output = "DP-1";
    mode = "2560x1440@144";
    position = "0x0";
    scale = 1;
    enabled = true;
  }
  {
    output = "HDMI-A-1";
    mode = "1920x1080@60";
    position = "2560x0";  # a la derecha de DP-1
    scale = 1.25;
    enabled = true;
  }
];
```

**Descubrimiento**: Ejecutar `hyprctl monitors` para listar salidas y modos
disponibles.

### Gestión de Aplicaciones y Paquetes

#### Aplicaciones Globales

Editar `~/ddubsOS/modules/core/packages.nix`:

```nix
environment.systemPackages = with pkgs; [
  # paquetes existentes...
  ### Mis Aplicaciones ###
  bottom
  lazygit
  mission-center
  # agregar tus paquetes aquí
];
```

#### Aplicaciones Específicas del Host

Editar `~/ddubsOS/hosts/<HOSTNAME>/host-packages.nix`:

```nix
{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    audacity
    discord
    obs-studio
    # paquetes específicos del host
  ];
}
```

#### Gestión de Flatpak

1. Editar `modules/core/flatpak.nix` bajo `services.flatpak.packages`
2. Agregar/remover IDs de aplicaciones Flatpak de flathub.org
3. Ejecutar `zcli rebuild`
4. Ver guía detallada: `docs/HOWTO-Install-Remove-Flatpaks.md`

### Configuración del Kernel

Sobrescribir kernel en `~/ddubsOS/hosts/HOSTNAME/hardware.nix`:

```nix
boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"];
boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_12;  # Ejemplo: kernel 6.12
boot.kernelModules = ["kvm-intel"];
```

**Tipos de Kernel Disponibles**:

- `linuxPackages` - Kernel LTS estable por defecto (6.12.x en 25.05)
- `linuxPackages_latest` - Kernel mainline más reciente
- `linuxPackages_zen` - Optimizado para rendimiento en escritorio/gaming
- `linuxPackages_hardened` - Enfocado en seguridad con parches de endurecimiento
- `linuxPackages_rt` - Kernel en tiempo real para aplicaciones de baja latencia

### Mantenimiento del Sistema

**Aplicar Cambios de Configuración**:

```bash
zcli rebuild  # Aplicar cambios (ejecutar git add . si creaste archivos nuevos)
```

**Actualizar Paquetes**:

```bash
zcli update  # Actualizar inputs del flake y reconstruir
```

**Limpiar Generaciones Antiguas**:

```bash
zcli cleanup  # Remover generaciones antiguas del sistema
```

**Habilitar Monitoreo Glances**:

```nix
# En variables.nix
enableGlances = true;  # Acceder en http://localhost:61210
```

---

## 🤖 Infraestructura de IA y LLM

### Configuración de OpenWebUI + Ollama

**Disponible solo en sistemas NVIDIA** - Proporciona inferencia de modelos de
lenguaje local con interfaz web.

#### Inicio Rápido

1. **Acceder Interfaz Web**: `http://localhost:3000`
2. **Descargar Primer Modelo**: Probar `llama3.2:1b` para pruebas ligeras
3. **Línea de Comandos**: Usar `ollama-webui-manager models`

#### Comandos de Gestión

```bash
# Control de Servicio
ollama-webui-manager start/stop/restart
ollama-webui-manager status

# Monitoreo
ollama-webui-manager logs [ollama|webui]

# Modelos
ollama-webui-manager models
ollama-webui-manager test
```

#### Puntos de Acceso

- **Interfaz Web**: `http://localhost:3000` - Interfaz de chat moderna
- **API**: `http://localhost:11434` - Acceso directo a API para desarrollo

### Recomendaciones de Modelos

#### Para GPUs de 4GB (GTX 1650, RTX 3050, etc.)

| Modelo        | Tamaño | Caso de Uso                   |
| ------------- | ------ | ----------------------------- |
| `llama3.2:1b` | ~1GB   | Chat rápido y ligero          |
| `llama3.2:3b` | ~3GB   | Mejor calidad, aún rápido     |
| `phi3:mini`   | ~2GB   | Modelo eficiente de Microsoft |
| `qwen2:1.5b`  | ~1GB   | Modelo ligero de Alibaba      |
| `gemma:2b`    | ~1.4GB | Pequeño pero capaz de Google  |

#### Para GPUs de 6GB+ (GTX 1660, RTX 3060, RTX 4060, etc.)

| Modelo           | Tamaño | Caso de Uso                          |
| ---------------- | ------ | ------------------------------------ |
| `mistral:7b`     | ~4.1GB | Propósito general, alta calidad      |
| `codellama:7b`   | ~3.8GB | Generación de código y programación  |
| `neural-chat:7b` | ~3.8GB | Modelo conversacional de Intel       |
| `vicuna:7b`      | ~3.8GB | Fuertes habilidades conversacionales |

### Gestión y Solución de Problemas

**Ubicaciones de Datos**:

- Modelos: `/var/lib/openwebui-ollama/ollama/`
- Datos OpenWebUI: `/var/lib/openwebui-ollama/openwebui/`

**Consejos de Rendimiento**:

- Comenzar con modelos más pequeños (parámetros 1B-3B)
- Monitorear VRAM con `nvidia-smi`
- Dejar 1-2GB VRAM libre para overhead
- Los modelos cuantificados (-q4, -q8) usan menos VRAM

**Solución de Problemas**:

```bash
ollama-webui-manager status  # Verificar estado del servicio
ollama-webui-manager logs    # Ver logs
ollama-webui-manager test    # Probar conectividad
```

---

## 🎨 Temas y Apariencia

### Configuración de Stylix

#### Habilitar/Deshabilitar Stylix

**Para Habilitar** (tematización basada en imágenes):

1. Editar `~/ddubsOS/modules/core/stylix.nix`
2. Comentar la sección `base16Scheme`
3. Seleccionar tu imagen para la paleta de colores
4. Ejecutar `zcli rebuild`

**Para Deshabilitar** (colores manuales):

1. Descomentar la sección `base16Scheme` en el mismo archivo
2. Ejecutar `zcli rebuild`

#### Cambiar Imagen de Stylix

Editar `~/ddubsOS/hosts/HOSTNAME/variables.nix`:

```nix
# Establecer Imagen de Stylix
stylixImage = ../../wallpapers/TuFondoDePantalla.jpg;
```

Los fondos de pantalla se almacenan en `~/ddubsOS/wallpapers/`

### Gestión de Fondos de Pantalla

#### Agregar Fondos de Pantalla

- Copiar nuevos fondos de pantalla al directorio `~/ddubsOS/wallpapers/`

#### Cambiar Fondo

- **SUPER + ALT + W** → Abrir selector de fondos de pantalla
- Usar `waypaper` para opciones adicionales

#### Cambios Automáticos de Fondo de Pantalla

1. Editar `~/ddubsOS/modules/home/hyprland/config.nix`
2. Comentar línea de fondo de pantalla estático
3. Agregar wallsetter:

```nix
exec-once = [
  # ... otros elementos de inicio ...
  #"sleep 1.5 && swww img /path/to/static/wallpaper.jpg"
  "sleep 1 && wallsetter"  # Habilitar rotación automática de fondos
];
```

#### Cambiar Intervalo de Rotación

Editar `~/ddubsOS/modules/home/scripts/wallsetter` y modificar el valor
`TIMEOUT =` (en segundos).

---

## 💻 Configuración de Terminal

### Terminal Kitty

#### Corregir Problemas del Cursor

Si el cursor salta:

1. Editar `~/ddubsOS/modules/home/kitty.nix`
2. Cambiar `cursor_trail 1` a `cursor_trail 0`
3. Ejecutar `zcli rebuild`

#### Atajos de Teclado

**Portapapeles**:

- `Ctrl+Shift+V` - Pegar desde selección
- `Shift+Insert` - Pegar desde selección

**Gestión de Ventanas**:

- `Alt+N` - Nueva ventana en directorio actual
- `Alt+W` - Cerrar ventana
- `Ctrl+Shift+Enter` - División horizontal
- `Ctrl+Shift+S` - División vertical

**Pestañas**:

- `Ctrl+Shift+T` - Nueva pestaña
- `Ctrl+Shift+Q` - Cerrar pestaña
- `Ctrl+Shift+Right/Left` - Siguiente/Anterior pestaña

### Terminal WezTerm

#### Habilitar WezTerm

Editar `~/ddubsOS/modules/home/wezterm.nix`:

```nix
{pkgs, ...}: {
  programs.wezterm = {
    enable = true;  # Cambiar de false
    package = pkgs.wezterm;
  };
}
```

#### Atajos de Teclado (ALT es tecla META)

**Gestión de Pestañas**:

- `ALT + T` - Abrir nueva pestaña
- `ALT + W` - Cerrar pestaña actual
- `ALT + N/P` - Siguiente/Anterior pestaña

**Gestión de Paneles**:

- `ALT + V` - División vertical
- `ALT + H` - División horizontal
- `ALT + Q` - Cerrar panel
- `ALT + Teclas de Flecha` - Navegar paneles

### Terminal Ghostty

#### Habilitar Ghostty

1. Editar `~/ddubsOS/modules/home/ghostty.nix`
2. Establecer `enable = true;`
3. Ejecutar `zcli rebuild`

#### Cambiar Tema

Temas disponibles en el mismo archivo:

```
#theme = Aura
theme = Dracula         # por defecto
#theme = Aardvark Blue
#theme = GruvboxDarkHard
```

#### Atajos de Teclado

**Gestión de Ventanas**:

- `ALT+S>N` - Nueva ventana
- `ALT+S>X` - Cerrar superficie

**Pestañas**:

- `ALT+S>C` - Nueva pestaña
- `ALT+S>1-9` - Ir a pestaña 1-9
- `ALT+S>Shift+H/L` - Anterior/Siguiente pestaña

**Divisiones**:

- `ALT+S>\` - División vertical
- `ALT+S>-` - División horizontal
- `ALT+S>H/J/K/L` - Navegar divisiones

### Gestor de Archivos Yazi

#### Configuración

- Configuración principal: `~/ddubsos/modules/home/yazi.nix`
- Usa movimientos y atajos estilo VIM
- Mapa de teclas: `~/ddubsos/modules/home/yazi/keymap.toml`

#### Corregir Error de Inicio de Yazi

Si ves errores de runtime de Lua:

```bash
ya pack -u  # Actualizar paquetes
```

Luego reiniciar yazi.

---

## 🔄 Actualizaciones y Mantenimiento del Sistema

### Actualizar ddubsOS

**Para versiones v1.0+**:

1. **Respaldar configuración actual**:

   ```bash
   cp -rpv ~/ddubsOS ~/Backup-ddubsOS
   ```

2. **Obtener actualizaciones**:

   ```bash
   cd ~/ddubsOS
   git stash && git pull
   ```

3. **Restaurar configuraciones de host**:

   ```bash
   cp -rpv ~/Backup-ddubsOS/hosts/HOSTNAME ~/ddubsOS/hosts/
   ```

4. **Agregar archivos y reconstruir**:

   ```bash
   git add .
   zcli rebuild
   ```

5. **Fusionar cambios personalizados**: Fusionar manualmente cualquier
   personalización que hayas hecho a:
   - Atajos de teclado de Hyprland
   - Configuraciones de Waybar
   - Paquetes adicionales en `modules/packages.nix`

**Importante**: No copies el host `default` del respaldo - usa la plantilla
actualizada para nuevos hosts.

---

## 📋 Información del Proyecto

### Acerca de ddubsOS

ddubsOS es una configuración personal de NixOS que evolucionó de ZaneyOS:

- 🎯 **Propósito**: Proporcionar una configuración NixOS funcional para uso
  diario
- 🔧 **Características**: Gaming (Steam), desarrollo, entorno de escritorio
  moderno
- 🤝 **Filosofía**: Compartir configuraciones "tal como están" para que otros
  las bifurquen y personalicen
- 🚫 **No es una distro**: No hay planes para ISO de instalación - es una
  plantilla de configuración

**Punto Clave**: Bifurca ddubsOS y hazlo tuyo. Comparte mejoras de vuelta a la
comunidad.

### Estructura del Proyecto

```
📂 ~/ddubsOS/
├── 📁 cheatsheets/          # Guías de referencia rápida
├── 📁 docs/                 # Documentación del proyecto
├── 📁 features/             # Módulos de características zcli
├── 📁 hosts/                # Configuraciones por host
│   ├── 📁 default/          # Plantilla para nuevos hosts
│   ├── 📁 asus/             # Configuraciones de host de ejemplo
│   └── 📁 ...               # Otras configuraciones de host
├── 📁 lib/                  # Bibliotecas compartidas zcli
├── 📁 modules/              # Módulos NixOS/Home Manager
│   ├── 📁 core/             # Módulos a nivel de sistema
│   └── 📁 home/             # Módulos a nivel de usuario
├── 📁 profiles/             # Perfiles Hardware/GPU
├── 📁 wallpapers/           # Colección de fondos de pantalla
├── 📄 flake.nix             # Configuración principal
└── 📄 flake.lock            # Archivo de bloqueo de dependencias
```

---

## ❄️ Fundamentos de NixOS

### Comprender Flakes

**Flakes** estandarizan y simplifican la gestión de configuración NixOS (como
`package.json` para JavaScript):

**Características Clave**:

1. **Reproducible**: Bloquear dependencias en `flake.lock`
2. **Portable**: Estructura consistente entre sistemas
3. **Predecible**: Procesos de construcción/despliegue estandarizados

Los Flakes hacen que las configuraciones NixOS sean más compartibles y
confiables.

### Home Manager

**Home Manager** proporciona gestión declarativa del entorno de usuario:

**Características**:

- **Declarativo**: Definir configuraciones de usuario en `home.nix`
- **Multiplataforma**: Funciona en NixOS, otras distros Linux, macOS
- **Aislado**: Configuraciones específicas de usuario separadas del sistema

Perfecto para gestionar dotfiles, configuraciones de shell y aplicaciones de
usuario.

### Construcciones Atómicas

**Las construcciones atómicas** aseguran cambios seguros del sistema:

**Cómo funciona**:

1. **Generaciones inmutables**: Cada cambio crea nueva generación del sistema
2. **Como transacción**: Los cambios o tienen éxito completo o no tienen efecto
3. **Rollback fácil**: Arrancar en generación anterior si ocurren problemas

**Beneficios**:

- ✅ **Confiable**: Sistema siempre en estado consistente
- 🔄 **Reproducible**: Misma configuración = mismo estado del sistema
- ⏪ **Seguro**: Rollback fácil a configuración funcionando

### Recursos de Aprendizaje

**Tutoriales en Video**:

- [Guía de Configuración NixOS](https://www.youtube.com/watch?v=AGVXJ-TIv3Y&t=34s)
- [Canal YouTube VimJoyer](https://www.youtube.com/@vimjoyer/videos) - Excelente
  contenido NixOS
- [Canal LibrePhoenix](https://www.youtube.com/@librephoenix) - Tutoriales Linux
  y NixOS
- [Serie NixOS de 8 Partes](https://www.youtube.com/watch?v=QKoQ1gKJY5A&list=PL-saUBvIJzOkjAw_vOac75v-x6EzNzZq-)

**Guías Escritas**:

- [Libro NixOS y Flakes](https://nixos-and-flakes.thiscute.world/preface) - Guía
  comprensiva

**Recursos Git**:

- [Gestionar NixOS con Git](https://www.youtube.com/watch?v=20BN4gqHwaQ)
- [Git para Principiantes](https://www.youtube.com/watch?v=K6Q31YkorUE)
- [Cómo Funciona Git](https://www.youtube.com/watch?v=e9lnsKot_SQ)
- [Inmersión Profunda Git de 1 Hora](https://www.youtube.com/watch?v=S7XpTAnSDL4&t=123s)

---

_Este FAQ está organizado para navegación fácil y referencia rápida. Usa la
tabla de contenidos para saltar a secciones específicas, y recuerda que la
mayoría de los cambios de configuración requieren ejecutar `zcli rebuild` para
tener efecto._
