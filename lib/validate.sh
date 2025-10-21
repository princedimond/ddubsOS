#!/usr/bin/env bash
# Curated validators and mappers for zcli
# Hardcoded lists per request (no external file sourcing)
set -Eeuo pipefail

# Browsers: keys allowed in variables.nix
# Include both google-chrome and google-chrome-stable so validation matches typical values
BROWSERS=(
	"google-chrome"
	"google-chrome-stable"
	"firefox"
	"firefox-esr"
	"brave"
	"chromium"
	"vivaldi"
	"floorp"
)

list_browsers() {
	printf "%s\n" "${BROWSERS[@]}"
}

browser_supported() {
	local key="${1:-}"
	for b in "${BROWSERS[@]}"; do
		if [[ "$b" == "$key" ]]; then return 0; fi
	done
	return 1
}

# Map browser key to expected command name (for optional availability checks)
browser_cmd_for() {
	local key="${1:-}"
	case "$key" in
	google-chrome | google-chrome-stable) echo "google-chrome-stable" ;;
	firefox) echo "firefox" ;;
	firefox-esr) echo "firefox-esr" ;;
	brave) echo "brave-browser" ;;
	chromium) echo "chromium" ;;
	vivaldi) echo "vivaldi" ;;
	floorp) echo "floorp" ;;
	*)
		echo ""
		return 1
		;;
	esac
}

# Terminals: per request, only those represented in variables.nix toggles plus mandatory kitty.
# Note: kitty is mandatory (must be present in supported list) but doesn't have to be the default.
# tmux is intentionally excluded as it is not a terminal emulator.
TERMINALS=(
	"kitty"
	"ghostty"
	"alacritty"
	"ptyxis"
	"wezterm"
)

list_terminals() {
	printf "%s\n" "${TERMINALS[@]}"
}

terminal_supported() {
	local key="${1:-}"
	for t in "${TERMINALS[@]}"; do
		if [[ "$t" == "$key" ]]; then return 0; fi
	done
	return 1
}

terminal_cmd_for() {
	local key="${1:-}"
case "$key" in
	kitty | ghostty | alacritty | ptyxis | wezterm) echo "$key" ;;
	*)
		echo ""
		return 1
		;;
	esac
}

is_cmd_available() {
	command -v "$1" >/dev/null 2>&1
}

maybe_warn_kitty_absent() {
	if ! command -v kitty >/dev/null 2>&1; then
		echo "Warning: kitty is mandatory for the system but is not currently available in PATH." >&2
	fi
}

# Boolean attributes supported by zcli settings set <attr> <value>
# Keep this as the single source of truth; other modules should call list_bool_attrs
BOOL_ATTRS=(
	"gnomeEnable" "bspwmEnable" "dwmEnable" "wayfireEnable" "cosmicEnable"
	"enableEvilhelix" "enableVscode" "enableMicro" "enableAlacritty" "enableTmux" "enablePtyxis" "enableWezterm" "enableGhostty"
	"enableDevEnv" "sddmWaylandEnable" "enableOpencode" "enableObs" "clock24h" "enableNFS" "printEnable" "thunarEnable"
	"enableGlances"
)

list_bool_attrs() {
	# Print unique boolean attribute names, one per line
	# Using sort -u for safety in case of accidental duplicates in the array
	printf "%s\n" "${BOOL_ATTRS[@]}" | sort -u
}
