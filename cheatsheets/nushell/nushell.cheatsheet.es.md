[English](./nushell.cheatsheet.md) | Español

# Nushell en ddubsOS — Resumen y Cheatsheet

## 🚀 ¿Qué es Nushell?
- Un shell moderno y estructurado donde los datos son tablas/registros en lugar de texto crudo.
- Las tuberías pasan datos tipados, habilitando filtrado, ordenación y formateo confiables.
- Multiplataforma, con comandos, plugins y configuración incluidos.

## 🌟 Destacados
- Tuberías tipadas: los comandos devuelven tablas/registros que puedes consultar con `where`, `select`, `get`, `sort-by`.
- Vistas enriquecidas: tablas legibles, salida tipo `ls` con estructura, `table -e` para expandido.
- Config en lenguaje Nu: define `alias`, funciones con `def`, y `env` en archivos `.nu`.
- Amigable entre shells: puedes invocar comandos externos fácilmente con `^cmd`.
- Excelente con herramientas que ya usas: eza, zoxide, git, ripgrep, fd, fzf.

---

## 🧭 Conceptos básicos

- Lanzar: `nu`
- Ayuda: `help`, `help commands`, `help <nombre>`
- Versión: `nu -v`
- Sistema de archivos: `ls`, `cd <ruta>`, `pwd`
- Leer archivo: `open <archivo>` (auto-parsea json/toml/yaml), `open -r <archivo>` para crudo
- Escribir archivo: `save <archivo>` o encadenar la tubería en `save`
- Variables: `let nombre = valor`, `let-env NOMBRE = "valor"`
- Ver entorno: `env`
- Externos: `^git status` (el circunflejo fuerza comando externo)

---

## 📦 Ejemplos de tuberías de datos

- Consulta JSON: `open package.json | get dependencies | transpose name version | sort-by name`
- CSV a tabla: `open data.csv | where status == active | select id name status`
- Contar archivos por extensión: `ls | where type == file | group-by extension | each { |it| { ext: $it.key, count: ($it.value | length) } } | sort-by count -r`
- Directorios más grandes: `ls -a | where type == dir | each { |d| { name: $d.name, size: (ls $d.name | where type == file | get size | math sum) } } | sort-by size -r | first 10`

---

## 🛠️ Tareas comunes

- Grep texto: `rg -n "patrón"` (externo) o `open archivo | find patrón`
- Buscar archivos: `fd "exp"` (externo), y luego encadenar a Nu: `^fd -t f | lines | where $it =~ "\.nix$"`
- Reemplazar en archivos: `sd "de" "a" archivo` (externo), o usa `str replace` por línea
- HTTP: `http get https://api.github.com/repos/... | get name stargazers_count`
- Lista de procesos: `ps | where name =~ "nu" | select pid name cpu mem`
- Matar: `kill <pid>` (externo), o `ps | where cpu > 80 | get pid | each { |p| ^kill -9 $p }`

---

## 🧩 Config en ddubsOS (planificado)

- Archivo de config: gestionado por Home Manager en `modules/home/shells/nushell.nix`.
- Alias: atajos de eza (ls, ll, la, tree, d, dir).
- Navegación: ayudantes de zoxide `zi` (interactivo) y `z` (salto rápido).
- Prompt: integración opcional de Starship compartida con otros shells.

---

## 🔁 Tabla de equivalencias zsh → Nushell

- Listar directorio
  - zsh: `ls -la`
  - nu: `ls -a | select name type size` (o con alias de eza: `la`)

- Subir de directorio
  - zsh: `cd ..`
  - nu: `cd ..`

- Exportar variable de entorno
  - zsh: `export FOO=bar`
  - nu: `let-env FOO = "bar"`

- Ver entorno
  - zsh: `env`
  - nu: `env`

- Alias
  - zsh: `alias gs='git status'`
  - nu: `alias gs = ^git status`

- Función
  - zsh:
    ```zsh
    z() { cd "$(zoxide query -i)" }
    ```
  - nu:
    ```nu
    def --env zi [] {
      let dest = ( ^zoxide query -i )
      if ($dest | is-empty) == false { cd $dest }
    }
    ```

- Grep (ripgrep)
  - zsh: `rg -n "foo" src`
  - nu: `^rg -n "foo" src`

- Buscar archivos (fd)
  - zsh: `fd ".*\.nix$"`
  - nu: `^fd ".*\.nix$"`

- Leer JSON y obtener un campo
  - zsh: `jq -r .name package.json`
  - nu: `open package.json | get name`

---

## 🧪 Consejos interactivos
- Convertir a tabla: añade `| table -e` para expandir registros profundos
- JSON bonito: `open file.json | to json --pretty 2`
- Unir líneas: `lines | str join ", "`
- Coincidencia regex: `where name =~ "foo.*bar"`
- Sin distinción de mayúsculas: `str contains -i`, `where name =~ '(?i)foo'`

---

## ⌨️ Atajos (REPL de Nu)
- Búsqueda en historial: Arriba/Abajo navega; `Ctrl+R` para búsqueda inversa (si se integra vía externo como fzf)
- Limpiar pantalla: `clear`
- Multilínea: Shift+Enter inserta nueva línea
- Editar buffer: a menudo `Ctrl+X Ctrl+E` si EDITOR es respetado (depende del entorno)

---

## 🔌 Ecosistema y plugins
- zoxide, eza, starship, fzf/fd/rg integran bien
- `nu -c` para ejecutar one-liners desde scripts
- Los scripts usan extensión `.nu` y se ejecutan con `nu script.nu`

---

## 🐛 Solución de problemas
- ¿Comando no encontrado? Anteponer `^` para externo (`^git`, `^cargo`).
- ¿Sorpresas al parsear? Usa `open -r` para bytes crudos y `from json`, `from toml` para parsear explícitamente.
- ¿Problemas de PATH? Revisa `env | where name =~ 'PATH'` y usa `path add`.

---

## 📚 Referencias
- Sitio oficial: https://www.nushell.sh
- Libro: https://www.nushell.sh/book/
- Comandos: `help commands`

