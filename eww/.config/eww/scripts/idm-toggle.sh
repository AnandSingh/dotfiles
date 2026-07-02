#!/usr/bin/env bash
# Toggle the iDotMatrix now-playing display. Bound to $mod+Shift+m. Not autostarted —
# the BLE matrix is often off, so you start it on demand. (The real-time EQ, idm-viz.py,
# stalls over BLE; now-playing text only pushes on track change, so it's stable. The
# EQ lives on better on the ESP32 Ulanzi TC001.)
set -u
VENV="$HOME/.local/share/idotmatrix-venv"
D="$(dirname "$(readlink -f "$0")")"
APP="idm-nowplaying.py"

if pgrep -f "idm-nowplayin[g].py" >/dev/null; then
    pkill -f "idm-nowplayin[g].py"
    notify-send "iDotMatrix" "Now-playing stopped" 2>/dev/null || true
    exit 0
fi

if [ ! -x "$VENV/bin/python" ]; then
    notify-send -u critical "iDotMatrix" "venv missing — run bootstrap (install_hud_tools)" 2>/dev/null
    exit 1
fi

setsid "$VENV/bin/python" "$D/$APP" >/dev/null 2>&1 </dev/null &
notify-send "iDotMatrix" "Now-playing started (BLE — close the phone app)" 2>/dev/null || true
