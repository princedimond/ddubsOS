# Zed Editor en NixOS: Overlay + Home Manager (config RW sin symlinks)

Audiencia: Usuarios de Linux nuevos en NixOS que quieren una forma práctica de usar Zed con configuración escribible bajo Home Manager, más un overlay acotado para arreglar problemas de hash aguas arriba.

---

## Problema (septiembre de 2025)

A inicios de septiembre de 2025, construir zed-editor desde nixpkgs empezó a fallar por un desajuste de hash en una derivación de salida fija. Nix requiere el hash exacto para fetchers de salida fija; cuando el tarball del tag en GitHub cambia, cambia el hash y la build falla hasta actualizarlo. El error se veía así:

- especificado: sha256-4cP6cohUZdhvr6mvIOozhg1ahEZEypCCjvAz0fjAtec=
- obtenido:   sha256-Q7Ord+GJJcOCH/S3qNwAbzILqQiIC94qb8V+JkzQqaQ=

Esto ocurrió al obtener zed-industries/zed en el tag v0.202.5. El workaround aquí fija fetchFromGitHub a ese tag y establece sha256 al valor “obtenido”—acotado localmente para que solo aplique cuando Zed está habilitado. Una vez que nixpkgs actualice al nuevo hash, el overlay se puede quitar.

---

## Panorama general

Este documento explica un enfoque que permite:
- Instalar Zed vía Home Manager
- Mantener la config de Zed escribible (sin symlinks de Home Manager), para que la app pueda cambiar ajustes mientras pruebas
- Sincronizar tus ajustes en vivo de vuelta al repo en cada rebuild, y luego instalarlos de nuevo
- Acotar un overlay solo a Zed (y solo cuando está habilitado) para arreglar el desajuste de hash por cambios del tarball aguas arriba

La solución vive en:
- Módulo: modules/home/editors/zed-editor.nix
- Ajustes gestionados (copiados a ~/.config/zed): modules/home/editors/zed-config/
- Conmutador por host: enableZed en hosts/<host>/variables.nix e importado en modules/home/default.nix

---

## ¿Por qué el overlay?

El archivo fuente de Zed (tarball del tag en GitHub) cambió aguas arriba, lo que causó el desajuste de hash en una derivación de salida fija al construir. Nix exige hashes exactos para fetches de salida fija (p.ej., fetchFromGitHub), por lo que la build falla hasta que el hash esperado coincide con el real.

Lo solucionamos con un overlay muy estrecho que solo afecta a zed-editor y solo cuando se importa este módulo de Home Manager. El overlay:
- Fija fetchFromGitHub al tag conocido (v0.202.5)
- Establece sha256 al valor “obtenido” que Nix reportó durante el fallo
- Delimita el cambio dentro del módulo de HM (no globalmente), así otros hosts quedan intactos

Código (bloque del overlay):
```nix path=/home/dwilliams/ddubsos/modules/home/editors/zed-editor.nix start=11
  nixpkgs.overlays = [
    (final: prev: {
      zed-editor = prev.zed-editor.overrideAttrs (old: {
        # Force src to a concrete fetchFromGitHub with the correct hash.
        # This bypasses any internal pinned fetch used by the package.
        src = prev.fetchFromGitHub {
          owner = "zed-industries";
          repo = "zed";
          rev = "v0.202.5"; # keep in sync with the package version
          sha256 = "sha256-Q7Ord+GJJcOCH/S3qNwAbzILqQiIC94qb8V+JkzQqaQ=";
          fetchSubmodules = true;
        };
      });
    })
  ];
```

Notas:
- Si/cuando nixpkgs actualice Zed, puedes quitar o actualizar este overlay.
- Mantener el overlay aquí (en el módulo de HM) implica que se aplica solo si enableZed es true.

---

## Habilitar Zed por host

Habilitas Zed por host con un flag booleano en hosts/<host>/variables.nix (enableZed). modules/home/default.nix importa el módulo de Zed solo si ese flag es true.

Fragmento (import condicional):
```nix path=/home/dwilliams/ddubsos/modules/home/default.nix start=69
  ++ (if gnomeEnable then [ ./gui/gnome.nix ] else [ ])
  ++ (if enableZed then [ ./editors/zed-editor.nix ] else [ ])
  ++ (if bspwmEnable then [ ./gui/bspwm.nix ] else [ ])
```

Esto facilita desplegar Zed en una máquina (p.ej., ixas) manteniendo otras sin cambios.

---

## Home Manager: copiar, no enlazar (archivos escribibles)

Zed escribe en su configuración mientras trabajas (asistente de bienvenida, cambios de UI, etc.). Si Home Manager hace symlink de estos archivos, la app puede seguir escribiendo, pero a menudo prefieres archivos planos en disco, escribibles, y no enlaces al store de solo lectura. Así que:
- Mantenemos una copia en el repo de tu config de Zed bajo modules/home/editors/zed-config/
- Durante la activación, copiamos el contenido del repo a ~/.config/zed (sin symlinks), asegurando que los archivos permanezcan RW para Zed

Esto evita sorpresas y mantiene una UX simple para ediciones dirigidas por la app.

---

## Respaldo y Sync: orden de operaciones

Para prevenir pérdida de datos y aun así sostener reproducibilidad, la activación ejecuta tres pasos en orden:

1) Sincroniza los ajustes en vivo de vuelta al repo
- Copia ~/.config/zed/. a modules/home/editors/zed-config/
- Captura cualquier cambio hecho desde el último rebuild

2) Respalda el directorio activo
- Mueve ~/.config/zed a ~/.config/zed.bak-YYYYmmdd-HHMMSS
- Red de seguridad por si quieres recuperar el estado vivo anterior

3) Instala desde el repo
- Copia modules/home/editors/zed-config/. a ~/.config/zed
- Asegura chmod -R u+w para que los archivos sean escribibles por ti/Zed
- Limpia directorios anidados obsoletos si alguna vez existió un layout heredado

Código anotado (DAG de activación):
```nix path=/home/dwilliams/ddubsos/modules/home/editors/zed-editor.nix start=33
  home.activation = {
    # First, sync any live changes back into the repo-managed directory
    syncZedBack = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -d "${zedConfigDir}" ]; then
        mkdir -p "${repoZedConfig}"
        echo "Syncing live Zed config from ${zedConfigDir} back to ${repoZedConfig}"
        cp -r --no-preserve=all "${zedConfigDir}/." "${repoZedConfig}/" 2>/dev/null || true
      fi
    '';

    # Then, back up the live config
    backupZed = lib.hm.dag.entryAfter [ "syncZedBack" ] ''
      if [ -d "${zedConfigDir}" ]; then
        echo "Backing up existing Zed config from ${zedConfigDir} to ${zedConfigDir}.bak-${timestamp}"
        mv "${zedConfigDir}" "${zedConfigDir}.bak-${timestamp}"
      fi
    '';

    installZed = lib.hm.dag.entryAfter [ "backupZed" ] ''
      mkdir -p "${zedConfigDir}"
      if [ -d "${repoZedConfig}" ]; then
        echo "Copying managed Zed config from ${repoZedConfig} to ${zedConfigDir} (no symlinks)"
        # Use "." to include dotfiles and copy directory contents
        cp -r --no-preserve=all "${repoZedConfig}/." "${zedConfigDir}/" 2>/dev/null || true
        # Clean up any legacy nested 'zed' directory if present and not managed
        if [ ! -d "${repoZedConfig}/zed" ] && [ -d "${zedConfigDir}/zed" ]; then
          rm -rf "${zedConfigDir}/zed"
        fi
        chmod -R u+w "${zedConfigDir}"
      else
        echo "Warning: ${repoZedConfig} not found. Skipping Zed config copy."
      fi
    '';
  };
```

Notas de implementación:
- Usamos cp -r --no-preserve=all en lugar de rsync para evitar requerir rsync en la unidad de HM.
- Usar "${dir}/." asegura copiar dotfiles.
- chmod -R u+w garantiza que Zed pueda escribir tras la instalación.

---

## Flujo diario

- Configura Zed normalmente. Actualiza ~/.config/zed en tiempo real.
- Cuando ejecutas zcli rebuild:
  - Tus ediciones en vivo se cosechan a modules/home/editors/zed-config
  - La copia del repo se (re)instala en ~/.config/zed
- Haz commit/push de modules/home/editors/zed-config para preservar tu setup curado

Esto te da los beneficios de Nix (instalación reproducible) y la ergonomía de archivos RW mientras iteras.

---

## Trade-offs y alternativas

- Symlinks vía home.file: más simple, pero pierdes la UX de “la app gestiona los archivos libremente” y puedes chocar con rutas del store de solo lectura si no se maneja con cuidado.
- Generar ajustes con Nix: muy reproducible, pero no genial para cambios frecuentes desde la app; tendrías que editar Nix cada vez.
- Copiar una vez, nunca sincronizar de vuelta: más seguro, pero tendrías que traer cambios al repo manualmente y es fácil olvidarlo.

Esta solución busca un punto medio que encaje con la UX de un editor/GUI.

---

## Cambiar versiones (mantenimiento del overlay)

- Si Zed actualiza aguas arriba y te topas con otro desajuste de hash, actualiza rev y sha256 dentro del bloque del overlay al nuevo tag y hash “obtenido”.
- Una vez que nixpkgs alcance el cambio, puedes quitar el overlay.

---

## Solución de problemas

- La unidad de HM falla con command not found: rsync
  - Se corrige usando cp en lugar de rsync en la activación (ya aplicado)
- El asistente de bienvenida no se ejecuta
  - Ocurre si settings.json/config.json ya existen. Elimínalos de ~/.config/zed y/o deja el repo vacío para que Zed se inicialice.
- Los cambios en vivo no aparecen en el repo
  - Asegúrate de haber reconstruido (zcli rebuild). La sincronización sucede en la activación.

---

## Archivos y rutas

- Config gestionada (copiada al lugar):
  - modules/home/editors/zed-config/
- Config en vivo:
  - ~/.config/zed/
- Respaldos (en cada activación si existía el dir en vivo):
  - ~/.config/zed.bak-YYYYmmdd-HHMMSS

---

## Resumen

- El overlay resuelve un desajuste de hash transitorio para Zed, acotado a este módulo de HM y flag por host.
- El script de activación de Home Manager sincroniza ediciones en vivo de vuelta al repo, respalda y luego instala el contenido del repo como archivos planos para que Zed pueda seguir escribiendo.
- Resultado: Puedes iterar dentro de la app y aún así preservar tu configuración bajo control de versiones.

