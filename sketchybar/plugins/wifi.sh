#!/usr/bin/env bash
source "$CONFIG_DIR/colors.sh"

# SSID via networksetup — `airport` gibt es seit macOS 14.4 nicht mehr.

SSID=$(networksetup -getairportnetwork en0 2>/dev/null | sed -n 's/^Current Wi-Fi Network: //p')

if [ -n "$SSID" ]; then
    sketchybar --set "$NAME" icon="" icon.color=$ACCENT label="$SSID"
else
    sketchybar --set "$NAME" icon="" icon.color=$COMMENT label="offline"
fi
