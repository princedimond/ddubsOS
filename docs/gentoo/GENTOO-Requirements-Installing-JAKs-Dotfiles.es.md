# Guía de Configuración de Gentoo Hyprland para la Configuración de JaKooLit

**Escrito por Don Williams (ddubs)**

Esta guía proporciona una comparación completa de paquetes entre Arch Linux (scripts de JaKooLit) y Gentoo Linux, con instrucciones específicas para usuarios nuevos de Gentoo que desean instalar Hyprland con los dotfiles de JaKooLit.

## 📚 Lectura Esencial Antes de Comenzar

### Documentación Oficial:
- **Manual de Gentoo**: https://wiki.gentoo.org/wiki/Handbook:Main_Page
- **Wiki de Gentoo Hyprland**: https://wiki.gentoo.org/wiki/Hyprland
- **Wiki Oficial de Hyprland**: https://wiki.hyprland.org/
- **Dotfiles de Hyprland de JaKooLit**: https://github.com/JaKooLit/Hyprland-Dots

### Conceptos Importantes de Gentoo:
- **Portage**: Gestor de paquetes de Gentoo (equivalente a pacman en Arch)
- **USE Flags**: Controlan qué características se compilan en los paquetes
- **Overlays**: Repositorios de paquetes de terceros (se necesita el overlay guru para algunos paquetes)
- **emerge**: Comando para instalar paquetes (equivalente a `pacman -S`)
- **eix**: Herramienta de búsqueda rápida de paquetes (recomendado instalar primero)

## ⚠️ Precauciones Importantes

### 1. **Consideraciones Importantes**
El soporte para los dotfiles actuales de Hyprland de Jak requiere que Hyprland y las aplicaciones de soporte sean de la rama de prueba de Gentoo. La rama estable actual solo tiene Hyprland v0.49, lo que resultará en muchos errores de Hyprland si se usa.

```bash
# Para habilitar paquetes de la rama de prueba, agregar a /etc/portage/package.accept_keywords
echo 'gui-wm/hyprland ~amd64' | sudo tee -a /etc/portage/package.accept_keywords/hyprland
# Repetir para otros paquetes relacionados con Hyprland según sea necesario
```

### 2. **Habilitar el Overlay GURU**
Muchos paquetes relacionados con Hyprland están en el overlay guru:
```bash
sudo emerge --ask app-eselect/eselect-repository
sudo eselect repository enable guru
sudo emerge --sync guru
```

### 3. **Configuración de USE Flags**
Hyprland requiere USE flags específicos. Los comandos emerge te solicitarán `--autounmask-write` cuando sea necesario. Siempre revisa los cambios antes de aplicarlos:
```bash
# Después de --autounmask-write, aplica los cambios con:
sudo etc-update --automode -5  # Combinar automáticamente todos los cambios
# O para revisión manual:
sudo dispatch-conf
```

### 4. **Requisitos del Sistema**
- **Gráficos**: Asegúrate de que tu GPU soporte Wayland (AMD/Intel recomendado, NVIDIA requiere configuración adicional)
- **Kernel**: Kernel moderno con soporte DRM
- **systemd**: Estas instrucciones asumen systemd (no OpenRC)

### 5. **Tiempo de Compilación**
Gentoo compila paquetes desde el código fuente. Paquetes grandes como webkit-gtk pueden tardar mucho tiempo.

### 6. **Instalar eix Primero**
Hace que la búsqueda de paquetes sea mucho más rápida:
```bash
sudo emerge -v app-portage/eix
sudo eix-update
```

## Estadísticas Resumidas

**Disponibles para Instalación:** 38/40 paquetes de la lista de prioridad
**Tasa de Éxito:** ~95%
**Paquetes que Requieren Alternativas:** 2 (cliphist→clipman, hyprpolkitagent→polkit-gnome)

## 🚀 Cómo Installé Gentoo

### Estos Son los Pasos Que Usé

