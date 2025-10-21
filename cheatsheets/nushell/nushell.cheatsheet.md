English | [Español](./nushell.cheatsheet.es.md)

# Nushell on ddubsOS — Summary & Cheatsheet
## 🚀 What is Nushell?
- A modern, structured-shell where data is tables/records instead of raw text.
- Pipelines pass typed data, enabling reliable filtering, sorting, and formatting.
- Cross-platform, batteries-included commands, plugins, and config.

## 🌟 Highlights
- Typed pipelines: commands output tables/records you can query with `where`, `select`, `get`, `sort-by`.
- Rich viewers: pretty tables, `ls` style output with structure, `table -e` for expanded.
- Config in Nu language: define `alias`, `def` functions, and `env` in `.nu`.
- Cross-shell friendliness: can call external commands easily with `^cmd`.
- Great with tools you already use: eza, zoxide, git, ripgrep, fd, fzf.

---

## 🧭 Basics

- Launch: `nu`
- Help: `help`, `help commands`, `help <name>`
- Version: `nu -v`
- Filesystem: `ls`, `cd <path>`, `pwd`
- Read file: `open <file>` (auto-parses json/toml/yaml), `open -r <file>` for raw
- Write file: `save <file>` or pipeline into `save`
- Variables: `let name = value`, `let-env NAME = "value"`
- Show env: `env`
- External: `^git status` (caret forces external command)

---

## 📦 Data pipeline examples

- JSON query: `open package.json | get dependencies | transpose name version | sort-by name`
- CSV to table: `open data.csv | where status == active | select id name status`
- Count files by extension: `ls | where type == file | group-by extension | each { |it| { ext: $it.key, count: ($it.value | length) } } | sort-by count -r`
- Find largest dirs: `ls -a | where type == dir | each { |d| { name: $d.name, size: (ls $d.name | where type == file | get size | math sum) } } | sort-by size -r | first 10`

---

## 🛠️ Common tasks

- Grep text: `rg -n "pattern"` (external) or `open file | find pattern`
- Find files: `fd "expr"` (external), then pipe into Nu: `^fd -t f | lines | where $it =~ "\.nix$"`
- Replace in files: `sd "from" "to" file` (external), or use `str replace` per line
- HTTP: `http get https://api.github.com/repos/... | get name stargazers_count`
- Process list: `ps | where name =~ "nu" | select pid name cpu mem`
- Kill: `kill <pid>` (external), or `ps | where cpu > 80 | get pid | each { |p| ^kill -9 $p }`

---

## 🧩 Config on ddubsOS (planned)

- Config file: managed by Home Manager in `modules/home/shells/nushell.nix`.
- Aliases: eza shortcuts (ls, ll, la, tree, d, dir).
- Navigation: zoxide helpers `zi` (interactive) and `z` (quick jump).
- Prompt: optional Starship integration shared with other shells.

---

## 🔁 zsh → Nushell cheat table

- List directory
  - zsh: `ls -la`
  - nu: `ls -a | select name type size` (or with eza alias: `la`)

- Change directory up
  - zsh: `cd ..`
  - nu: `cd ..`

- Export env var
  - zsh: `export FOO=bar`
  - nu: `let-env FOO = "bar"`

- Show env
  - zsh: `env`
  - nu: `env`

- Alias
  - zsh: `alias gs='git status'`
  - nu: `alias gs = ^git status`

- Function
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

- Find files (fd)
  - zsh: `fd ".*\.nix$"`
  - nu: `^fd ".*\.nix$"`

- Read JSON and get field
  - zsh: `jq -r .name package.json`
  - nu: `open package.json | get name`

---

## 🧪 Interactive tips
- Pipe to table: add `| table -e` to expand deep records
- Pretty JSON: `open file.json | to json --pretty 2`
- Join lines: `lines | str join ", "`
- Regex match: `where name =~ "foo.*bar"`
- Case-insensitive: `str contains -i`, `where name =~ '(?i)foo'`

---

## ⌨️ Keybindings (Nu REPL basics)
- History search: Up/Down navigates; `Ctrl+R` for reverse search (if integrated via external like fzf)
- Clear screen: `clear`
- Multiline: Shift+Enter inserts newline
- Edit buffer: often `Ctrl+X Ctrl+E` if EDITOR is respected (depends on env)

---

## 🔌 Ecosystem & Plugins
- zoxide, eza, starship, fzf/fd/rg integrate well
- `nu -c` to run one-liners from scripts
- Scripts use `.nu` extension and can be run with `nu script.nu`

---

## 🐛 Troubleshooting
- Command not found? Prefix with `^` for external (`^git`, `^cargo`).
- Parsing surprises? Use `open -r` for raw bytes and `from json`, `from toml` to parse explicitly.
- Path issues? Check `env | where name =~ 'PATH'` and use `path add`.

---

## 📚 References
- Official site: https://www.nushell.sh
- Book: https://www.nushell.sh/book/
- Commands: `help commands`

