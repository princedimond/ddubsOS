#!/bin/bash
#
# Don Williams
# Script to write out ISO images to USB thumbdrive

# Usage: ./script.sh FILENAME.ISO DEVICE

ISO_FILE=$1
OUTPUT_DEVICE=$2

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)" 
   exit 1
fi

# Verify that both arguments are provided
if [ -z "$ISO_FILE" ] || [ -z "$OUTPUT_DEVICE" ]; then
  echo "Usage: $0 FILENAME.ISO DEVICE"
  exit 1
fi

# Check if the output device is mounted
if mount | grep $OUTPUT_DEVICE > /dev/null; then
  echo "Error: $OUTPUT_DEVICE is mounted. Please unmount it before proceeding."
  exit 1
fi

# Confirm the action with the user
read -p "Are you sure you want to write $ISO_FILE to $OUTPUT_DEVICE? This will erase all data on the device. (y/n): " confirmation
if [ "$confirmation" != "y" ]; then
  echo "Operation cancelled."
  exit 1
fi

# Execute the dd command
echo "Writing $ISO_FILE to $OUTPUT_DEVICE..."
dd if=$ISO_FILE of=$OUTPUT_DEVICE bs=4M status=progress oflag=sync

echo "Finished writing the ISO to $OUTPUT_DEVICE."

