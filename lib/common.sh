#!/usr/bin/env bash
# Common library for zcli
# Sourced by the zcli dispatcher and feature modules
# Keep lightweight: no set -euo here as zcli already sets strict mode

INFO_ICON="ℹ"
WARN_ICON="⚠"
ERR_ICON="✗"
OK_ICON="✔"

log_info() { echo "${INFO_ICON} $*"; }
log_warn() { echo "${WARN_ICON} $*" >&2; }
log_err() { echo "${ERR_ICON} $*" >&2; }

# die prints an error and exits with non-zero status
# Usage: die "message" [code]
die() {
	local code=1
	if [ $# -ge 2 ]; then
		code="$2"
	fi
	log_err "$1"
	exit "$code"
}