#### 1. Instalar Herramientas del Sistema Primero
```bash
# Instalar eix para búsqueda rápida de paquetes
sudo emerge -v app-portage/eix
sudo eix-update
```

#### 2. Instalar Núcleo de Hyprland
```bash
# Compositor principal y ecosistema
sudo emerge -v gui-wm/hyprland gui-apps/hypridle gui-apps/hyprlock
```

#### 3. Instalar Herramientas Wayland Básicas
```bash
# Capturas de pantalla y fondo de pantalla
sudo emerge -v gui-apps/grim gui-apps/slurp gui-apps/swappy gui-apps/swww gui-apps/hyprshot
```

#### 4. Instalar Gestión del Portapapeles
```bash
# Nota: cliphist no está disponible, usar clipman en su lugar
sudo emerge -v gui-apps/clipman gui-apps/wl-clipboard
```

#### 5. Instalar Notificaciones
```bash
sudo emerge -v gui-apps/swaync
# libnotify se incluirá como dependencia
```

#### 6. Instalar Controles de Audio
```bash
sudo emerge -v media-sound/pamixer media-sound/pavucontrol media-sound/playerctl
```

#### 7. Instalar Utilidades del Sistema
```bash
sudo emerge -v app-misc/brightnessctl media-gfx/imagemagick sys-apps/inxi gnome-base/gvfs app-editors/nano
```

#### 8. Instalar Temas Qt
```bash
# Nota: qt6ct no está disponible en Gentoo
sudo emerge -v x11-themes/kvantum x11-misc/qt5ct
```

**IMPORTANTE - Para usuarios de QuickShell:**
```bash
# Habilitar la bandera qml USE para Qt5Compat (requerido para GraphicalEffects)
echo 'dev-qt/qt5compat qml' | sudo tee -a /etc/portage/package.use/qt
sudo emerge -v dev-qt/qt5compat
```

#### 9. Instalar Applet de NetworkManager
```bash
sudo emerge -v gnome-extra/nm-applet
```

#### 10. Instalar Gestión de Sesión
```bash
sudo emerge -v gui-apps/wlogout x11-misc/xdg-user-dirs
```

#### 11. Instalar Fuentes
```bash
# Nota: nerdfonts probablemente ya está instalado
sudo emerge -v media-fonts/source-code-pro media-fonts/noto-emoji
```

#### 12. Instalar Motor de Temas GTK
```bash
sudo emerge -v x11-themes/gtk-engines-murrine
```

#### 13. Instalar Monitoreo de Batería
```bash
sudo emerge -v sys-power/acpi
```

#### 14. Instalar Herramientas Críticas para la Configuración de JaKooLit
```bash
# YAD - REQUERIDO para diálogos de ayuda y solicitudes de fondo de SDDM
# WALLUST - REQUERIDO para temas basados en fondos de pantalla
# POLKIT-GNOME - REQUERIDO para diálogos de autenticación
sudo emerge -v gnome-extra/yad x11-misc/wallust gnome-extra/polkit-gnome
```

#### 15. Instalar Bibliotecas Python
```bash
sudo emerge -v dev-python/pyquery
```

#### 16. Instalar Herramientas Opcionales
```bash
sudo emerge -v app-editors/mousepad media-video/mpv sys-process/nvtop \
                media-gfx/loupe media-sound/cava gui-apps/nwg-displays \
                sci-calculators/qalculate-gtk net-misc/yt-dlp
```

#### 17. Instalar AGS v1.9.0 (Aylur's GTK Shell)

**Nota:** AGS no está en los repositorios de Gentoo, así que lo construimos desde el código fuente. AGS v1.9.0 es requerido para la funcionalidad de vista general del escritorio de JaKooLit.

**✅ Probado y Verificado en Gentoo x86_64**

##### Requisitos Específicos Importantes de Gentoo:

1. **nodejs necesita la bandera npm USE habilitada**
2. **Nombre de paquete correcto**: `dev-libs/gjs` (NO `gnome-base/gjs`)
3. **Gentoo usa `/usr/local/lib64/`** para typelibs (no `/usr/local/lib/`)
4. **Se requiere script wrapper** para configurar `GI_TYPELIB_PATH`

##### Opción 1: Usando el Script Automatizado (Recomendado)

Se proporciona un script de instalación completo a continuación. Este maneja todos los requisitos específicos de Gentoo automáticamente.

**Descargar y ejecutar:**
```bash
# Descargar el script (o crearlo manualmente - ver script abajo)
# El script está disponible en ~/ddubsos/myscripts-repo/agsv1-gentoo-install.sh

# Hacer ejecutable y ejecutar
chmod +x agsv1-gentoo-install.sh
./agsv1-gentoo-install.sh
```

**Script de Instalación Completo:**

El script completo `agsv1-gentoo-install.sh` está disponible en `~/ddubsos/myscripts-repo/` e incluye:

- Detección y configuración automática de la bandera npm USE para nodejs
- Nombres de paquete correctos (`dev-libs/gjs` no `gnome-base/gjs`)
- Creación automática de script wrapper para soporte de lib64
- Parche del lanzador actualizado para usar `/usr/local/lib64`

##### Opción 2: Instalación Manual

Si prefieres instalar manualmente:

```bash
# 1. Habilitar la bandera npm USE para nodejs
echo 'net-libs/nodejs npm' | sudo tee -a /etc/portage/package.use/nodejs

# 2. Instalar dependencias (nota: dev-libs/gjs NO gnome-base/gjs)
sudo emerge -v dev-lang/typescript net-libs/nodejs dev-build/meson \
               dev-libs/glib dev-libs/gjs x11-libs/gtk+:3 \
               gui-libs/gtk-layer-shell sys-power/upower \
               net-misc/networkmanager dev-libs/gobject-introspection \
               dev-libs/libdbusmenu net-libs/libsoup:3.0

# 3. Clonar y construir AGS
git clone --depth=1 https://github.com/JaKooLit/ags_v1.9.0.git
cd ags_v1.9.0
npm install
meson setup build
sudo meson install -C build

# 4. Crear wrapper para soporte de lib64 (REQUERIDO para Gentoo)
sudo mv /usr/local/bin/ags /usr/local/bin/ags.bin
cat << 'EOF' | sudo tee /usr/local/bin/ags
#!/bin/bash
export GI_TYPELIB_PATH=/usr/local/lib64:$GI_TYPELIB_PATH
exec /usr/local/bin/ags.bin "$@"
EOF
sudo chmod +x /usr/local/bin/ags

# 5. Aplicar parche del lanzador
LAUNCHER="/usr/local/share/com.github.Aylur.ags/com.github.Aylur.ags"
sudo sed -i \
    -e 's|^import GIR from "gi://GIRepository?version=2.0";$|import GLib from "gi://GLib";|' \
    -e '/GIR.Repository.prepend_search_path/d' \
    -e '/GIR.Repository.prepend_library_path/d' \
    "$LAUNCHER"

sudo awk '{print} $0 ~ /^import GLib from "gi:\/\/GLib";$/ {print "const __old = GLib.getenv(\"GI_TYPELIB_PATH\");"; print "GLib.setenv(\"GI_TYPELIB_PATH\", \"/usr/local/lib64\" + (__old ? \":\" + __old : \"\"), true);"}' "$LAUNCHER" > /tmp/ags_launcher
sudo mv /tmp/ags_launcher "$LAUNCHER"
sudo chmod +x "$LAUNCHER"

# 6. Verificar
ags --version  # Debería mostrar: 1.9.0

# 7. Limpiar
cd ..
rm -rf ags_v1.9.0
```

##### Verificación:

```bash
ags --version
# Salida esperada: 1.9.0
```

##### Problemas Comunes:

