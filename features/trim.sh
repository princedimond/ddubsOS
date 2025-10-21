#!/usr/bin/env bash
# Trim feature module for zcli
# Requires FSTRIM_BIN from dispatcher

trim_main() {
	echo "Running 'sudo fstrim -v /' may take a few minutes and impact system performance."
	read -p "Enter (y/Y) to run now or enter to exit (y/N): " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		echo "Running fstrim..."
		sudo "$FSTRIM_BIN" -v /
		echo "fstrim complete."
	else
		echo "Trim operation cancelled."
	fi
}
