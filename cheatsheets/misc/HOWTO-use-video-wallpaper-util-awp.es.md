# Cómo usar la utilidad de fondos animados (awp)

Esta guía explica cómo usar las herramientas de fondos animados incluidas en ddubsOS:
- awp: un CLI que envuelve mpvpaper para establecer fondos animados por monitor o en todos
- awp-menu: un menú rofi compacto con búsqueda para elegir un archivo de fondo y aplicarlo con awp

Requisitos
- mpvpaper instalado y en PATH
- Un compositor Wayland (Hyprland, sway, etc.)
- jq (para detectar monitores vía hyprctl/swaymsg), provisto en tiempo de ejecución por el paquete

Directorio de fondos
- Directorio por defecto: ~/Pictures/Wallpapers
- Sobrescribe con la variable de entorno: WALLPAPERS_DIR

Inicio rápido
- Establecer un archivo específico en todos los monitores:
  ```bash path=null start=null
  awp -f "$HOME/Pictures/Wallpapers/Animated-Space-Room-2.mp4" -m all
  ```
- Abrir el menú y aplicar (por defecto estira para llenar):
  ```bash path=null start=null
  awp-menu
  ```

CLI: awp
Uso
```bash path=null start=null
a wp [1|2|3...] [-f|--file FILE] [-m|--mon MONITOR|all] [--fill|--stretch] [-k|--kill]
```
- -f, --file FILE: ruta a un fondo (video o imagen animada)
- -m, --mon MON: nombre de monitor (p. ej., HDMI-A-1) o all
  - Si se omite: awp intenta el monitor enfocado y si falla usa el primero detectado
- --fill: relleno recortando (conserva aspecto) vía mpv panscan=1.0
- --stretch: estira para llenar la pantalla (ignora aspecto) vía mpv keepaspect=no
- -k, --kill: termina instancias de mpvpaper existentes
  - Con -m MON, solo ese monitor
  - Sin -m, todas las instancias

Ejemplos
- Estirar para llenar en todos los monitores:
  ```bash path=null start=null
  awp -f "$HOME/Pictures/Wallpapers/foo.avif" -m all --stretch
  ```
- Relleno recortando (conservar aspecto, puede recortar bordes) en un monitor:
  ```bash path=null start=null
  awp -f "$HOME/Pictures/Wallpapers/bar.mkv" -m HDMI-A-1 --fill
  ```
- Reemplazar lo que esté corriendo con el fondo seleccionado:
  ```bash path=null start=null
  awp --kill && awp -f "$HOME/Pictures/Wallpapers/clip.webm" -m all
  ```

Notas
- awp reenvía opciones mpv a mpvpaper mediante -o. Por defecto habilita el bucle.
- --fill añade panscan=1.0; --stretch añade keepaspect=no.

Menú: awp-menu
- Lista formatos comunes soportados por mpv/mpvpaper en tu directorio de fondos:
  MP4, M4V, MP4V, MOV, WEBM, AVI, MKV, MPEG/MPG, WMV, AVCHD, FLV, OGV, M2TS/TS, 3GP y AVIF.
- Incluye enlaces simbólicos del directorio superior.
- Usa rofi con búsqueda difusa e insensible a mayúsculas.
- Estilo: esquinas redondeadas y fondo translúcido para blur/sombra.
- Comportamiento: invoca awp con --stretch por defecto (bucle, keepaspect=no) para llenar pantalla.

Ejemplos
- Abrir el menú y aplicar en todos los monitores:
  ```bash path=null start=null
  awp-menu
  ```
- Usar un directorio distinto solo para esta ejecución:
  ```bash path=null start=null
  WALLPAPERS_DIR="$HOME/Videos/Wallpapers" awp-menu
  ```

Solución de problemas
- No aparecen archivos en el menú
  - Verifica que el directorio exista: echo "$WALLPAPERS_DIR" (o usa la ruta por defecto)
  - Asegúrate de que los archivos estén en el nivel superior (awp-menu usa -maxdepth 1)
  - Los enlaces simbólicos están soportados
- El fondo no llena la pantalla
  - Usa --stretch para pantalla completa (puede distorsionar)
  - Usa --fill para conservar aspecto (puede recortar)
- Múltiples instancias de mpvpaper
  - Usa awp --kill para terminarlas
  - awp-menu ya elimina instancias antes de aplicar

Integración
- Asigna una tecla para lanzar awp-menu en tu compositor (ej., binds de Hyprland)
- Si prefieres a menudo el relleno recortando, agrega --fill a tu atajo o alias

Seguridad
- awp y awp-menu no requieren privilegios
- No usan secretos; evita colocarlos en rutas/archivos

Dónde viven los scripts
- awp: modules/home/scripts/awp.nix (instalado como ejecutable)
- awp-menu: modules/home/scripts/awp-menu.nix (instalado como ejecutable)

¡Feliz personalización!

