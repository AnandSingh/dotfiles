#!/usr/bin/env bash
# Feed live cava bar values to eww as a JSON array, one line per frame.
# eww `deflisten` runs this; each line updates the EQ bars. When nothing is
# playing, cava emits zeros → flat bars (a real, audio-reactive visualizer).
CONF="$(dirname "$(readlink -f "$0")")/../cava.conf"

command -v cava >/dev/null || { echo "[0,0,0,0,0,0,0,0,0,0,0,0]"; exit 0; }

# cava raw ascii prints "50;30;80;...;" per frame; convert to "[50,30,80,...]".
# Strip everything but digits/';' first — cava prints a terminal-title escape and
# shader chatter at startup that would otherwise corrupt the first JSON lines.
stdbuf -oL cava -p "$CONF" 2>/dev/null | while IFS= read -r line; do
    clean="$(printf '%s' "$line" | tr -cd '0-9;')"
    [ -n "$clean" ] || continue
    printf '[%s]\n' "$(printf '%s' "${clean%;}" | tr ';' ',')"
done
