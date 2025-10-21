#!/usr/bin/env bash
# Rebuild/Update feature module for zcli (Phase 3)
# Expects functions and env from dispatcher + libs:
#   verify_hostname, ensure_accept_flag, parse_nh_args, handle_backups, PROFILE

# Optional pinned git from dispatcher; fall back to PATH git
: "${GIT_BIN:=git}"

# Collect untracked and unstaged files in the project repo
_collect_stage_candidates() {
	local repo="$HOME/$PROJECT"
	local line status path
	# Use --porcelain for stable parsing
	while IFS= read -r line; do
		status="${line:0:2}"
		path="${line:3}"
		# Include untracked (??) and anything with unstaged changes (second column not space)
		if [[ "$status" == "??" || "${status:1:1}" != " " ]]; then
			CANDIDATE_PATHS+=("$path")
			CANDIDATE_STATUS+=("$status")
		fi
	done < <("$GIT_BIN" -C "$repo" status --porcelain)
}

# Prompt user to stage selected files (or all). No-op if none.
_maybe_prompt_stage() {
	local repo="$HOME/$PROJECT"
	CANDIDATE_PATHS=()
	CANDIDATE_STATUS=()
	_collect_stage_candidates

	local count=${#CANDIDATE_PATHS[@]}
	if (( count == 0 )); then
		return 0
	fi

	echo "Untracked/unstaged files in $PROJECT:" >&2
	local i
	for (( i=0; i<count; i++ )); do
		printf "  [%d] %s  %s\n" "$((i+1))" "${CANDIDATE_STATUS[$i]}" "${CANDIDATE_PATHS[$i]}" >&2
	done
	printf "Select files to stage (e.g. 1 3 5, or 'all', or Enter to skip): " >&2
	local sel
	read -r sel

	# Skip if empty
	if [[ -z "$sel" ]]; then
		return 0
	fi

	# Stage all
	if [[ "$sel" == "all" ]]; then
		"$GIT_BIN" -C "$repo" add -A
		return 0
	fi

	# Normalize separators to spaces, then iterate
	sel=${sel//,/ }
	local idx files_to_stage=()
	for idx in $sel; do
		# Ensure numeric
		if [[ ! "$idx" =~ ^[0-9]+$ ]]; then
			printf "Ignoring invalid selection: %s\n" "$idx" >&2
			continue
		fi
		# Convert to 0-based
		local j=$((idx-1))
		if (( j < 0 || j >= count )); then
			printf "Index out of range: %s\n" "$idx" >&2
			continue
		fi
		files_to_stage+=("${CANDIDATE_PATHS[$j]}")
	done

	if (( ${#files_to_stage[@]} == 0 )); then
		return 0
	fi

	# Use add -A per-path to also record deletions where applicable
	local chunk
	for chunk in "${files_to_stage[@]}"; do
		"$GIT_BIN" -C "$repo" add -A -- "$chunk"
	done
}

_rebuild_run() {
	local mode="$1"
	shift
	local extra_args
	extra_args=$(parse_nh_args "$@") || return 1

	case "$mode" in
	switch)
		echo "Starting NixOS rebuild for host: $($HOSTNAME_BIN)"
		;;
	boot)
		echo "Starting NixOS rebuild (boot) for host: $($HOSTNAME_BIN)"
		echo "Note: Configuration will be activated on next reboot"
		;;
	update)
		echo "Updating flake and rebuilding system for host: $($HOSTNAME_BIN)"
		;;
	esac

	local accept_flags
	accept_flags="$(ensure_accept_flag)"

	local cmd
	case "$mode" in
	switch)
		cmd="nh os switch --hostname '$PROFILE' $extra_args$accept_flags"
		;;
	boot)
		cmd="nh os boot --hostname '$PROFILE' $extra_args$accept_flags"
		;;
	update)
		cmd="nh os switch --hostname '$PROFILE' --update $extra_args$accept_flags"
		;;
	esac

	if eval "$cmd"; then
		case "$mode" in
		switch) echo "Rebuild finished successfully" ;;
		boot)
			echo "Rebuild-boot finished successfully"
			echo "New configuration set as boot default - restart to activate"
			;;
		update) echo "Update and rebuild finished successfully" ;;
		esac
		return 0
	else
		case "$mode" in
		switch) echo "Rebuild Failed" >&2 ;;
		boot) echo "Rebuild-boot Failed" >&2 ;;
		update) echo "Update and rebuild Failed" >&2 ;;
		esac
		return 1
	fi
}

# Public entry to run the staging prompt as a standalone command
stage_main() {
	# Usage: zcli stage [--all]
	local mode="prompt"
	if [[ "${1:-}" == "--all" ]]; then
		mode="all"
	fi
	if [[ "$mode" == "all" ]]; then
		"$GIT_BIN" -C "$HOME/$PROJECT" add -A
		echo "Staged all untracked/unstaged changes in $PROJECT."
		return 0
	fi
	_maybe_prompt_stage
}

rebuild_main() {
	# $1 is one of: rebuild | rebuild-boot | update | upgrade
	local cmd="$1"
	shift

	# Extract staging behavior flags from the remaining args and strip them from what we pass to nh
	local STAGE_BEHAVIOR="prompt"
	local forward_args=()
	while [[ $# -gt 0 ]]; do
		case "$1" in
		--no-stage)
			STAGE_BEHAVIOR="skip"; shift ;;
		--stage-all)
			STAGE_BEHAVIOR="all"; shift ;;
		*)
			forward_args+=("$1"); shift ;;
		esac
	done

	# Verify we are acting on the correct host and project state
	verify_hostname

	# Apply staging behavior
	case "$STAGE_BEHAVIOR" in
		skip) : ;;
		all) "$GIT_BIN" -C "$HOME/$PROJECT" add -A ;;
		*) _maybe_prompt_stage ;;
	esac

	# Perform any requested backup file cleanup
	handle_backups

	case "$cmd" in
	rebuild)
		_rebuild_run switch "rebuild" "${forward_args[@]}"
		;;
	rebuild-boot)
		_rebuild_run boot "rebuild-boot" "${forward_args[@]}"
		;;
	update | upgrade)
		_rebuild_run update "update" "${forward_args[@]}"
		;;
	*)
		echo "Error: Unknown rebuild command '$cmd'" >&2
		return 1
		;;
	esac
}
