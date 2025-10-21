#!/usr/bin/env bash
# Diagnostics feature module for zcli
# Requires INXI_BIN (pinned) from dispatcher

diag_main() {
	echo "Generating system diagnostic report..."
	"$INXI_BIN" --full >"$HOME/diag.txt"
	echo "Diagnostic report saved to $HOME/diag.txt"
}
