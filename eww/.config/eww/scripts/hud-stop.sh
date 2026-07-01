#!/usr/bin/env bash
# Kill switch: tear down the Dell ambient HUD (art + widgets + timer). Leaves the
# ergonomic top-strip gap in place (that was a separate choice); the strip just goes
# back to the plain dark background. Run this if you don't like the HUD.
set -u

MODEL="DELL P3222QE"

if [ -z "${SWAYSOCK:-}" ] || [ ! -S "${SWAYSOCK:-}" ]; then
    SWAYSOCK="$(ls "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"/sway-ipc.*.sock 2>/dev/null | head -1)"
    export SWAYSOCK
fi

systemctl --user stop dell-hud-art.timer 2>/dev/null || true
eww-x11 close dell-hud 2>/dev/null || true
eww-x11 kill 2>/dev/null || true
pkill -x cava 2>/dev/null || true    # eww deflisten spawns cava for the EQ bars

# reset the Dell wallpaper back to the solid theme colour
if [ -S "${SWAYSOCK:-}" ]; then
    conn="$(swaymsg -t get_outputs 2>/dev/null | jq -r --arg m "$MODEL" '.[]|select(.model==$m)|.name' | head -1)"
    [ -n "$conn" ] && swaymsg output "$conn" bg "#1e1e2e" solid_color >/dev/null
fi
