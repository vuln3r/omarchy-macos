#!/usr/bin/env bash
# Volume. $INFO comes from the volume_change event, otherwise ask osascript.

VOLUME="${INFO:-$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)}"
[ -z "$VOLUME" ] && exit 0

case "$VOLUME" in
    100|9[0-9]|8[0-9]|7[0-9]|6[0-9]) ICON="" ;;
    [1-5][0-9])                      ICON="" ;;
    *)                               ICON="" ;;
esac

sketchybar --set "$NAME" icon="$ICON" label="${VOLUME}%"
