[English](./warp-terminal-current.md) | Español

# Módulo Warp Terminal (Actual) {#opt-programs.warp-terminal-current.enable}

Este módulo proporciona acceso a la versión actual/bleeding-edge de Warp Terminal, empaquetada directamente desde los lanzamientos más recientes.

Instala DOS ejecutables por separado:
- `warp-terminal` — Versión estable desde nixpkgs
- `warp-bld` — Versión bleeding-edge desde el paquete "actual" vendorizado (este repositorio)

## Resumen

- Paquete: `warp-terminal-current`
- Origen: Vendorizado en este repositorio en `pkgs/warp-terminal-current` (basado en los lanzamientos de Warp)
- Actualizaciones: Usa `zcli update-warp` (ver abajo) o los scripts locales
- Plataformas: x86_64-linux, aarch64-linux
- Licencia: No libre (propietaria)

## Uso

Habilita en tu configuración de ddubsos:

```nix
programs.warp-terminal-current = {
  enable = true;
  waylandSupport = true; # Predeterminado: true
};
```

### Ejemplo de personalización

```nix
programs.warp-terminal-current = {
  enable = true;
  waylandSupport = true;
  desktopName = "Warp-Dev";   # Nombre personalizado en el lanzador
  iconName = "warp-terminal"; # Usar el icono estándar en lugar del personalizado
};
```

## Opciones

- `programs.warp-terminal-current.enable`
  - Tipo: Booleano
  - Predeterminado: `false`
  - Descripción: Habilita la versión actual/bleeding-edge de Warp Terminal

- `programs.warp-terminal-current.waylandSupport`
  - Tipo: Booleano
  - Predeterminado: `true`
  - Descripción: Habilita soporte Wayland (exporta `WARP_ENABLE_WAYLAND=1`)

- `programs.warp-terminal-current.package`
  - Tipo: Paquete
  - Predeterminado: `pkgs.warp-bld`
  - Descripción: Paquete wrapper `warp-bld` (bleeding-edge; envuelve `pkgs.warp-terminal-current`) (permite overrides)

- `programs.warp-terminal-current.desktopName`
  - Tipo: Cadena
  - Predeterminado: `"Warp-bld"`
  - Descripción: Nombre mostrado en los lanzadores

- `programs.warp-terminal-current.iconName`
  - Tipo: Cadena
  - Predeterminado: `"warp-terminal-bld"`
  - Descripción: Nombre de icono para la aplicación

## Integración de Escritorio

Al habilitar, se crea:
- Dos ejecutables: `warp-terminal` (estable) y `warp-bld` (bleeding-edge)
- Entrada .desktop: "Warp-bld" (distinguible de la estable)
- Icono personalizado: `warp-terminal-bld` con indicadores visuales de bleeding-edge
- Lanzador GUI: aparece como "Warp-bld"
- Palabras clave: "terminal", "bleeding", "edge", "current"

## Actualizaciones

Flujo preferido (recomendado):
```bash
zcli update-warp          # actualiza versions.json vendorizado con hashes SRI verificados
zcli rebuild              # reconstruye para activar la versión actual nueva
```
- Opcional: añade --commit para hacer commit automático: `zcli update-warp --commit`

Alternativa (helpers directos):
```bash
scripts/update-warp-current.sh  # ejecuta el actualizador vendorizado
zcli rebuild
```

Solo verificación (sin reconstruir):
```bash
pkgs/warp-terminal-current/warp-latest.sh   # actualiza versions.json in-place
# Puedes hacer commit del cambio opcionalmente
```

## Diferencias respecto a Estable

- Estable (`warp-terminal`): Disponible en nixpkgs, ritmo de actualización de NixOS
- Actual (`warp-terminal-current`): Últimos lanzamientos upstream, actualizado cuando ejecutas el flujo anterior

## Solución de Problemas

- Fallos de compilación usuales:
  1. Problemas de red al descargar desde releases.warp.dev
  2. Hashes incorrectos (ejecuta `zcli update-warp` para recalcular SRI y actualizar)
  3. Licencia no libre no permitida (ddubsos la habilita en NixOS/Home Manager)

### Información de versión

Para comprobar la versión actual del paquete:
```bash
nix eval .#packages.x86_64-linux.warp-terminal-current.version
```
