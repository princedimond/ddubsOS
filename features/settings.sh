#!/usr/bin/env bash
# Settings feature module for zcli (Phase 2 refactor)
# Expects pinned tools and environment from dispatcher:
#   GREP, SED, AWK, SORT, CP, DATE, BASENAME, HEAD, HOSTNAME_BIN, ZROOT_DIR
# Also expects color vars: SETTINGS_GREEN, SETTINGS_RED, SETTINGS_BOLD, SETTINGS_RESET
# And validators from lib/validate.sh: list_browsers, list_terminals, browser_supported, terminal_supported, etc.

# Settable string attributes for `zcli settings`
SETTABLE_STRING_ATTRS=(
	panelChoice browser terminal keyboardLayout consoleKeyMap stylixImage waybarChoice starshipChoice animChoice
)

list_string_attrs() {
	printf "%s\n" "${SETTABLE_STRING_ATTRS[@]}"
}

print_settings_help() {
	echo "Settings help"
	echo "-------------"
	echo "Use: zcli settings set <attr> <value>"
	echo
	echo "Requires app name or file path:"
	local string_entries=()
	for a in "${SETTABLE_STRING_ATTRS[@]}"; do
		string_entries+=("$a" "$(_string_attr_hint "$a")")
	done
	_settings_print_columns_text "${string_entries[@]}"
	echo
	echo "ON/OFF values:"
	if type -t list_bool_attrs >/dev/null 2>&1; then
		local bool_entries=()
		while IFS= read -r b; do
			[ -n "$b" ] || continue
			bool_entries+=("$b" "(ON/OFF)")
		done < <(list_bool_attrs | sort -u)
		_settings_print_columns_text "${bool_entries[@]}"
	else
		echo "  - (boolean list unavailable)"
	fi
	echo
	echo "Examples:"
	echo "  zcli settings set browser firefox"
	echo "  zcli settings set terminal kitty"
	echo "  zcli settings set enableWezterm true"
	echo "  zcli settings set stylixImage $HOME/ddubsos/wallpapers/your.jpg"
	echo "  zcli settings set consoleKeyMap us"
}

_settings_resolve_vars_file() {
	local current_hostname
	current_hostname="$($HOSTNAME_BIN)"
	local candidate="$ZROOT_DIR/hosts/$current_hostname/variables.nix"
	if [ -f "$candidate" ]; then
		echo "$candidate"
		return
	fi
	local fallback="$ZROOT_DIR/hosts/default/variables.nix"
	if [ -f "$fallback" ]; then
		echo "$fallback"
		return
	fi
	echo ""
}

_settings_get_raw() {
	# Usage: _settings_get_raw <file> <attr>
	# Returns the raw Nix value token for attr (e.g., true, false, "str", ../../path)
	local file="$1"
	shift
	local attr="$1"
	shift
	if [ ! -f "$file" ]; then
		echo ""
		return
	fi
	{ "$GREP" -E "^[[:space:]]*${attr}[[:space:]]*=" "$file" |
		"$SED" -E 's/.*=[[:space:]]*//; s/;.*$//; s/^[[:space:]]*//; s/[[:space:]]*$//' | "$HEAD" -n1; } 2>/dev/null || true
}

