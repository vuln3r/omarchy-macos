#!/usr/bin/env bash
# SSID via networksetup — `airport` gibt es seit macOS 14.4 nicht mehr.

SSID=$(networksetup -getairportnetwork en0 2>/dev/null | sed -n 's/^Current Wi-Fi Network: //p')

if [ -n "$SSID" ]; then
    sketchybar --set "$NAME" icon="" icon.color=0xff2dd5b7 label="$SSID"
else
    sketchybar --set "$NAME" icon="" icon.color=0xff53685b label="offline"
fi
