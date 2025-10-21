# qs-wallpapers-restore

Restaura el último fondo seleccionado al inicio de sesión, con respaldos robustos y arranque de swww compatible con Hyprpanel.

Instalado desde: modules/home/scripts/qs-wallpapers-restore.nix

## Qué hace

- Lee el último fondo aplicado desde los archivos de estado escritos por qs-wallpapers-apply:
  - $XDG_STATE_HOME/qs-wallpapers/current.json (preferido)
  - $XDG_STATE_HOME/qs-wallpapers/current_wallpaper (respaldo)
- Aplica el fondo usando un orden priorizado:
  1) El backend usado cuando se guardó (si está registrado)
  2) swww
  3) hyprpaper
  4) mpvpaper
  5) waypaper (como respaldo suave; los fallos se ignoran y se intenta el siguiente)
- Gestiona conflictos deteniendo demonios incompatibles entre intentos (p.ej., detiene mpvpaper/hyprpaper antes de usar swww, detiene swww/hyprpaper antes de usar mpvpaper).
- Si usa swww, espera por Hyprpanel (si está presente) antes de iniciar swww-daemon para evitar condiciones de carrera con el panel. Si Waybar ya corre, procede de inmediato.

## Dónde se guarda el estado

Estos archivos los escribe qs-wallpapers-apply cuando una selección se aplica con éxito:

- $XDG_STATE_HOME/qs-wallpapers/current.json
  - path: ruta absoluta a la imagen
  - backend: mpvpaper | swww | hyprpaper
  - timestamp: segundos desde epoch
- $XDG_STATE_HOME/qs-wallpapers/current_wallpaper
  - Texto plano con la misma ruta absoluta. Usado como simple respaldo si falta el JSON.

## Integración con Hyprland

Hyprland exec-once está configurado para ejecutar qs-wallpapers-restore. La configuración incorpora un respaldo por defecto vía waypaper si no hay estado o falla la restauración.

- Para setups con hyprpanel (primario): Hyprpanel inicia primero, luego qs-wallpapers-restore. El script espera brevemente por Hyprpanel antes de iniciar swww-daemon.
- Para setups con waybar: swww-daemon inicia temprano; qs-wallpapers-restore se ejecuta después y aplica vía swww o recurre a respaldos.

Consulta modules/home/hyprland/exec-once.nix para las líneas exactas.

## Opciones (variables de entorno)

- QS_RESTORE_WAIT_HYPRPANEL_SECONDS
  - Por defecto: 15
  - Segundos a esperar al proceso `hyprpanel` antes de iniciar swww-daemon. Si no se detecta en ese tiempo, el script continúa.
- QS_RESTORE_ORDER
  - Orden por defecto (tras el backend registrado): swww,hyprpaper,mpvpaper,waypaper
  - Proporciona una lista separada por comas para sobrescribir, p.ej.: `QS_RESTORE_ORDER="hyprpaper,swww,mpvpaper"`
- QS_DEBUG
  - Si está establecida, habilita logging verboso (prefijo [qs-restore]).

## Comportamiento de salida

- Devuelve 0 en éxito (fondo aplicado por cualquier método).
- Devuelve 1 si todos los métodos fallaron.
- Devuelve 0 y sale rápido si no existe una ruta válida guardada (permitiendo que exec-once siga al respaldo por defecto, p.ej., una imagen por defecto vía waypaper).

## Notas y advertencias

- waypaper se trata como respaldo suave: si falla (p.ej., tras una actualización de Python), el script simplemente continúa al siguiente método o sale.
- No se usan herramientas solo-X11 (p.ej., nitrogen). Se prefieren herramientas nativas de Wayland.
- El backend por defecto para nuevas selecciones se controla con `WALLPAPER_BACKEND` (ver docs de qs-wallpapers-apply).

