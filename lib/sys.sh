#!/usr/bin/env bash
# System helpers for zcli
# Requires pinned tools provided by the dispatcher:
#   GREP, LSPCI, RM, HOSTNAME_BIN

handle_backups() {
	if [ ${#BACKUP_FILES[@]} -eq 0 ]; then
		echo "No backup files configured to check."
		return
	fi

	echo "Checking for backup files to remove..."
	for file_path in "${BACKUP_FILES[@]}"; do
		local full_path="$HOME/$file_path"
		if [ -f "$full_path" ]; then
			echo "Removing stale backup file: $full_path"
			"$RM" "$full_path"
		fi
	done
}

# detect_gpu_profile: infer GPU profile from lspci output
# Returns one of: nvidia, nvidia-laptop, amd-hybrid, amd, intel, vm, or empty

detect_gpu_profile() {
	local detected_profile=""
	local has_nvidia=false
	local has_intel=false
	local has_amd=false
	local has_vm=false

	if "$LSPCI" &>/dev/null; then
		if "$LSPCI" | "$GREP" -qi 'vga\|3d'; then
			while read -r line; do
				if echo "$line" | "$GREP" -qi 'nvidia'; then
					has_nvidia=true
				elif echo "$line" | "$GREP" -qi 'amd'; then
					has_amd=true
				elif echo "$line" | "$GREP" -qi 'intel'; then
					has_intel=true
				elif echo "$line" | "$GREP" -qi 'virtio\|vmware'; then
					has_vm=true
				fi
			done < <("$LSPCI" | "$GREP" -i 'vga\|3d')

			if "$has_vm"; then
				detected_profile="vm"
			elif "$has_nvidia" && "$has_intel"; then
				detected_profile="nvidia-laptop"
			elif "$has_nvidia" && "$has_amd"; then
				detected_profile="amd-hybrid"
			elif "$has_nvidia"; then
				detected_profile="nvidia"
			elif "$has_amd"; then
				detected_profile="amd"
			elif "$has_intel"; then
				detected_profile="intel"
			fi
		fi
	else
		echo "Warning: lspci command not found. Cannot auto-detect GPU profile." >&2
	fi
	echo "$detected_profile"
}
