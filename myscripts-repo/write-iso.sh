#!/bin/bash


# Check if the input parameters are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <input_file> <destination_device>"
   lsblk -f
    exit 1
fi

input_file=$1
destination_device=$2

# Check if the destination device is mounted
if mount | grep $destination_device > /dev/null; then
    echo "Error: The destination device $destination_device is mounted. Please unmount it before proceeding."
    lsblk -f
    exit 1
fi

# Check if the destination device is the boot device
boot_device=$(df /boot | tail -1 | awk '{print $1}')
if [ "$destination_device" == "$boot_device" ]; then
    echo "Error: The destination device $destination_device is the boot device. Aborting to prevent overwriting the boot device."
    exit 1
fi

# Run dd command with the given parameters
sudo dd if="$input_file" of="$destination_device" oflag=sync bs=4M status=progress


