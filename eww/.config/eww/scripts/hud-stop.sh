#!/usr/bin/env bash
# Tear down the Dell ambient HUD, its timer, wallpaper, and temporary workspace gaps.
set -u

MODEL="DELL U4025QW"

if [ -z "${SWAYSOCK:-}" ] || [ ! -S "${SWAYSOCK:-}" ]; then
    SWAYSOCK="$(ls "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"/sway-ipc.*.sock 2>/dev/null | head -1)"
    export SWAYSOCK
fi

systemctl --user stop dell-hud-art.timer 2>/dev/null || true
eww-x11 close dell-hud 2>/dev/null || true
eww-x11 kill 2>/dev/null || true
pkill -x cava 2>/dev/null || true    # eww deflisten spawns cava for the EQ bars

# Reset the temporary gaps without changing the operator's focused workspace,
# then restore the Dell wallpaper to the solid theme colour.
if [ -S "${SWAYSOCK:-}" ]; then
    current_ws=$(swaymsg -t get_workspaces --raw | jq -r '.[] | select(.focused).name')
    for n in 6 7 8 9; do swaymsg "workspace number $n; gaps top current set 0" >/dev/null; done
    [ -n "$current_ws" ] && swaymsg "workspace $current_ws" >/dev/null

    conn="$(swaymsg -t get_outputs 2>/dev/null | jq -r --arg m "$MODEL" '.[]|select(.model==$m)|.name' | head -1)"
    [ -n "$conn" ] && swaymsg output "$conn" bg "#1e1e2e" solid_color >/dev/null
fi