**Problema 1: "npm: command not found"**
- Solución: Habilitar la bandera npm USE para nodejs (el script lo maneja automáticamente)

**Problema 2: "Typelib file for namespace 'GUtils' not found"**
- Solución: El script wrapper configura GI_TYPELIB_PATH a /usr/local/lib64 (el script lo maneja automáticamente)

**Problema 3: "gnome-base/gjs not found"**
- Solución: Usar `dev-libs/gjs` en su lugar (el script usa el nombre de paquete correcto)

## 💡 Consejos Importantes para Usuarios de Gentoo

### Consejos de Instalación de Paquetes:

1. **Conflictos de USE Flags**: Cuando emerge reporte conflictos de USE flags, usar:
   ```bash
   sudo emerge -v --autounmask-write <paquete>
   sudo etc-update --automode -5
   sudo emerge -v <paquete>
   ```

2. **Verificar Disponibilidad de Paquetes**:
   ```bash
   eix <nombre-paquete>  # Búsqueda rápida
   emerge -s <nombre-paquete>  # Búsqueda estándar
   ```

3. **Progreso de Instalación**: Paquetes grandes (webkit-gtk, mpv) pueden tardar 30+ minutos en compilar.

4. **Resolución de Dependencias**: Portage manejará automáticamente las dependencias, pero revisa la lista antes de continuar.

### Configuración Específica de Hyprland:

1. **Iniciar Agente Polkit**: Agregar a `~/.config/hypr/hyprland.conf`:
   ```bash
   exec-once = /usr/libexec/polkit-gnome-authentication-agent-1
   ```

2. **Iniciar Gestor de Portapapeles**: Agregar a hyprland.conf:
   ```bash
   exec-once = wl-paste --type text --watch clipman store
   exec-once = wl-paste --type image --watch clipman store
   ```

3. **Controladores Gráficos**: Asegurar la instalación correcta del controlador:
   - **AMD**: `media-libs/mesa` con `VIDEO_CARDS="amdgpu radeonsi"`
   - **Intel**: `media-libs/mesa` con `VIDEO_CARDS="intel iris"`
   - **NVIDIA**: Seguir la guía de NVIDIA de Gentoo (más complejo para Wayland)

### Paquetes Equivalentes y Alternativas:

| Paquete Arch | Equivalente Gentoo | Notas |
|-------------|------------------|-------|
| `cliphist` | `gui-apps/clipman` | Funcionalmente equivalente |
| `hyprpolkitagent` | `gnome-extra/polkit-gnome` | Alternativa compatible |
| `qt6ct` | No disponible | Usar temas nativos de Qt6 |
| `yad` | `gnome-extra/yad` | En overlay guru |
| `wallust` | `x11-misc/wallust` | En overlay guru |

### Solución de Problemas:

1. **Paquete No Encontrado**: Verificar si el overlay guru está habilitado:
   ```bash
   eselect repository list
   ```

2. **Errores de Compilación**: Verificar dependencias faltantes o USE flags:
   ```bash
   emerge --info <paquete>
   ```

3. **Rendimiento**: Considerar usar:
   ```bash
   # En /etc/portage/make.conf
   MAKEOPTS="-j$(nproc)"
   EMERGE_DEFAULT_OPTS="--jobs 4 --load-average $(nproc)"
   ```

### Configuración Post-Instalación:

1. **Crear Entrada de Escritorio de Hyprland** (para gestores de pantalla):
   ```bash
   sudo mkdir -p /usr/local/share/wayland-sessions
   sudo tee /usr/local/share/wayland-sessions/hyprland.desktop << 'EOF'
   [Desktop Entry]
   Name=Hyprland
   Comment=An intelligent dynamic tiling Wayland compositor
   Exec=Hyprland
   Type=Application
   EOF
   ```

2. **Habilitar Servicios** (si se usa systemd):
   ```bash
   systemctl --user enable pipewire pipewire-pulse wireplumber
   ```

