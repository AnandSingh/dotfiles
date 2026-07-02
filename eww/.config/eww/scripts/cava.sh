#!/usr/bin/env bash
# Feed live cava bar values to eww as a JSON array, one line per frame.
#
# cava's `source = auto` binds to the default monitor only at startup, so it does
# NOT follow later default-sink changes (route laptop -> Sonos and the bars would
# freeze on the old, silent monitor). So we resolve the CURRENT default sink's
# monitor explicitly and restart cava whenever the default changes. Also loops
# forever so a transient monitor drop never kills the visualizer for good.
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
BASE="$(dirname "$(readlink -f "$0")")/../cava.conf"

default_monitor() { printf '%s.monitor' "$(pactl get-default-sink 2>/dev/null)"; }

while :; do
    mon="$(default_monitor)"
    conf="$(mktemp)"
    # point cava at the current default monitor explicitly
    sed "s|^source = .*|source = ${mon}|" "$BASE" > "$conf"

    # cava -> JSON frames (strip cava's startup escape/shader noise)
    stdbuf -oL cava -p "$conf" 2>/dev/null | while IFS= read -r line; do
        clean="$(printf '%s' "$line" | tr -cd '0-9;')"
        [ -n "$clean" ] || continue
        printf '[%s]\n' "$(printf '%s' "${clean%;}" | tr ';' ',')"
    done &
    cava_pipe=$!

    # watch the default sink; if it changes, kill cava so the loop rebinds
    while kill -0 "$cava_pipe" 2>/dev/null; do
        sleep 1
        [ "$(default_monitor)" != "$mon" ] && break
    done
    pkill -f "cava -p ${conf}" 2>/dev/null   # only THIS cava (unique temp conf)
    kill "$cava_pipe" 2>/dev/null
    wait "$cava_pipe" 2>/dev/null
    rm -f "$conf"
    echo "[0,0,0,0,0,0,0,0,0,0,0,0]"
    sleep 0.3
done
