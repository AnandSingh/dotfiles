#!/usr/bin/env bash
# Route system audio to a Sonos room (by NAME) or the laptop speaker, keeping the
# audio visualizers alive on EITHER output.
#
# Why the "tap": RAOP/Sonos sink monitors are silent in PipeWire, so cava can't
# see audio sent straight to a Sonos. Fix: a persistent null sink "viz_tap" (which
# HAS a working monitor) is always the default; apps play into it; a loopback
# copies it to the real output (laptop or Sonos). cava reads viz_tap.monitor, so
# the bars react no matter where the sound actually goes.
#
#   sound-sink.sh Den            sound-sink.sh "Media Room"            sound-sink.sh laptop
set -u
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
TAP="viz_tap"

target="${1:-}"
[ -n "$target" ] || { echo "usage: sound-sink.sh <room-name|laptop>"; exit 1; }

laptop_sink() { pactl list short sinks | awk '/HiFi__Speaker__sink/{print $2; exit}'; }
sonos_sink() {  # room (raop sink Description) -> raop sink Name
    pactl list sinks 2>/dev/null | awk -v r="$1" '
        /^[[:space:]]*Name: / { name=$2 }
        /^[[:space:]]*Description: / { d=$0; sub(/^[[:space:]]*Description: /,"",d); if (d==r) { print name; exit } }'
}

# tear down any existing viz_tap loopback (used only for Sonos targets)
drop_loopbacks() {
    for m in $(pactl list modules 2>/dev/null | awk -v t="$TAP" '
        /Module #/ { id=$2 } /Argument:/ { if (index($0, "source="t".monitor")) print id }'); do
        pactl unload-module "$m" 2>/dev/null || true
    done
}

case "$target" in
    laptop|Laptop|speaker)
        # Laptop: its sink monitor works directly — no tap/loopback (no added latency).
        real="$(laptop_sink)"; label="Laptop"
        [ -n "$real" ] || { notify-send -u critical "Audio" "Laptop sink not found" 2>/dev/null; exit 1; }
        drop_loopbacks
        pactl set-default-sink "$real"
        for si in $(pactl list short sink-inputs 2>/dev/null | awk '{print $1}'); do
            pactl move-sink-input "$si" "$real" 2>/dev/null || true
        done
        ;;
    *)
        # Sonos: RAOP monitors are silent, so route through the tap (monitorable)
        # and loopback the tap to the Sonos so the visualizer still reacts.
        real="$(sonos_sink "$target")"; label="$target"
        [ -n "$real" ] || { notify-send -u critical "Audio" "Output not found: $target" 2>/dev/null; exit 1; }
        pactl list short sinks | grep -q "[[:space:]]${TAP}[[:space:]]" \
            || pactl load-module module-null-sink sink_name="$TAP" \
                 sink_properties="device.description=Visualizer-Tap" >/dev/null
        drop_loopbacks
        pactl load-module module-loopback source="${TAP}.monitor" sink="$real" \
            latency_msec=120 sink_input_properties="media.name=viz_tap_loopback" >/dev/null
        pactl set-default-sink "$TAP"
        # move app streams to the tap, but NOT the loopback's own stream (would loop)
        lb_si="$(pactl list sink-inputs 2>/dev/null | awk '
            /Sink Input #/ { id=$3; gsub(/#/,"",id) }
            /media.name = "viz_tap_loopback"/ { print id }')"
        for si in $(pactl list short sink-inputs 2>/dev/null | awk '{print $1}'); do
            [ "$si" = "$lb_si" ] && continue
            pactl move-sink-input "$si" "$TAP" 2>/dev/null || true
        done
        ;;
esac

notify-send "Audio → $label" 2>/dev/null || true
