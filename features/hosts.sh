#!/usr/bin/env bash
# Hosts feature module for zcli (Phase 1 refactor)
# Requires pinned tool variables to be defined by the dispatcher:
#   GREP, SED, AWK, SORT, HOSTNAME_BIN, ZROOT_DIR
# Also relies on verify_hostname being available (from dispatcher or lib in later phases)

# Return the host-packages.nix path for the current host
_hosts_packages_file() {
	local f
	f="$ZROOT_DIR/hosts/$($HOSTNAME_BIN)/host-packages.nix"
	if [ -f "$f" ]; then
		echo "$f"
	else
		echo "" # not found
	fi
}

# List packages from host-packages.nix using an awk parser and stable sort
_hosts_list_packages() {
	local f="$1"
	if [ ! -f "$f" ]; then
		return 1
	fi
	"$AWK" '
    BEGIN{inlist=0}
    /environment\.systemPackages[[:space:]]*=[[:space:]]*with[[:space:]]+pkgs;[[:space:]]*\[/ {inlist=1; next}
    inlist==1 && /\];/ {inlist=0; exit}
    inlist==1 {
      line=$0
      sub(/#.*/, "", line)              # remove comments
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
      if (line != "") {
        # Accept simple identifiers possibly with dots/dashes/underscores
        if (line ~ /^[A-Za-z0-9._-]+$/) {
          print line
        }
      }
    }
  ' "$f" | "$SORT" -u
}

# Entrypoint: implements `zcli hosts-apps`
hosts_apps_main() {
	verify_hostname
	local hp_file
	hp_file="$(_hosts_packages_file)"
	if [ -z "$hp_file" ]; then
		echo "Error: host-packages.nix not found for host '$($HOSTNAME_BIN)'." >&2
		return 1
	fi
	echo "Host-specific packages (from $hp_file):"
	local pkgs_list
	pkgs_list="$(_hosts_list_packages "$hp_file")"
	if [ -n "$pkgs_list" ]; then
		echo "$pkgs_list" | sed 's/^/  - /'
	else
		echo "  (none found)"
	fi
}
