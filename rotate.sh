#!/bin/bash

#    rotate.sh - display rotation script for notebooks with touchscreens like Thinkpad Helix and others
#    Copyright (C) 2017-2019 Björn Knorr - netaddict.de

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

# Description:
# Use one of the following arguments: [normal, left, right, inverted].
# If you don't supply an argument, it will use the last orientation from the ~/.rotationstate 
# file, so you may call this script in your .xinitrc or autostart to set the display orientation to the last state

# Usage:
# rotate.sh normal
# rotate.sh left
# rotate.sh inverted
# rotate.sh right
#
# You may create shortcuts with this commands on your desktop or desktop menu



# ---- configure the following variables to your needs

# input devices to rotate - find your devices with the "xinput" command
WACOMPEN1="Wacom HID 5077 Pen stylus"
WACOMPEN2="Wacom HID 5077 Pen eraser"
TOUCHSCREEN='Wacom HID 5077 Finger touch'
TOUCHPAD='Synaptics TM3203-003'
TRACKPOINT='TPPS/2 IBM TrackPoint'

# display to rotate - find your active display with the "xrandr" command (look for the "connected" device)
TOUCHDISPLAY='eDP-1'

# -----------------------------------------------------



# read rotation status file
CONFIGFILE=~/.rotationstate
if [[ -f "$CONFIGFILE" ]]; then
	STATUS=`cat "$CONFIGFILE" |head -n1`
else
	STATUS='normal'
	touch "$CONFIGFILE"
	echo "$STATUS" > "$CONFIGFILE"
fi

# transformation matrix
MATRIXRIGHT="0 1 0 -1 0 1 0 0 1"
MATRIXLEFT="0 -1 1 1 0 0 0 0 1"
MATRIXINVERTED="-1 0 1 0 -1 1 0 0 1"
MATRIXNORMAL="1 0 0 0 1 0 0 0 1"

# rotation input decives function
function rotate_inputdevices {
	[ ! -z "$WACOMPEN1" ] && xinput set-prop "$WACOMPEN1" "Coordinate Transformation Matrix" $1
	[ ! -z "$WACOMPEN2" ] && xinput set-prop "$WACOMPEN2" "Coordinate Transformation Matrix" $1
	[ ! -z "$TOUCHSCREEN" ] && xinput set-prop "$TOUCHSCREEN" "Coordinate Transformation Matrix" $1
	[ ! -z "$TOUCHPAD" ] && xinput set-prop "$TOUCHPAD" "Coordinate Transformation Matrix" $1
	[ ! -z "$TRACKPOINT" ] && xinput set-prop "$TRACKPOINT" "Coordinate Transformation Matrix" $1
}

# rotate according to command if set - else rotate according to state file
if [ -n "$1" ]
	then
		STATUS=$1
fi

case "$STATUS" in
		
	normal)		MATRIX=$MATRIXNORMAL;;
	left)		MATRIX=$MATRIXLEFT;;
	inverted)	MATRIX=$MATRIXINVERTED ;;
	right)		MATRIX=$MATRIXRIGHT;;
	*)			echo "Use one of the following arguments: [normal, left, right, inverted]." && exit 0
	esac

	#rotate input devices
	rotate_inputdevices "$MATRIX"

	#rotate display
	xrandr --output "$TOUCHDISPLAY" --rotate "$STATUS"

	#write status to state file
	echo "$STATUS" > $CONFIGFILE	

exit 0
