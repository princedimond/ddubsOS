# Guía de actualización: de ddubsOS v2.4 a la rama refactor (flake por host)

Fecha: 2025-09-06

Esta guía te ayuda a actualizar desde Stable v2.4 a la rama refactor que introduce:
- Salidas del flake por host (#<host>) junto con las salidas de perfil heredadas (#amd/#intel/#nvidia/...)
- Flags mejorados del instalador (--host/--profile/--build-host/--non-interactive)
- Nuevos comandos de gestión de host en zcli (add-host, del-host, rename-host, hostname set)

Requisitos previos
- Estás en ddubsOS Stable-v2.4 (DDUBSOS_VERSION=2.4) y tu sistema reconstruye sin errores.
- Tienes un repositorio git de ddubsOS en ~/ddubsos.

Paso 1: Crear un respaldo (recomendado)
- Haz una copia del repo por si quieres volver atrás:
  cp -rp ~/ddubsos ~/ddubsos-backup-$(date +%F)

Paso 2: Cambiar a la rama refactor
- Muévete a la rama ddubos-refactor:
  git -C ~/ddubsos fetch --all --prune
  git -C ~/ddubsos switch ddubos-refactor

Importante: La primera rebuild debe ser nixos-rebuild (no zcli)
- En Stable v2.4 el zcli instalado no tiene lógica compatible con refactor. Haz una rebuild con tu objetivo de perfil heredado para instalar el zcli actualizado. Ejemplos:
  sudo nixos-rebuild switch --flake ~/ddubsos#vm
  sudo nixos-rebuild boot   --flake ~/ddubsos#vm
- Nota: Durante esta primera actualización, los objetivos por hostname (.#<host>) NO funcionarán para switch/boot; usa el objetivo de perfil heredado. Tras esta primera rebuild, ya puedes usar zcli y objetivos por host normalmente.

Paso 3: Revisar cambios
- Se añaden salidas del flake por host para cada directorio en hosts/.
- Se mantienen salidas de perfil heredadas (amd, intel, nvidia, nvidia-laptop, vm) para preservar el instalador y flujos actuales.
- El instalador gana flags y modo no interactivo; zcli gana comandos de gestión de hosts.
- Home Manager ahora puede compartir el conjunto global de paquetes mediante un interruptor.

Paso 4: Elegir el objetivo de build
- Opción A: Seguir usando objetivos de perfil heredados (sin cambios):
  sudo nixos-rebuild switch --flake .#amd   # o intel/nvidia/...
- Opción B: Cambiar al objetivo por host (preferido en adelante):
  sudo nixos-rebuild switch --flake .#<tu-host>

Paso 5: Actualizar/instalar con el instalador refinado (opcional)
- Flags nuevas:
  --host NAME          # preselecciona hostname
  --profile NAME       # uno de amd|intel|nvidia|nvidia-laptop|vm
  --build-host         # construir por objetivo de host (en lugar de perfil)
  --non-interactive    # aceptar valores por defecto; sin prompts

- Ejemplos:
  ./install-ddubsos.sh --host ixas --profile amd --build-host
  ./install-ddubsos.sh --non-interactive --build-host

Paso 6: Gestión de host con zcli (opcional)
- Crear un host nuevo:
  zcli add-host my-laptop [amd|intel|nvidia|nvidia-laptop|vm]
  # Usa zcli update-host my-laptop <profile> para establecer flake host/profile

- Borrar un host:
  zcli del-host my-laptop

- Renombrar un host y actualizar flake host si apuntaba al nombre viejo:
  zcli rename-host old-name new-name

- Establecer flake host (no mueve carpetas):
  zcli hostname set <new-host>


Paso 8: Reconstruir y validar
- Revisa formateo y salud básica:
  nix flake check --print-build-logs
- Reconstruye (elige uno):
  sudo nixos-rebuild switch --flake .#<host>
  sudo nixos-rebuild switch --flake .#<profile>

Ejemplo: actualizar un host VM (ddubsos-vm) a builds por host

Este ejemplo muestra una migración típica en una VM que usa objetivos de perfil heredados.

1) Cambiar a la rama refactor
- git -C ~/ddubsos switch ddubos-refactor

2) Asegurar que existe un directorio de host
- Si hosts/ddubsos-vm ya existe, puedes usarlo.
- De lo contrario, créalo:
  - zcli add-host ddubsos-vm vm
  - Edita hosts/ddubsos-vm/variables.nix (navegador, terminal, stylixImage, etc.)

3) Apuntar flake host/profile a ddubsos-vm
- zcli update-host ddubsos-vm vm
  - Esto establece host = "ddubsos-vm" y profile = "vm" en flake.nix

4) Reconstruir usando el objetivo por host (nuevo camino preferido)
- sudo nixos-rebuild switch --flake .#ddubsos-vm

Nota: Puedes seguir construyendo con el objetivo de perfil heredado en cualquier momento:
- sudo nixos-rebuild switch --flake .#vm

Solución de problemas
- Definiciones de módulo duplicadas (p.ej., sysctl swappiness) suelen indicar que hosts/<host> se importó dos veces. El refactor evita dobles importaciones; asegúrate de no importar manualmente ambos hosts/<host> y profiles/<profile> en la misma pila.
- Si el formateo Alejandra falla en flake checks, ejecuta: nix fmt

Volver a v2.4
- Si es necesario, cambia a la rama estable:
  git -C ~/ddubsos switch Stable-v2.4
  sudo nixos-rebuild switch --flake .#<profile>

Notas
- Mantén system.stateVersion y home.stateVersion ancladas.
- Para hosts nuevos, usa zcli add-host y zcli update-host para mantener el flake host/profile alineado.

