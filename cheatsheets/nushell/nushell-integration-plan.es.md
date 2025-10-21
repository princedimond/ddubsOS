[English](./nushell-integration-plan.md) | Español

# Plan de Integración de Nushell (para ddubsOS)
Audiencia: futuro asistente de IA y mantenedores. Este documento captura el contexto exacto del repositorio, las referencias a archivos y los pasos/código concretos necesarios para integrar Nushell (nu) como un shell de primera clase y seleccionable junto con zsh/bash/fish.

## Lista de Tareas

- [ ] Añadir `shellChoice = "zsh";` a `hosts/default/variables.nix`
- [ ] Actualizar `modules/home/default.nix` con importaciones condicionales de shell basadas en `shellChoice`
- [ ] Crear `modules/home/shells/nushell.nix` con:
  - [ ] Configuración del programa Nushell
  - [ ] Alias de eza (ls, ll, la, tree, d, dir)
  - [ ] Funciones de zoxide (zi interactivo, z directo)
  - [ ] Integración del prompt de Starship
- [ ] Actualizar los envoltorios de fastfetch (`modules/home/scripts/ff*.nix`) para detectar Nushell
- [ ] Revisar las configuraciones de shell existentes para paridad:
  - [ ] `modules/home/zsh/zshrc-personal`
  - [ ] `modules/home/zsh/default.nix`
  - [ ] `modules/home/shells/eza.nix`
- [ ] Probar en un host estableciendo `shellChoice = "nushell"`
- [ ] Validar que los alias de eza, las funciones de zoxide y el prompt de Starship funcionen en Nushell
- [ ] Confirmar que fastfetch muestra "nu" como shell cuando se ejecuta desde Nushell

## Resumen

- Objetivo: Añadir Nushell como un shell opcional, integrado de manera similar a los shells existentes, controlado por host a través de una variable de host. Preservar las convenciones existentes de eza y zoxide.
- NO cambiar el comportamiento ahora; este es un plan listo para ejecutar.

## Referencias relevantes del repositorio (en el momento de la redacción)

- Patrón de variables de host:
  - hosts/default/variables.nix
  - hosts/<host>/variables.nix (ej., hosts/ixas/variables.nix)
- Orquestación de importación de home:
  - modules/home/default.nix
- Módulos de shell actuales:
  - modules/home/zsh/default.nix
  - modules/home/zsh/zshrc-personal.nix
  - modules/home/shells/bash.nix
  - modules/home/shells/bashrc-personal.nix
  - modules/home/shells/fish.nix
  - modules/home/shells/zoxide.nix
  - modules/home/shells/eza.nix
- Fragmentos de CLI compartidos:
  - modules/home/cli/fzf.nix (fzf presente)
  - modules/home/cli/default.nix (importa fastfetch, fzf, git, etc.)
- Envoltorios de Fastfetch (ya conscientes del shell):
  - modules/home/scripts/ff.nix
  - modules/home/scripts/ff1.nix
  - modules/home/scripts/ff2.nix

## Diseño de alto nivel

1. Añadir una variable de host `shellChoice = "zsh" | "bash" | "fish" | "nushell"`.
2. Actualizar `modules/home/default.nix` para importar condicionalmente el módulo de shell correcto basado en `shellChoice`.
3. Crear un nuevo `modules/home/shells/nushell.nix` que:
   - Habilite Nushell a través de Home Manager.
   - Añada alias nativos de Nushell que reflejen los alias de eza utilizados en otros shells.
   - Añada funciones de Nushell para la usabilidad de zoxide (zi interactivo, z básico), reflejando tu experiencia de usuario con zoxide.
   - Opcional: integre el prompt de Starship en Nushell si se desea.
4. Opcionalmente, extender la detección de shell de los envoltorios `ff` para manejar explícitamente Nushell (nu) para que Fastfetch muestre `nu` cuando se invoque desde Nushell.

### Paso 1: Añadir variable de host

- En `hosts/default/variables.nix`, añade una nueva variable con un valor predeterminado seguro (no cambies otros hosts a menos que se desee):

```
shellChoice = "zsh";  # opciones: "zsh" | "bash" | "fish" | "nushell"
```

- Los hosts pueden anular esto en `hosts/<host>/variables.nix`, ej.:

```
shellChoice = "nushell";
```

### Paso 2: Conectar `shellChoice` en `modules/home/default.nix`

