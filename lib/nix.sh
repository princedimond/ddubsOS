#!/usr/bin/env bash
# Nix-related helpers for zcli
# Requires environment variables from dispatcher:
#   GREP, SED, HOSTNAME_BIN, FLAKE_NIX_PATH

# verify_hostname: Validates current hostname against flake.nix host variable
verify_hostname() {
	local current_hostname
	local flake_hostname

	current_hostname="$($HOSTNAME_BIN)"

	if [ -f "$FLAKE_NIX_PATH" ]; then
		# Extract only the first quoted host assignment (the let-bound value), ignoring
		# later unquoted occurrences like: specialArgs = { host = hostName; }.
		flake_hostname=$($GREP -E '^[[:space:]]*host[[:space:]]*=[[:space:]]*"' "$FLAKE_NIX_PATH" | $HEAD -n1 | $SED 's/.*=[[:space:]]*"\([^"]*\)".*/\1/')

		if [ -z "$flake_hostname" ]; then
			echo "Error: Could not find 'host' variable in $FLAKE_NIX_PATH" >&2
			exit 1
		fi

		if [ "$current_hostname" != "$flake_hostname" ]; then
			echo "Error: Hostname mismatch!" >&2
			echo "  Current hostname: '$current_hostname'" >&2
			echo "  Flake.nix host:   '$flake_hostname'" >&2
			echo "" >&2
			echo "Hint: Run 'zcli update-host' to automatically update flake.nix" >&2
			echo "      or manually edit $FLAKE_NIX_PATH" >&2
			exit 1
		fi
	else
		echo "Error: Flake.nix not found at $FLAKE_NIX_PATH" >&2
		exit 1
	fi

	# Also check if host folder exists
	local folder
	folder="$HOME/$PROJECT/hosts/$current_hostname"
	if [ ! -d "$folder" ]; then
		echo "Error: Matching host not found in $PROJECT, Missing folder: $folder" >&2
		exit 1
	fi
}

# ensure_accept_flag: Return extra flags to pass to nix via nh if needed
ensure_accept_flag() {
	if nix show-config 2>/dev/null | $GREP -q "^accept-flake-config = true$"; then
		echo "" # already enabled
	else
		echo " -- --accept-flake-config" # forward to nix via nh's separator
	fi
}
