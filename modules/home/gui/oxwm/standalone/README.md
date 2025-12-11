# OxWM Keybindings Helper (Standalone)

This directory contains a **portable** `oxwm-parser` script that can be used on
any Linux system running [OxWM](https://github.com/zsnmwy/oxwm) with minimal
dependencies.

The script parses your OxWM configuration and shows the keybindings either as a
formatted table in the terminal or in a `rofi` menu.

## Files

- `oxwm-parser` – Bash script, safe to copy to any Linux system
- `oxwm-keybinds.rasi` – Bundled rofi theme used by default when present
- `README.md` – This file

## Dependencies

You need the following commands available in your `$PATH`:

- `bash`
- `awk` (or `gawk`)
- `lua`
- `rofi`

The script automatically checks for these at startup and will print a helpful
error if something is missing.

## Installation

Example (user local install):

```bash
mkdir -p ~/.local/bin
cp oxwm-parser ~/.local/bin/
chmod +x ~/.local/bin/oxwm-parser

# (optional but recommended) install the bundled theme into your rofi config
mkdir -p "$HOME/.config/rofi"
cp oxwm-keybinds.rasi "$HOME/.config/rofi/oxwm-keybinds.rasi"
```

Make sure `~/.local/bin` is in your `$PATH`, e.g. in `~/.profile` or your shell
RC file.

## Config locations

By default the script looks for OxWM configs in:

- `$HOME/.config/oxwm/config.lua`
- `$HOME/.config/oxwm/config.ron`

It supports:

- RON configuration with `keybindings = [...]` (including keychords)
- Lua table-style configs (older OxWM templates)
- Imperative Lua configs (0.7+), via a stubbed `oxwm` Lua module

## Usage

Run without arguments to open a rofi menu:

```bash
oxwm-parser
```

Print the keybindings as an aligned table:

```bash
oxwm-parser --print
```

Show local help:

```bash
oxwm-parser --help
oxwm-parser -h
```

## Rofi menu / theme configuration

The script launches `rofi -dmenu` with reasonable defaults, but you can
customize the appearance via environment variables.

### Basic rofi controls

- `OXWM_ROFI_WIDTH_PCT` – Percent of screen width used by the window
  (default: `45`).
- `OXWM_ROFI_LINES` – Number of visible rows (listview lines) (default: `15`).
- `OXWM_ROFI_FONT` – Monospaced font passed via `-font` (default: `"monospace 11"`).

Example:

```bash
OXWM_ROFI_WIDTH_PCT=55 OXWM_ROFI_LINES=20 \
  OXWM_ROFI_FONT="JetBrainsMono Nerd Font 11" \
  oxwm-parser
```

### Custom rofi theme

This standalone package ships with a default theme file:

- `oxwm-keybinds.rasi` (in the same directory as `oxwm-parser`)

When you run `oxwm-parser` from that directory (or keep the script and theme
side-by-side), the bundled theme is used automatically.

You can override this in two ways:

1. Point `OXWM_ROFI_THEME` at any `.rasi` file or rofi theme:

   ```bash
   OXWM_ROFI_THEME="$HOME/.config/rofi/oxwm-keybinds.rasi" oxwm-parser
   ```

2. Copy the bundled theme to your user rofi config:

   ```bash
   mkdir -p "$HOME/.config/rofi"
   cp oxwm-keybinds.rasi "$HOME/.config/rofi/oxwm-keybinds.rasi"
   ```

If `OXWM_ROFI_THEME` is **not** set, the script first tries to use the bundled
`oxwm-keybinds.rasi` next to the script, then falls back to
`$HOME/.config/rofi/oxwm-keybinds.rasi` if that file exists. Otherwise rofi uses
its built-in defaults.

A minimal example theme (`oxwm-keybinds.rasi`):

```rasi
configuration {
  font: "monospace 11";
}

* {
  background:  #1e1e2e;
  foreground:  #cdd6f4;
  selected:    #89b4fa;
  border:      #45475a;
}

window {
  border:        1;
  padding:       8;
  width:         45%;
}

listview {
  lines:         15;
  columns:       1;
  spacing:       2;
}

element {
  padding:       2 4;
}

element-text {
  highlight:     bold;
}
```

### Column alignment controls

The script aligns the keybinding column and description column using an
approximation from pixels to spaces. You can tweak this if things look slightly
misaligned with your font:

- `OXWM_COL_GAP_PX` – Pixel gap between keybind and description columns
  (default: `10`).
- `OXWM_CHAR_PX` – Approximate character width in pixels used to translate the
  gap to spaces (default: `7`).
- `OXWM_EXTRA_SPACES` – Extra spaces appended after the calculated gap
  (default: `5`).

Example:

```bash
OXWM_COL_GAP_PX=16 OXWM_EXTRA_SPACES=2 oxwm-parser
```

## Binding in OxWM

You can bind the helper to a key in your OxWM config, for example
`Super+Alt+K`:

### Lua config example

```lua
oxwm.key.bind({ "Mod4", "Mod1" }, "K", oxwm.spawn({ "sh", "-c", "oxwm-parser" }))
```

### RON config example

```ron
(modifiers: [$modkey, $secondary_modkey], key: K,
 action: Spawn, arg: ["sh", "-c", "oxwm-parser"]),
```

Once installed, this makes `oxwm-parser` a portable helper for any OxWM user,
regardless of their distro or setup.