- El comportamiento actual importa todos los shells. Cambiar a importaciones condicionales impulsadas por `shellChoice`.
- Ejemplo de reemplazo para el bloque “# Shells” (ajusta las rutas según sea necesario):

```
# Antes: importando incondicionalmente los shells
#   ./shells/bash.nix
#   ./shells/bashrc-personal.nix
#   ./shells/eza.nix
#   ./shells/fish.nix
#   ./shells/zoxide.nix
#   ./zsh/default.nix
#   ./zsh/zshrc-personal.nix

# Después: importaciones condicionales
let
  inherit (import ../../hosts/${host}/variables.nix)
    shellChoice
    # ... herencias existentes
  ;

  shellImports =
    if shellChoice == "zsh" then [
      ./zsh/default.nix
      ./zsh/zshrc-personal.nix
      ./shells/eza.nix
      ./shells/zoxide.nix
    ] else if shellChoice == "bash" then [
      ./shells/bash.nix
      ./shells/bashrc-personal.nix
      ./shells/eza.nix
      ./shells/zoxide.nix
    ] else if shellChoice == "fish" then [
      ./shells/fish.nix
      ./shells/eza.nix
      ./shells/zoxide.nix
    ] else if shellChoice == "nushell" then [
      ./shells/nushell.nix
      ./shells/eza.nix
      ./shells/zoxide.nix
    ] else [
      # Alternativa (zsh) si se proporciona un valor no válido
      ./zsh/default.nix
      ./zsh/zshrc-personal.nix
      ./shells/eza.nix
      ./shells/zoxide.nix
    ];
in {
  imports = [
    # ... otras importaciones
  ] ++ shellImports
    # ... importaciones condicionales restantes ya presentes en este archivo
  ;
}
```

Notas:

- Mantenemos `eza.nix` y `zoxide.nix` en la lista por shell para asegurar que se carguen para cada shell elegido. Esto también mantiene el comportamiento de los alias globales consistente en los shells que respetan `home.shellAliases` (bash/zsh/fish). Nushell necesita sus propios alias (ver Paso 3).

### Paso 3: Crear `modules/home/shells/nushell.nix`

- Nuevo archivo: `modules/home/shells/nushell.nix`
- Proporcionar configuración de Nushell con alias de eza y ayudantes de zoxide. Home Manager soporta `programs.nushell`.

```
{ pkgs, ... }:
{
  programs.nushell = {
    enable = true;
    # Puedes añadir ajustes como: configFile.text o envFile.text si es necesario.
    # Usa extraConfig para ayudantes interactivos y alias.
    extraConfig = ''
      # =========================
      # alias de eza (Nushell)
      # =========================
      alias ls = eza
      alias ll = eza -a --no-user --long
      alias la = eza -lah
      alias tree = eza --tree
      alias d = eza -a --grid
      alias dir = eza -a --grid

      # =========================
      # ayudantes de zoxide (Nushell)
      # =========================
      # Selector interactivo (como tu "zi"), luego cd a la selección.
      def --env zi [] {
        let dest = ( ^${pkgs.zoxide}/bin/zoxide query -i )
        if ($dest | is-empty) == false { cd $dest }
      }

      # "z" básico para saltar directamente a la mejor coincidencia
      def --env z [ ...rest ] {
        let dest = ( ^${pkgs.zoxide}/bin/zoxide query -- $rest | lines | first )
        if ($dest | is-empty) == false { cd $dest }
      }

      # =========================
      # Opcional: prompt de Starship para Nushell
      # =========================
      # Si quieres el mismo prompt en todas partes, Home Manager puede gestionar
      # la configuración de Starship. Para Nushell específicamente, descomenta las líneas de abajo
      # para inicializar Starship en Nu:
      # let-env STARSHIP_SHELL = "nushell"
      # use std "path add"
      # let-env PROMPT_COMMAND = ( ^${pkgs.starship}/bin/starship init nu | from nuon )
      # let-env PROMPT_COMMAND_RIGHT = ""
    '';
  };

  # Opcional: configuración centralizada de Starship (compartida entre shells)
  programs.starship = {
    enable = true;
    # los ajustes pueden vivir en pkgs.writeText o a través de home.file si quieres un formato de prompt personalizado
    # compartido entre shells. Mantén las convenciones existentes del repositorio.
  };
}
```

Notas:

