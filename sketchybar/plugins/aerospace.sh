#!/usr/bin/env bash
# Hebt den fokussierten AeroSpace-Workspace hervor. $1 = Workspace-ID.
# FOCUSED_WORKSPACE kommt vom Trigger; beim ersten Zeichnen fragen wir AeroSpace direkt.

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
