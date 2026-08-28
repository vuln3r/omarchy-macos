#!/usr/bin/env bash
# Ladestand + Symbol. Quelle: pmset (kein Zusatz-Tool noetig).

BATT=$(pmset -g batt)
PERCENT=$(echo "$BATT" | grep -Eo '[0-9]+%' | head -1 | tr -d '%')
CHARGING=$(echo "$BATT" | grep -c 'AC Power')

[ -z "$PERCENT" ] && exit 0

COLOR=0xffc1c497
if [ "$CHARGING" -eq 1 ]; then
    ICON=""
    COLOR=0xff63b07a
else
    case "${PERCENT}" in
        100|9[0-9]|8[0-9]) ICON="" ;;
        7[0-9]|6[0-9])     ICON="" ;;
        5[0-9]|4[0-9])     ICON="" ;;
        3[0-9]|2[0-9])     ICON="" ; COLOR=0xffe5c736 ;;
        *)                 ICON="" ; COLOR=0xffff5345 ;;
    esac
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="${PERCENT}%"
