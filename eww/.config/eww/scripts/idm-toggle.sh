#!/usr/bin/env bash
# Toggle the iDotMatrix audio visualizer. Bound to $mod+Shift+m. Not autostarted —
# the BLE matrix is often off, so you start it on demand.
set -u
VENV="$HOME/.local/share/idotmatrix-venv"
D="$(dirname "$(readlink -f "$0")")"

if pgrep -f "[i]dm-viz.py" >/dev/null; then
    pkill -f "[i]dm-viz.py"
    notify-send "iDotMatrix" "Visualizer stopped" 2>/dev/null || true
    exit 0
fi

if [ ! -x "$VENV/bin/python" ]; then
    notify-send -u critical "iDotMatrix" "venv missing — run bootstrap (install_hud_tools)" 2>/dev/null
    exit 1
fi

setsid "$VENV/bin/python" "$D/idm-viz.py" >/dev/null 2>&1 </dev/null &
notify-send "iDotMatrix" "Visualizer started (BLE — close the phone app)" 2>/dev/null || true
