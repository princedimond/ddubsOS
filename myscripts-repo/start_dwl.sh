#!/bin/sh 
export WLR_DRM_NO_ATOMIC=1 
export WLR_NO_HARDWARE_CURSORS=1 
WLR_NO_HARDWARE_CURSORS=1  slstatus -s | dwl -s "sh -c 'swaybg -i ~/Pictures/wallpaper/Purple-Nightmare.jpg &'| wlr-randr --output Virtual-1 --custom-mode 1920x1080"