- Nushell no consume `home.shellAliases`, por lo que los alias deben definirse aquí en `extraConfig`.
- Las funciones de zoxide usan zoxide directamente; esto refleja tu experiencia de usuario deseada con "zi" sin depender de la inicialización automática de zoxide. Si prefieres el fragmento de inicialización oficial de Nu de zoxide más adelante, podemos cambiarlo.
- Si quieres direnv u otros ganchos por shell, se pueden añadir de manera similar.

### Paso 4 (opcional): Extender los envoltorios de fastfetch para reconocer Nushell

- Tus envoltorios actuales detectan el proceso padre y ejecutan fastfetch a través de ese shell (zsh, bash, fish). Añade un caso para Nushell:

```
# En modules/home/scripts/ff*.nix donde ocurre la detección de shell:
case "$parent_name" in
  *zsh*) shell="${pkgs.zsh}/bin/zsh" ;;
  *bash*) shell="${pkgs.bash}/bin/bash" ;;
  *fish*) shell="${pkgs.fish}/bin/fish" ;;
  *nu*|*nushell*) shell="${pkgs.nushell}/bin/nu" ;;
  *) shell="$(command -v "$parent_name" 2>/dev/null || true)" ;;
	esac
```

Esto asegura que Fastfetch informe “nu” cuando se invoque desde Nushell.

### Revisión de paridad de alias/funciones (asegurar una experiencia de usuario consistente)

- Revisa los siguientes archivos para reflejar los alias/funciones relevantes en Nushell donde sea posible:
  - ~/ddubsos/modules/home/zsh/zshrc-personal
  - ~/ddubsos/modules/home/zsh/default.nix
  - ~/ddubsos/modules/home/shells/eza.nix
- Notas:
  - zoxide está integrado en los shells actuales; `cdi` tiene un alias a `zi` en `eza.nix` por compatibilidad.
  - Replica comportamientos equivalentes en Nushell (alias/funciones anteriores) para que cambiar de shell preserve la memoria muscular.

### Pasos de validación (al implementar más tarde)

1. Elige un host y establece `shellChoice = "nushell"` en `hosts/<host>/variables.nix`.
2. Reconstruye Home Manager / sistema.
3. Abre una nueva sesión de Nu (`nu`) y valida:
   - alias de eza: ejecuta `ls/ll/la/tree`.
   - zoxide: ejecuta `zi` para invocar el salto interactivo; ejecuta `z nombre-directorio` para saltar directamente.
   - Si usas Starship: valida que el prompt se haya cargado.
4. Ejecuta `ff/ff1/ff2` dentro de Nushell y confirma que Fastfetch muestra el Shell como “nu”.

### Reversión / notas

- Para revertir, cambia `shellChoice` de nuevo a "zsh" (u otros) en las variables del host y reconstruye.
- No se cambia ningún comportamiento global hasta que selecciones explícitamente Nushell a través de `shellChoice`.

### Posibles dificultades / consideraciones

- La semántica de los alias de Nushell es diferente a la de bash/zsh; los alias proporcionados funcionan para los casos de uso comunes de eza.
- Si cambias el nombre del comando de zoxide globalmente (ej., `"--cmd cd"`), tu alias "zi" en `eza.nix` (`zi = "cdi"`) puede divergir del `zi` de Nu anterior. Las funciones de Nushell aquí usan zoxide directamente y no se ven afectadas por esa bandera global.
- Si quieres la integración oficial de Nu de zoxide en lugar de funciones personalizadas, podemos reemplazar las funciones con el script de inicialización de zoxide (requiere verificar las versiones actuales de zoxide para el fragmento exacto).
- Si quieres que Nushell sea el shell de inicio de sesión predeterminado del sistema, también necesitarás cambiar el shell del usuario en la configuración de usuario de NixOS. Este plan solo cubre el comportamiento y la configuración del shell interactivo de Home Manager.

### Resumen de las ediciones a realizar (cuando estés listo)

- `hosts/default/variables.nix`: añade `shellChoice = "zsh";` (y anula por host).
- `modules/home/default.nix`: importa `shellImports` condicionales basados en `shellChoice`.
- Crea `modules/home/shells/nushell.nix` con alias de eza, funciones de zoxide, y Starship opcional.
- Actualiza los envoltorios `ff` `~/ddubsos/modules/home/cli/fastfetch` para detectar y ejecutar a través de Nushell.

Fin del plan.