3. **Desplegar Dotfiles de JaKooLit**:
   ```bash
   git clone https://github.com/JaKooLit/Hyprland-Dots.git
   cd Hyprland-Dots
   # Seguir las instrucciones de instalación de JaKooLit
   ```

4. **Probar Componentes Críticos**:
   ```bash
   # Captura de pantalla
   grim ~/test.png
   
   # Temas de fondo de pantalla
   wallust ~/Pictures/wallpaper.png
   
   # Diálogo
   yad --info --text="Diálogo de prueba"
   ```

## 📖 Recursos Adicionales

- **Wiki de Gentoo - Wayland**: https://wiki.gentoo.org/wiki/Wayland
- **Foros de Gentoo**: https://forums.gentoo.org/
- **Discord de Hyprland**: https://discord.gg/hyprland
- **Documentación de JaKooLit**: https://github.com/JaKooLit/Hyprland-Dots/wiki

## ⚠️ Problemas Conocidos

1. **Usuarios de NVIDIA**: El soporte de Wayland en NVIDIA requiere:
   - Versión de controlador 495+
   - Parámetro del kernel `nvidia-drm.modeset=1`
   - Variables de entorno en hyprland.conf

2. **Usuarios de VM**: Deshabilitar paquetes de Bluetooth:
   ```bash
   # Omitir instalaciones de bluez, bluez-utils, blueman
   ```

3. **Aplicaciones Qt6**: Sin qt6ct, usar temas con variables de entorno:
   ```bash
   export QT_QPA_PLATFORMTHEME=qt5ct  # Regresa a temas de Qt5
   ```

## 🎯 Script de Instalación Rápida

Para usuarios experimentados, aquí hay un enfoque de una línea (revisar antes de ejecutar):

```bash
# Instalar todos los paquetes esenciales
sudo emerge -v \
  app-portage/eix \
  gui-wm/hyprland gui-apps/hypridle gui-apps/hyprlock \
  gui-apps/grim gui-apps/slurp gui-apps/swappy gui-apps/swww gui-apps/hyprshot \
  gui-apps/clipman gui-apps/swaync \
  media-sound/pamixer media-sound/pavucontrol media-sound/playerctl \
  app-misc/brightnessctl media-gfx/imagemagick sys-apps/inxi \
  gnome-base/gvfs x11-themes/kvantum x11-misc/qt5ct \
  gnome-extra/nm-applet gui-apps/wlogout x11-misc/xdg-user-dirs \
  media-fonts/source-code-pro media-fonts/noto-emoji \
  x11-themes/gtk-engines-murrine sys-power/acpi \
  gnome-extra/yad x11-misc/wallust gnome-extra/polkit-gnome \
  dev-python/pyquery
```

**Nota**: Los conflictos de USE flags requerirán --autounmask-write como se muestra arriba.

## 🎉 Verificación

Después de la instalación, verificar componentes críticos:

```bash
# Verificar que todos los binarios estén disponibles
which hyprland grim slurp swappy hyprshot clipman swaync \
      pamixer playerctl brightnessctl wallust yad

# Verificar agente polkit
ls /usr/libexec/polkit-gnome-authentication-agent-1

# Probar eix
eix hyprland

# Verificar AGS
ags --version
```

¡Si todos los comandos tienen éxito, estás listo para instalar los dotfiles de JaKooLit!

---

## Ubicación del Script de Instalación de AGS

El script completo de instalación de AGS está disponible en:
```
~/ddubsos/myscripts-repo/agsv1-gentoo-install.sh
```

Este script maneja automáticamente:
- Verificación y configuración de la bandera npm USE para nodejs
- Instalación de todas las dependencias con nombres de paquete correctos
- Construcción y compilación de AGS
- Creación del script wrapper para soporte de lib64 de Gentoo
- Aplicación de todos los parches necesarios
- Verificación de la instalación

Para usar el script:
```bash
cd ~/ddubsos/myscripts-repo/
./agsv1-gentoo-install.sh
```
