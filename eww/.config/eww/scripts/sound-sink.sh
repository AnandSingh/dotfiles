#!/usr/bin/env bash
# Route system audio to a Sonos room (by NAME — survives re-pairing / IP changes)
# or the laptop speaker, move any current streams, and keep the cava visualizer
# following the active sink.
#   sound-sink.sh Den
#   sound-sink.sh "Media Room"
#   sound-sink.sh laptop
set -u
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

target="${1:-}"
[ -n "$target" ] || { echo "usage: sound-sink.sh <room-name|laptop>"; exit 1; }

laptop_sink() { pactl list short sinks | awk '/HiFi__Speaker__sink/{print $2; exit}'; }

# room name -> current AirPlay IP (via mDNS, so re-paired coordinators resolve) ->
# the matching raop sink name.
sonos_sink() {
    local room="$1" ip
    ip="$(timeout 5 avahi-browse -rtp _airplay._tcp 2>/dev/null \
        | awk -F';' -v r="$room" '$1=="=" && $3=="IPv4" { gsub(/\\032/," ",$4); if ($4==r) { print $8; exit } }')"
    [ -n "$ip" ] || return 1
    pactl list short sinks | awk -v ip="$ip" 'index($2, ip".7000") {print $2; exit}'
}

case "$target" in
    laptop|Laptop|speaker) sink="$(laptop_sink)"; label="Laptop" ;;
    *)                     sink="$(sonos_sink "$target")"; label="$target" ;;
esac

if [ -z "${sink:-}" ]; then
    notify-send -u critical "Audio" "Output not found: $target" 2>/dev/null
    echo "output not found: $target" >&2
    exit 1
fi

pactl set-default-sink "$sink"
# move any currently-playing streams onto the new sink
for si in $(pactl list short sink-inputs 2>/dev/null | awk '{print $1}'); do
    pactl move-sink-input "$si" "$sink" 2>/dev/null || true
done
# cava follows the new default: kill it — eww's deflisten respawns it, and the
# fresh cava (source=auto) binds to the new default sink's monitor.
pkill -x cava 2>/dev/null || true

notify-send "Audio → $label" 2>/dev/null || true
