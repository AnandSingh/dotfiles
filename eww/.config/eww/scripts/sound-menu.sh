#!/usr/bin/env bash
# fuzzel picker for the audio output: laptop speaker + any Sonos room discovered
# on the network. Routes via sound-sink.sh (which also makes the visualizer follow).
set -u
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
D="$(dirname "$(readlink -f "$0")")"

rooms="$(timeout 5 avahi-browse -rtp _airplay._tcp 2>/dev/null \
    | awk -F';' '$1=="=" && $3=="IPv4" { gsub(/\\032/," ",$4); print $4 }' | sort -u)"

choice="$(printf 'Laptop\n%s\n' "$rooms" | fuzzel --dmenu --prompt 'Audio → ')" || exit 0
[ -n "$choice" ] || exit 0

case "$choice" in
    Laptop) "$D/sound-sink.sh" laptop ;;
    *)      "$D/sound-sink.sh" "$choice" ;;
esac
