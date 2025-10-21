#!/usr/bin/env bash
# Generations feature module for zcli

generations_main() {
	echo "--- User Generations ---"
	nix-env --list-generations | cat || echo "Could not list user generations."
	echo ""
	echo "--- System Generations ---"
	nix profile history --profile /nix/var/nix/profiles/system | cat || echo "Could not list system generations."
}
