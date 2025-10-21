#!/usr/bin/env bash
# Argument parsing helpers for zcli
# parse_nh_args: parse flags and additional args for nh commands
# Usage: extra_args=$(parse_nh_args "$@")
parse_nh_args() {
	local args_string=""
	local options_selected=()
	shift # Remove the main command (rebuild, rebuild-boot, update)

	while [[ $# -gt 0 ]]; do
		case $1 in
		--dry | -n)
			args_string="$args_string --dry"
			options_selected+=("dry run mode (showing what would be done)")
			shift
			;;
		--ask | -a)
			args_string="$args_string --ask"
			options_selected+=("confirmation prompts enabled")
			shift
			;;
		--cores)
			if [[ -n $2 && $2 =~ ^[0-9]+$ ]]; then
				args_string="$args_string -- --cores $2"
				options_selected+=("limited to $2 CPU cores")
				shift 2
			else
				echo "Error: --cores requires a numeric argument" >&2
				return 1
			fi
			;;
		--verbose | -v)
			args_string="$args_string --verbose"
			options_selected+=("verbose output enabled")
			shift
			;;
		--no-nom)
			args_string="$args_string --no-nom"
			options_selected+=("nix-output-monitor disabled")
			shift
			;;
		--)
			shift
			args_string="$args_string -- $*"
			options_selected+=("additional arguments: $*")
			break
			;;
		-*)
			echo "Warning: Unknown flag '$1' - passing through to nh" >&2
			args_string="$args_string $1"
			options_selected+=("unknown flag '$1' passed through")
			shift
			;;
		*)
			echo "Error: Unexpected argument '$1'" >&2
			return 1
			;;
		esac
	done

	if [[ ${#options_selected[@]} -gt 0 ]]; then
		echo "Options selected:" >&2
		for option in "${options_selected[@]}"; do
			echo "  ✓ $option" >&2
		done
		echo >&2
	fi

	echo "$args_string"
}
