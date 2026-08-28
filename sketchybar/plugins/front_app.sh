#!/usr/bin/env bash
# Name of the focused app. $INFO comes from the front_app_switched event.

if [ "$SENDER" = "front_app_switched" ]; then
    sketchybar --set "$NAME" label="$INFO"
fi
