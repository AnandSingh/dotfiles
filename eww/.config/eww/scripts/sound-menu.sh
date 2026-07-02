#!/usr/bin/env bash
# fuzzel picker for the audio output: laptop speaker + every Sonos room that
# PipeWire currently has a raop sink for. Reads PipeWire (not live mDNS), so a
# room stays selectable even if its AirPlay mDNS ad lapsed. Routes via
# sound-sink.sh (which also makes the visualizer follow).
set -u
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
D="$(dirname "$(readlink -f "$0")")"

# room names = Description of each raop sink (dedup)
rooms="$(pactl list sinks 2>/dev/null | awk '
    /^[[:space:]]*Name: raop_sink/ { israop=1; next }
    /^[[:space:]]*Name: /          { israop=0 }
    israop && /^[[:space:]]*Description: / { d=$0; sub(/^[[:space:]]*Description: /,"",d); print d; israop=0 }
' | sort -u)"

choice="$(printf 'Laptop\n%s\n' "$rooms" | fuzzel --dmenu --prompt 'Audio → ')" || exit 0
[ -n "$choice" ] || exit 0

case "$choice" in
    Laptop) "$D/sound-sink.sh" laptop ;;
    *)      "$D/sound-sink.sh" "$choice" ;;
esac
