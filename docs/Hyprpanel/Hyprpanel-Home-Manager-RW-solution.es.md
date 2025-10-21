# Hyprpanel en NixOS: configuración RW con Home Manager sin symlinks (revisión + mejoras)

Audiencia: Usuarios de Linux nuevos en NixOS que quieren un flujo de trabajo ergonómico, con archivos escribibles, para Hyprpanel bajo Home Manager—similar al enfoque usado con Zed.

---

## Enfoque actual en este repositorio

El módulo modules/home/hyprpanel.nix actualmente copia los archivos de Hyprpanel del repositorio a ~/.config/hyprpanel y los deja escribibles:

```nix path=/home/dwilliams/ddubsos/modules/home/hyprpanel.nix start=1
{ config, ... }: {
  home.activation.setupHyprpanel = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/hyprpanel"
    cp -r --no-preserve=all ${config.home.homeDirectory}/ddubsos/modules/home/hyprpanel/* "$HOME/.config/hyprpanel/"
    chmod -R u+w "$HOME/.config/hyprpanel"
  '';

  home.file = {
    ".local/bin/" = {
      source = ./scripts;
      recursive = true;
    };
  };
}
```

Pros:
- Simple: copia desde el repo a ~/.config/hyprpanel y garantiza permisos de escritura
- Usa la activación de Home Manager para instalar los archivos en cada rebuild

Contras / pequeños huecos:
- Sin sincronización de cambios en vivo hacia atrás: los cambios hechos en ~/.config/hyprpanel no aterrizan automáticamente en el repo
- Sin respaldo antes de sobrescribir: una copia fallida o ediciones del usuario podrían perderse sin red de seguridad
- cp con un `*` final no incluye dotfiles (archivos ocultos), que a veces importan

---

## Mejoras sugeridas

1) Añadir un paso de sincronización de vuelta antes de instalar
- Copiar ~/.config/hyprpanel/. de regreso a modules/home/hyprpanel (repo) para capturar ediciones en vivo antes de sobrescribir el directorio activo. Esto refleja la solución de Zed y soporta un flujo app-first agradable.

2) Añadir un paso de respaldo
- Antes de copiar el contenido del repo, respalda ~/.config/hyprpanel a ~/.config/hyprpanel.bak-YYYYmmdd-HHMMSS. Facilita recuperar un estado previo.

3) Copiar dotfiles y garantizar RW
- Usa el patrón `"${dir}/."` con cp para incluir archivos ocultos.
- Ejecuta `chmod -R u+w` para mantener los archivos escribibles tras la instalación.

4) Evitar rsync
- `cp -r --no-preserve=all` evita introducir rsync como dependencia en la unidad de Home Manager.

---

## Implementación propuesta

Debajo hay un reemplazo directo para la lógica de activación. Imita el patrón del módulo de Zed: sincroniza de vuelta, respalda y luego instala.

```nix path=null start=null
{ config, lib, ... }:
let
  repoHyprCfg = "${config.home.homeDirectory}/ddubsos/modules/home/hyprpanel";
  hyprCfgDir  = "${config.home.homeDirectory}/.config/hyprpanel";
  timestamp   = "$(date +%Y%m%d-%H%M%S)";
in
{
  home.activation = {
    # 1) Sync en vivo hacia el repo
    syncHyprpanelBack = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -d "${hyprCfgDir}" ]; then
        echo "Syncing live hyprpanel config from ${hyprCfgDir} back to ${repoHyprCfg}"
        mkdir -p "${repoHyprCfg}"
        cp -r --no-preserve=all "${hyprCfgDir}/." "${repoHyprCfg}/" 2>/dev/null || true
      fi
    '';

    # 2) Respaldo del directorio activo (si existe)
    backupHyprpanel = lib.hm.dag.entryAfter [ "syncHyprpanelBack" ] ''
      if [ -d "${hyprCfgDir}" ]; then
        echo "Backing up existing hyprpanel config from ${hyprCfgDir} to ${hyprCfgDir}.bak-${timestamp}"
        mv "${hyprCfgDir}" "${hyprCfgDir}.bak-${timestamp}"
      fi
    '';

    # 3) Instalar desde el repo en ~/.config/hyprpanel (sin symlinks; mantener RW)
    installHyprpanel = lib.hm.dag.entryAfter [ "backupHyprpanel" ] ''
      mkdir -p "${hyprCfgDir}"
      if [ -d "${repoHyprCfg}" ]; then
        echo "Copying managed hyprpanel config from ${repoHyprCfg} to ${hyprCfgDir} (no symlinks)"
        cp -r --no-preserve=all "${repoHyprCfg}/." "${hyprCfgDir}/" 2>/dev/null || true
        chmod -R u+w "${hyprCfgDir}"
      else
        echo "Warning: ${repoHyprCfg} not found. Skipping hyprpanel config copy."
      fi
    '';
  };

  # Mantener la población de .local/bin vía HM (symlinks válidos para scripts)
  home.file.".local/bin/" = {
    source = ./scripts;
    recursive = true;
  };
}
```

Por qué funciona bien:
- Puedes ajustar archivos en ~/.config/hyprpanel sin pensar en Nix.
- Un rebuild cosecha esos cambios al repo, te da un respaldo y reinstala la copia del repo.
- Puedes hacer commit/push de modules/home/hyprpanel para preservar lo que te guste.

---

## Consejos y barandillas opcionales

- Considera añadir un README pequeño en modules/home/hyprpanel explicando el flujo de copia de vuelta para contribuyentes.
- Si prefieres un archivo histórico, puedes tar la copia del repo (o el directorio activo) antes de cada sync/backup.
- Si algunos archivos nunca deben sobrescribirse desde el repo (p.ej., secretos por host), añade exclusiones en los cp y muestra una advertencia si existen.

---

## Resumen

- El módulo actual ya ofrece archivos escribibles copiando del repo a ~/.config/hyprpanel.
- Los cambios sugeridos añaden sincronización bidireccional y respaldos, igualando el patrón usado para el editor Zed.
- Este patrón evita el “reconstruir por cada pequeño ajuste” y ofrece una UX pragmática y amigable con Nix para trastear—ideal para setups personales donde la reproducibilidad estricta no es obligatoria.

