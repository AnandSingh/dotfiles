#!/usr/bin/env bash
# Route system audio directly to a Sonos room (by NAME) or the laptop speaker,
# and move any current streams onto it.
#   sound-sink.sh Den
#   sound-sink.sh "Media Room"
#   sound-sink.sh laptop
#
# Direct routing — no virtual "tap" sink. (The tap existed only to let the
# visualizer see Sonos-bound audio; that's gone. Trade-off: the on-screen EQ
# reacts to laptop audio but not audio sent to Sonos — PipeWire RAOP monitors are
# silent. cava.sh follows the default sink either way.)
set -u
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

target="${1:-}"
[ -n "$target" ] || { echo "usage: sound-sink.sh <room-name|laptop>"; exit 1; }

laptop_sink() { pactl list short sinks | awk '/HiFi__Speaker__sink/{print $2; exit}'; }
# room name (raop sink Description) -> raop sink Name
sonos_sink() {
    pactl list sinks 2>/dev/null | awk -v r="$1" '
        /^[[:space:]]*Name: / { name=$2 }
        /^[[:space:]]*Description: / { d=$0; sub(/^[[:space:]]*Description: /,"",d); if (d==r) { print name; exit } }'
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
for si in $(pactl list short sink-inputs 2>/dev/null | awk '{print $1}'); do
    pactl move-sink-input "$si" "$sink" 2>/dev/null || true
done

notify-send "Audio → $label" 2>/dev/null || true
