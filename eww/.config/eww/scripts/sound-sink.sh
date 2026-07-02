#!/usr/bin/env bash
# Route system audio to a Sonos room (by NAME) or the laptop speaker, with a
# safety net: if the Sonos isn't actually reachable over AirPlay, fall back to the
# laptop instead of leaving audio silently dead (PipeWire RAOP drops happen when a
# Sonos stops advertising AirPlay — grouped/busy/mDNS lapse).
#   sound-sink.sh Den
#   sound-sink.sh "Media Room"
#   sound-sink.sh laptop
set -u
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

target="${1:-}"
[ -n "$target" ] || { echo "usage: sound-sink.sh <room-name|laptop>"; exit 1; }

laptop_sink() { pactl list short sinks | awk '/HiFi__Speaker__sink/{print $2; exit}'; }
sonos_sink() {  # room (raop sink Description) -> raop sink Name
    pactl list sinks 2>/dev/null | awk -v r="$1" '
        /^[[:space:]]*Name: / { name=$2 }
        /^[[:space:]]*Description: / { d=$0; sub(/^[[:space:]]*Description: /,"",d); if (d==r) { print name; exit } }'
}
move_all() { for si in $(pactl list short sink-inputs 2>/dev/null | awk '{print $1}'); do
                 pactl move-sink-input "$si" "$1" 2>/dev/null || true; done; }

use_laptop() {
    local s; s="$(laptop_sink)"
    pactl set-default-sink "$s"; move_all "$s"
    notify-send "Audio → Laptop" "$1" 2>/dev/null || true
}

if [ "$target" = laptop ] || [ "$target" = Laptop ] || [ "$target" = speaker ]; then
    use_laptop "selected"; exit 0
fi

# --- Sonos target ---
# Reachability: TCP-probe the speaker's AirPlay port (7000). More reliable than
# mDNS (whose ad flakily lapses even when the speaker is up). IP comes from the
# raop sink name (raop_sink.<host>.<ip>.7000).
sink="$(sonos_sink "$target")"
ip="$(printf '%s' "$sink" | grep -oE '192\.168\.[0-9]+\.[0-9]+' | head -1)"

if [ -z "$sink" ] || [ -z "$ip" ] || ! timeout 2 bash -c "exec 3<>/dev/tcp/$ip/7000" 2>/dev/null; then
    use_laptop "$target not reachable (AirPlay port closed) — using Laptop"
    exit 1
fi

# 2) route to it
pactl set-default-sink "$sink"; move_all "$sink"

# 3) if music is playing, confirm the AirPlay TCP actually comes up; else fall back
if playerctl status 2>/dev/null | grep -q Playing; then
    for _ in 1 2 3 4 5 6 7 8; do
        ss -tn 2>/dev/null | grep -q "${ip}:7000" && { notify-send "Audio → $target" 2>/dev/null; exit 0; }
        sleep 0.5
    done
    use_laptop "$target didn't connect — using Laptop"
    exit 1
fi

notify-send "Audio → $target" 2>/dev/null || true