_settings_unquote() {
	local v="$1"
	if [[ "$v" == \"*\" && "$v" == *\" ]]; then
		v="${v:1:${#v}-2}"
	fi
	echo "$v"
}

_settings_on_off() {
	local v="$1"
	if [ "$v" = "true" ]; then
		printf "%bON %b" "$SETTINGS_GREEN" "$SETTINGS_RESET"
	else
		printf "%bOFF%b" "$SETTINGS_RED" "$SETTINGS_RESET"
	fi
}

_settings_basename() {
	local v
	v="$(_settings_unquote "$1")"
	v="${v%/}"
	"$BASENAME" -- "$v" 2>/dev/null || echo "$v"
}

_settings_print_columns() {
	local entries=("$@")
	local i=0
	while [ $i -lt ${#entries[@]} ]; do
		local l1="${entries[$i]}"
		local v1="${entries[$((i + 1))]}"
		i=$((i + 2))
		local l2=""
		local v2=""
		if [ $i -lt ${#entries[@]} ]; then
			l2="${entries[$i]}"
			v2="${entries[$((i + 1))]}"
			i=$((i + 2))
		fi
		local l3=""
		local v3=""
		if [ $i -lt ${#entries[@]} ]; then
			l3="${entries[$i]}"
			v3="${entries[$((i + 1))]}"
			i=$((i + 2))
		fi
		printf "  %-20s %s" "$l1:" "$(_settings_on_off "$v1")"
		if [ -n "$l2" ]; then printf "    %-20s %s" "$l2:" "$(_settings_on_off "$v2")"; fi
		if [ -n "$l3" ]; then printf "    %-20s %s" "$l3:" "$(_settings_on_off "$v3")"; fi
		printf "\n"
	done
}

# Determine terminal width
_term_width() {
	local w
	w=${COLUMNS:-}
	if [ -n "$w" ]; then echo "$w"; return; fi
	if command -v tput >/dev/null 2>&1; then
		w=$(tput cols 2>/dev/null || true)
		if [ -n "$w" ]; then echo "$w"; return; fi
	fi
	echo 80
}

# Print pairs (label, value) in 1-3 columns depending on terminal width
# Each column uses: label 16, value 22 (~39-41 chars with spacing)
_settings_print_columns_text() {
	local entries=("$@")
	local width=$(_term_width)
	local perRow=1
	if [ "$width" -ge 120 ]; then
		perRow=3
	elif [ "$width" -ge 80 ]; then
		perRow=2
	else
		perRow=1
	fi

	local i=0
	while [ $i -lt ${#entries[@]} ]; do
		local printed=0
		local j=0
		while [ $j -lt $perRow ] && [ $i -lt ${#entries[@]} ]; do
			local lbl="${entries[$i]}"; local val="${entries[$((i + 1))]}"
			i=$((i + 2))
			printf "  %-16s %-22s" "$lbl:" "$val"
			printed=1
			j=$((j + 1))
		done
		[ $printed -eq 1 ] && printf "\n"
	done
}

# Provide friendly example hints for string attributes
_string_attr_hint() {
	case "$1" in
		panelChoice) echo "left|right" ;;
		browser) echo "firefox|brave|google-chrome" ;;
		terminal) echo "kitty|wezterm|alacritty" ;;
		keyboardLayout) echo "us|de|fr|..." ;;
		consoleKeyMap) echo "us|de|fr|..." ;;
		stylixImage) echo "~/ddubsos/wallpapers/your.jpg" ;;
		waybarChoice) echo "default|compact|..." ;;
		starshipChoice) echo "starship.nix|starship-1.nix|starship-rbmcg.nix" ;;
		animChoice) echo "default|none|..." ;;
		*) echo "value" ;;
	esac
}

_settings_resolve_host_vars_file() {
	local current_hostname
	current_hostname="$($HOSTNAME_BIN)"
	local f="$ZROOT_DIR/hosts/$current_hostname/variables.nix"
	if [ -f "$f" ]; then echo "$f"; else echo ""; fi
}

_settings_backup_file() {
	local file="$1"
	local ts
	ts="$($DATE +%Y%m%d-%H%M%S)"
	local backup="${file}.bak-${ts}"
	"$CP" -f -- "$file" "$backup"
	echo "$backup"
}

_settings_quote() {
	local v="$1"
	printf '"%s"' "$v"
}

_settings_write_attr_value() {
	local file="$1"
	shift
	local attr="$1"
	shift
	local value="$1"
	shift
	if "$GREP" -Eq "^[[:space:]]*${attr}[[:space:]]*=" "$file"; then
		"$SED" -i "s|^[[:space:]]*${attr}[[:space:]]*=.*;|  ${attr} = ${value};|" "$file"
	else
		echo "" >>"$file"
		echo "  # Added by zcli on $($DATE)" >>"$file"
		echo "  ${attr} = ${value};" >>"$file"
	fi
}

normalize_bool() {
	local v="${1:-}"
	v="${v,,}"
	case "$v" in
		true|on|yes|1) echo true; return 0 ;;
		false|off|no|0) echo false; return 0 ;;
		*) return 1 ;;
	esac
}


