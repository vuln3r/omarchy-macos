#!/usr/bin/env bash
# Tailscale connection state.
#
# Read from scutil, not from `tailscale status`: scutil answers in ~45 ms
# without touching the daemon, and the network configuration is the thing we
# actually care about here. The bundle id is matched rather than the display
# name, because that name is user editable in the Tailscale app.
#
# ponytail: no distinction between "logged out" and "stopped" - both show as
# not connected, which is the only thing worth a glance in a status bar.

source "$CONFIG_DIR/colors.sh"

STATE=$(scutil --nc list 2>/dev/null | grep -F 'io.tailscale' | head -1)

# Tailscale not installed at all -> nothing to report.
if [ -z "$STATE" ]; then
    sketchybar --set "$NAME" drawing=off
    exit 0
fi

sketchybar --set "$NAME" drawing=on

case "$STATE" in
    *"(Connected)"*)
        sketchybar --set "$NAME" icon="󰕥" icon.color="$ACCENT" label="on"
        ;;
    *)
        sketchybar --set "$NAME" icon="󰦝" icon.color="$COMMENT" label="off"
        ;;
esac
