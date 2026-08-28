#!/usr/bin/env bash
# Volume. $INFO comes from the volume_change event, otherwise ask osascript.

VOLUME="${INFO:-$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)}"
[ -z "$VOLUME" ] && exit 0

# The percentage is known right away - show it before the slower device lookup.
sketchybar --set "$NAME" label="${VOLUME}%"

# Which device is playing? Bluetooth and USB count as headphones here; the
# 3.5mm jack reports as built-in and only gives itself away by name.
# ponytail: system_profiler costs ~0.3s per call. SwitchAudioSource -c is
# instant, but that is another formula to install for one icon.
OUTPUT=$(system_profiler SPAudioDataType -json 2>/dev/null | jq -r '
    first(.. | objects
          | select(.coreaudio_default_audio_output_device == "spaudio_yes"))
    | "\(.coreaudio_device_transport) \(._name)"')

case "$OUTPUT" in
    *bluetooth*|*usb*|*[Hh]eadphone*|*[Kk]opfh*|*AirPod*)
        ICON="" ;;
    *)
        case "$VOLUME" in
            100|9[0-9]|8[0-9]|7[0-9]|6[0-9]) ICON="" ;;
            [1-5][0-9])                      ICON="" ;;
            *)                               ICON="" ;;
        esac ;;
esac

sketchybar --set "$NAME" icon="$ICON"
