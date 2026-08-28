#!/usr/bin/env bash
# Lautstaerke. $INFO kommt vom volume_change-Event; sonst per osascript nachfragen.

VOLUME="${INFO:-$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)}"
[ -z "$VOLUME" ] && exit 0

case "$VOLUME" in
    100|9[0-9]|8[0-9]|7[0-9]|6[0-9]) ICON="" ;;
    5[0-9]|4[0-9]|3[0-9])            ICON="" ;;
    2[0-9]|1[0-9])                   ICON="" ;;
    *)                               ICON="" ;;
esac

sketchybar --set "$NAME" icon="$ICON" label="${VOLUME}%"
