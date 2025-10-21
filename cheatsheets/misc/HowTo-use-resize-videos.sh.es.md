# Cómo usar resize-videos.sh (recompresión compacta con progreso y notificaciones)

Esta guía explica cómo usar myscripts-repo/resize-videos.sh para recomprimir videos de fondo de pantalla con menor tamaño y mínima pérdida visual. El script muestra progreso, omite salidas actualizadas y notifica al finalizar.

Requisitos
- ffmpeg
- Opcional: libnotify (para notify-send)

El script incluye un shebang de nix shell que provee las dependencias automáticamente al ejecutarlo.

Ubicación del script
- myscripts-repo/resize-videos.sh

Qué hace
- Re‑codifica videos con el códec, escala y fps elegidos
- Elimina audio (los fondos no necesitan sonido)
- Elige contenedor según códec (H.265→mp4, VP9→webm, AV1→mkv)
- Omite archivos ya convertidos y actualizados
- Muestra una barra de progreso por archivo: “Processing N of M [####----] 50%”
- Envía una notificación de escritorio al terminar o si hubo errores

Valores por defecto
- Directorio de origen: wallpapers
- Directorio de destino: wallpapers/optimized
- Altura: 1080
- FPS: 30
- Códec: libx265 (H.265)
- CRF: 24
- Preset: slow
- Límite de duración: ninguno (usa largo completo)

Flags y variables de entorno
- Flags:
  - -s DIR: directorio de origen
  - -d DIR: directorio de destino
  - -H N: altura de salida (mantiene proporción)
  - -F N: fps de salida
  - -c CODEC: libx265 | libvpx-vp9 | libsvtav1
  - -r N: CRF / calidad (depende del códec)
  - -p NAME: preset del codificador (p. ej., slow, medium)
  - -t SEC: límite de duración en segundos (opcional)
  - -h: ayuda
- Variables de entorno:
  - SRC_DIR, OUT_DIR, HEIGHT, FPS, CODEC, CRF, PRESET, DURATION

Ejemplos
- H.265 MP4 a 1080p/30fps:
  ```bash path=null start=null
  myscripts-repo/resize-videos.sh -c libx265 -H 1080 -F 30 -r 24 -p slow
  ```
- VP9 WebM con CRF 32, límite de 20 segundos:
  ```bash path=null start=null
  myscripts-repo/resize-videos.sh -c libvpx-vp9 -r 32 -t 20
  ```
- AV1 MKV con CRF 32, 1440p:
  ```bash path=null start=null
  myscripts-repo/resize-videos.sh -c libsvtav1 -H 1440 -r 32 -p 7
  ```

Consejos de tamaño/calidad
- H.265 (libx265) es rápido y compacto; VP9 (libvpx-vp9) es abierto y de alta calidad; AV1 (libsvtav1) logra tamaños menores pero codifica más lento.
- Aumenta CRF para tamaños más pequeños; disminúyelo para más calidad.
- Una duración corta (10–30s) hace bucle suave y reduce tamaño.

Solución de problemas
- "ffmpeg: command not found": el shebang de nix debería proveerlo. Si lo quitaste, instala ffmpeg o ejecuta con nix shell:
  ```bash path=null start=null
  nix shell nixpkgs#ffmpeg nixpkgs#libnotify -c myscripts-repo/resize-videos.sh -h
  ```
- No se encuentran archivos: verifica el directorio de origen; el script busca muchas extensiones comunes.

