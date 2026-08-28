#!/usr/bin/env bash
source "$CONFIG_DIR/colors.sh"

# SSID via networksetup - `airport` is gone as of macOS 14.4.

SSID=$(networksetup -getairportnetwork en0 2>/dev/null | sed -n 's/^Current Wi-Fi Network: //p')

if [ -n "$SSID" ]; then
    sketchybar --set "$NAME" icon="" icon.color=$ACCENT label="$SSID"
else
    sketchybar --set "$NAME" icon="" icon.color=$COMMENT label="offline"
fi