settings_set_main() {
	local attr="$1"
	shift
	local value="$1"
	shift
	local dry_run=false
	while [[ $# -gt 0 ]]; do
		case "$1" in
		--dry-run | -n)
			dry_run=true
			shift
			;;
		*)
			echo "Error: Unknown flag '$1' for settings set" >&2
			return 1
			;;
		esac
	done

	verify_hostname
	local vars_file
	vars_file="$(_settings_resolve_host_vars_file)"
	if [ -z "$vars_file" ]; then
		echo "Error: Host-specific variables.nix not found; refusing to write to default." >&2
		return 1
	fi

	local is_bool=false
	local is_path=false

	case "$attr" in
	browser)
		if ! browser_supported "$value"; then
			echo "Error: Unsupported browser key '$value'. Use: zcli settings --list-browsers" >&2
			return 1
		fi
		# Guardrail: require browser command to be installed before accepting the change
		if type -t browser_cmd_for >/dev/null 2>&1 && type -t is_cmd_available >/dev/null 2>&1; then
			cmd="$(browser_cmd_for "$value" || true)"
			if [ -n "$cmd" ] && ! is_cmd_available "$cmd"; then
				echo "Error: Browser '$value' is not installed (missing command '$cmd'). Please install it first, then re-run: zcli settings set browser $value" >&2
				return 1
			fi
		fi
		;;
	terminal)
		if ! terminal_supported "$value"; then
			echo "Error: Unsupported terminal key '$value'. Use: zcli settings --list-terminals" >&2
			return 1
		fi
		if [ "$value" != "kitty" ] && type -t maybe_warn_kitty_absent >/dev/null 2>&1; then
			maybe_warn_kitty_absent || true
		fi
		;;
	stylixImage | waybarChoice | starshipChoice | animChoice)
		if [ -f "$value" ]; then :; else
			if [ -f "$ZROOT_DIR/$value" ]; then value="$ZROOT_DIR/$value"; elif [ -f "$HOME/$value" ]; then value="$HOME/$value"; fi
		fi
		if [ ! -f "$value" ]; then
			echo "Error: File not found for $attr: $value" >&2
			return 1
		fi
		is_path=true
		;;
	panelChoice | keyboardLayout | consoleKeyMap) ;;
gnomeEnable | bspwmEnable | dwmEnable | wayfireEnable | cosmicEnable | \
	enableEvilhelix | enableVscode | enableMicro | enableAlacritty | enableTmux | enablePtyxis | enableWezterm | enableGhostty | \
	enableDevEnv | sddmWaylandEnable | enableOpencode | enableObs | clock24h | enableNFS | printEnable | thunarEnable | \
	enableGlances)
		local norm
		norm="$(normalize_bool "$value")" || { echo "Error: Invalid boolean value for $attr: $value (use true/false, on/off, yes/no, 1/0)" >&2; return 1; }
		value="$norm"
		is_bool=true
		;;
	*)
		echo "Error: Unsupported attribute '$attr'" >&2
		return 1
		;;
	esac

	local rendered
	if [ "$is_bool" = true ]; then
		rendered="$value"
	elif [ "$is_path" = true ]; then
		# Write as a Nix path (unquoted) so it can be used in imports or file options
		rendered="$value"
	else
		rendered="$(_settings_quote "$value")"
	fi

	echo "Target file: $vars_file"
	echo "Set: $attr = $rendered;"

	if "$dry_run"; then
		echo "--dry-run: no changes written"
		return 0
	fi

	local backup
	backup="$(_settings_backup_file "$vars_file")"
	echo "Backup created: $backup"

	_settings_write_attr_value "$vars_file" "$attr" "$rendered"

	# Post-write guardrails for related toggles
	if [ "$attr" = "terminal" ]; then
		case "$value" in
			alacritty)
				current="$(_settings_get_raw "$vars_file" enableAlacritty)"
				if [ "$current" != "true" ]; then
					if "$dry_run"; then
						echo "--dry-run: would also enable enableAlacritty = true;"
					else
						_settings_write_attr_value "$vars_file" enableAlacritty true
						echo "✔ Also enabled enableAlacritty"
					fi
				fi
				;;
			ptyxis)
				current="$(_settings_get_raw "$vars_file" enablePtyxis)"
				if [ "$current" != "true" ]; then
					if "$dry_run"; then
						echo "--dry-run: would also enable enablePtyxis = true;"
					else
						_settings_write_attr_value "$vars_file" enablePtyxis true
						echo "✔ Also enabled enablePtyxis"
					fi
				fi
				;;
			wezterm)
				current="$(_settings_get_raw "$vars_file" enableWezterm)"
				if [ "$current" != "true" ]; then
					if "$dry_run"; then
						echo "--dry-run: would also enable enableWezterm = true;"
					else
						_settings_write_attr_value "$vars_file" enableWezterm true
						echo "✔ Also enabled enableWezterm"
					fi
				fi
				;;
			ghostty)
				current="$(_settings_get_raw "$vars_file" enableGhostty)"
				if [ "$current" != "true" ]; then
					if "$dry_run"; then
						echo "--dry-run: would also enable enableGhostty = true;"
					else
						_settings_write_attr_value "$vars_file" enableGhostty true
						echo "✔ Also enabled enableGhostty"
					fi
				fi
				;;
			*) : ;;
		esac
	fi

	local new_val
	new_val="$(_settings_unquote "$(_settings_get_raw "$vars_file" "$attr")")"
	if [ "$new_val" = "$value" ]; then
		echo "✔ Updated $attr successfully"
		return 0
	else
		echo "Warning: Post-write verification mismatch for $attr (found '$new_val')" >&2
		return 1
	fi
}

