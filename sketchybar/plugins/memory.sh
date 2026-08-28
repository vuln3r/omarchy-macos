#!/usr/bin/env bash
# RAM-Belegung wie im Aktivitaetsmonitor: aktiv + wired + komprimiert.
#
# ponytail: nicht die "free percentage" aus `memory_pressure` nehmen — die
# zaehlt inactive-Seiten als frei und meldet 54%, waehrend real 240 MB frei
# und 9 GB komprimiert sind. Bei LM Studio neben Xcode ist genau das der
# Unterschied zwischen "passt" und "der Mac swappt gleich".

source "$CONFIG_DIR/colors.sh"

PCT=$(vm_stat | awk -v total="$(sysctl -n hw.memsize)" '
    /page size of/           { ps = $8 }
    /Pages active/           { a  = $3 }
    /Pages wired down/       { w  = $4 }
    /occupied by compressor/ { c  = $5 }
    END { if (ps > 0 && total > 0) printf "%.0f", (a + w + c) * ps / total * 100 }')

[ -z "$PCT" ] && exit 0

case "$PCT" in
    100|9[0-9]|8[0-9]) COLOR=$RED ;;
    7[0-9]|6[0-9])     COLOR=$YELLOW ;;
    *)                 COLOR=$ACCENT ;;
esac

sketchybar --set "$NAME" icon="" icon.color="$COLOR" label="${PCT}%"
