#!/usr/bin/env bash
# Name der fokussierten App. $INFO kommt vom front_app_switched-Event.

if [ "$SENDER" = "front_app_switched" ]; then
    sketchybar --set "$NAME" label="$INFO"
fi