settings_view_main() {
	verify_hostname
	local vars_file
	vars_file="$(_settings_resolve_vars_file)"
	if [ -z "$vars_file" ]; then
		echo "Error: Could not locate variables.nix for this host or default." >&2
		return 1
	fi

	echo "${SETTINGS_BOLD}Host settings from:${SETTINGS_RESET} $vars_file"
	echo

	local panelChoice browser terminal keyboardLayout consoleKeyMap
	panelChoice="$(_settings_unquote "$(_settings_get_raw "$vars_file" panelChoice)")"
	browser="$(_settings_unquote "$(_settings_get_raw "$vars_file" browser)")"
	terminal="$(_settings_unquote "$(_settings_get_raw "$vars_file" terminal)")"
	keyboardLayout="$(_settings_unquote "$(_settings_get_raw "$vars_file" keyboardLayout)")"
	consoleKeyMap="$(_settings_unquote "$(_settings_get_raw "$vars_file" consoleKeyMap)")"

	local stylixImage waybarChoice starshipChoice animChoice
	stylixImage="$(_settings_basename "$(_settings_get_raw "$vars_file" stylixImage)")"
	waybarChoice="$(_settings_basename "$(_settings_get_raw "$vars_file" waybarChoice)")"
	starshipChoice="$(_settings_basename "$(_settings_get_raw "$vars_file" starshipChoice)")"
	animChoice="$(_settings_basename "$(_settings_get_raw "$vars_file" animChoice)")"

	local monitors
	monitors="$({ "$GREP" -E '^[[:space:]]*monitor[[:space:]]*=' "$vars_file" | "$SED" -E 's/^[[:space:]]*//'; } 2>/dev/null || true)"

	local enableGlances gnomeEnable bspwmEnable dwmEnable wayfireEnable cosmicEnable
local enableEvilhelix enableVscode enableMicro enableAlacritty enableTmux enablePtyxis enableWezterm enableGhostty
	local enableDevEnv sddmWaylandEnable enableOpencode enableObs clock24h enableNFS printEnable thunarEnable
	enableGlances="$(_settings_get_raw "$vars_file" enableGlances)"
	gnomeEnable="$(_settings_get_raw "$vars_file" gnomeEnable)"
	bspwmEnable="$(_settings_get_raw "$vars_file" bspwmEnable)"
	dwmEnable="$(_settings_get_raw "$vars_file" dwmEnable)"
	wayfireEnable="$(_settings_get_raw "$vars_file" wayfireEnable)"
	cosmicEnable="$(_settings_get_raw "$vars_file" cosmicEnable)"
	enableEvilhelix="$(_settings_get_raw "$vars_file" enableEvilhelix)"
	enableVscode="$(_settings_get_raw "$vars_file" enableVscode)"
	enableMicro="$(_settings_get_raw "$vars_file" enableMicro)"
	enableAlacritty="$(_settings_get_raw "$vars_file" enableAlacritty)"
	enableTmux="$(_settings_get_raw "$vars_file" enableTmux)"
enablePtyxis="$(_settings_get_raw "$vars_file" enablePtyxis)"
enableWezterm="$(_settings_get_raw "$vars_file" enableWezterm)"
	enableGhostty="$(_settings_get_raw "$vars_file" enableGhostty)"
	enableDevEnv="$(_settings_get_raw "$vars_file" enableDevEnv)"
	sddmWaylandEnable="$(_settings_get_raw "$vars_file" sddmWaylandEnable)"
	enableOpencode="$(_settings_get_raw "$vars_file" enableOpencode)"
	enableObs="$(_settings_get_raw "$vars_file" enableObs)"
	clock24h="$(_settings_get_raw "$vars_file" clock24h)"
	enableNFS="$(_settings_get_raw "$vars_file" enableNFS)"
	printEnable="$(_settings_get_raw "$vars_file" printEnable)"
	thunarEnable="$(_settings_get_raw "$vars_file" thunarEnable)"

	echo "${SETTINGS_BOLD}Desktop Environments${SETTINGS_RESET}"
	_settings_print_columns \
		"gnomeEnable" "$gnomeEnable" \
		"bspwmEnable" "$bspwmEnable" \
		"dwmEnable" "$dwmEnable" \
		"wayfireEnable" "$wayfireEnable" \
		"cosmicEnable" "$cosmicEnable"
	echo

	echo "${SETTINGS_BOLD}Editors & Terminals${SETTINGS_RESET}"
	_settings_print_columns \
		"enableEvilhelix" "$enableEvilhelix" \
		"enableVscode" "$enableVscode" \
		"enableMicro" "$enableMicro" \
		"enableAlacritty" "$enableAlacritty" \
		"enableTmux" "$enableTmux" \
"enablePtyxis" "$enablePtyxis" \
		"enableWezterm" "$enableWezterm" \
		"enableGhostty" "$enableGhostty"
	echo

	echo "${SETTINGS_BOLD}System & Services${SETTINGS_RESET}"
	_settings_print_columns \
		"enableDevEnv" "$enableDevEnv" \
		"enableOpencode" "$enableOpencode" \
		"enableObs" "$enableObs" \
		"sddmWaylandEnable" "$sddmWaylandEnable" \
		"enableNFS" "$enableNFS" \
		"printEnable" "$printEnable" \
		"thunarEnable" "$thunarEnable" \
		"clock24h" "$clock24h"
	echo

	echo "${SETTINGS_BOLD}Defaults & Panel${SETTINGS_RESET}"
	printf "  %-20s %s\n" "panelChoice:" "$panelChoice"
	printf "  %-20s %s\n" "browser:" "$browser"
	printf "  %-20s %s\n" "terminal:" "$terminal"
	printf "  %-20s %s\n" "keyboardLayout:" "$keyboardLayout"
	printf "  %-20s %s\n" "consoleKeyMap:" "$consoleKeyMap"
	echo

	echo "${SETTINGS_BOLD}Appearance & Animations${SETTINGS_RESET}"
	printf "  %-20s %s\n" "stylixImage:" "$stylixImage"
	printf "  %-20s %s\n" "waybarChoice:" "$waybarChoice"
	printf "  %-20s %s\n" "starshipChoice:" "$starshipChoice"
	printf "  %-20s %s\n" "animChoice:" "$animChoice"
	echo

	if [ -n "$monitors" ]; then
		echo "${SETTINGS_BOLD}Monitor Setup${SETTINGS_RESET}"
		printf "  %s\n" "$monitors" | sed 's/^/  /'
		echo
	fi

	# Locations for appearance attributes (trimmed to repo-relative path)
	local _display_root
	_display_root="${ZROOT_DIR#$HOME/}"
	echo "  (Location: stylixImage -> $_display_root/wallpapers)"
	echo "  (Location: waybarChoice -> $_display_root/modules/home/waybar)"
	echo "  (Location: starshipChoice -> $_display_root/modules/home/cli)"
	echo "  (Location: animChoice -> $_display_root/modules/home/hyprland)"
	echo
}

settings_main() {
	# Drop the primary command name if present (settings or features)
	if [ "${1-}" = "settings" ] || [ "${1-}" = "features" ]; then shift; fi

	# Subcommands / options
	if [ "$#" -ge 1 ]; then
		case "$1" in
		--list-browsers)
			if type -t list_browsers >/dev/null 2>&1; then
				list_browsers
			else
				echo "No curated browsers list available." >&2
				return 1
			fi
			return 0
			;;
		--list-terminals)
			if type -t list_terminals >/dev/null 2>&1; then
				list_terminals
			else
				echo "No curated terminals list available." >&2
				return 1
			fi
			return 0
			;;
		help)
			print_settings_help
			return 0
			;;
		set)
			if [ "$#" -lt 3 ]; then
				echo "Usage: zcli settings set <attr> <value> [--dry-run]" >&2
				return 1
			fi
			local attr="$2"
			local value="$3"
			shift 3
			settings_set_main "$attr" "$value" "$@"
			return $?
			;;
		esac
	fi

	# Default: show view
	settings_view_main
}
