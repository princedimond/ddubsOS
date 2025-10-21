# Cómo usar resize-images.sh (conversión a WebP con progreso y notificaciones)

Esta guía explica cómo usar myscripts-repo/resize-images.sh para convertir y redimensionar fondos de pantalla (imágenes) con mínima pérdida perceptual. El script muestra el progreso, omite salidas actualizadas y envía una notificación al finalizar.

Requisitos
- libwebp (para cwebp)
- Opcional: libnotify (para notify-send)

El script incluye un shebang de nix shell, así que las dependencias se proveen automáticamente al ejecutarlo.

Ubicación del script
- myscripts-repo/resize-images.sh

Qué hace
- Convierte imágenes a WebP
- Redimensiona a una altura máxima (manteniendo proporción)
- Omite archivos ya convertidos y actualizados
- Muestra una barra de progreso por archivo: “Processing N of M [####----] 50%”
- Envía una notificación de escritorio al terminar o si hubo errores

Valores por defecto
- Directorio de origen: wallpapers
- Directorio de destino: wallpapers/optimized
- Altura máxima: 1080
- Calidad (WebP): 75
- Extensiones: jpg,jpeg,png (soporta mayúsculas/minúsculas)

Flags y variables de entorno
- Flags:
  - -s DIR: directorio de origen
  - -d DIR: directorio de destino
  - -H N: altura máxima (pixeles); 0 para mantener original
  - -q N: calidad (0–100)
  - -e LISTA: extensiones separadas por coma (p. ej., "jpg,jpeg,png")
  - -h: ayuda
- Variables de entorno:
  - SRC_DIR, OUT_DIR, MAXH, QUALITY, EXTS

Ejemplos
- Redimensionar a 1440p con calidad 80, directorios por defecto:
  ```bash path=null start=null
  myscripts-repo/resize-images.sh -H 1440 -q 80
  ```
- Convertir desde otro directorio de origen a un destino personalizado:
  ```bash path=null start=null
  myscripts-repo/resize-images.sh -s Pictures/Wallpapers -d Pictures/Wallpapers/optimized
  ```
- Usar variables de entorno en lugar de flags:
  ```bash path=null start=null
  SRC_DIR=wallpapers OUT_DIR=wallpapers/optimized MAXH=1440 QUALITY=80 \
    myscripts-repo/resize-images.sh
  ```

Notas sobre calidad
- Una calidad WebP ~80 suele ser indistinguible visualmente; ajusta según preferencia.
- Para pantallas 4K, una altura máxima de 1440 es un gran equilibrio. 1080 es suficiente en la mayoría de los casos.

Solución de problemas
- "cwebp: command not found": el shebang de nix debería proporcionarlo. Si quitaste el shebang, instala libwebp o ejecuta con nix shell:
  ```bash path=null start=null
  nix shell nixpkgs#libwebp nixpkgs#libnotify -c myscripts-repo/resize-images.sh
  ```
- No se encuentran archivos: verifica el directorio de origen y la lista de extensiones.

