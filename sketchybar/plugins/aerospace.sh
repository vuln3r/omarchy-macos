#!/usr/bin/env bash
# Highlights the focused AeroSpace workspace. $1 = workspace ID.
# FOCUSED_WORKSPACE comes from the trigger; on the first draw we ask AeroSpace.

source "$CONFIG_DIR/colors.sh"

FOCUSED="${FOCUSED_WORKSPACE:-$(/opt/homebrew/bin/aerospace list-workspaces --focused 2>/dev/null)}"

if [ "$1" = "$FOCUSED" ]; then
    sketchybar --set "$NAME" background.drawing=on \
                             background.color=$ACCENT \
                             icon.color=$BG
else
    sketchybar --set "$NAME" background.drawing=off \
                             icon.color=$COMMENT
fi
