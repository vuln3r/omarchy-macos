#!/usr/bin/env bash
# Memory in use, the way Activity Monitor counts it: active + wired +
# compressed.
#
# ponytail: do NOT use the "free percentage" from `memory_pressure`. It counts
# inactive pages as free and reports 54% while only 240 MB are actually free
# and 9 GB sit in the compressor - the difference between "fine" and "about to
# start swapping".

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
