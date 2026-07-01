#!/usr/bin/env bash
# Start (or restart, idempotently) the Dell ambient HUD: top-strip gap + eww overlay
# + wallpaper rotation. Guarded on the Dell being docked, so it is safe to run at
# login (exec) AND on demand ($mod+Shift+g) after docking mid-session.
set -u

MODEL="DELL P3222QE"
D="$(dirname "$(readlink -f "$0")")"

# --- self-detect sway socket ---
if [ -z "${SWAYSOCK:-}" ] || [ ! -S "${SWAYSOCK:-}" ]; then
    SWAYSOCK="$(ls "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"/sway-ipc.*.sock 2>/dev/null | head -1)"
    export SWAYSOCK
fi
[ -S "${SWAYSOCK:-}" ] || exit 0

# --- Dell docked? (retry a few times for login timing) else no HUD, no daemons ---
outputs=""
for _ in 1 2 3 4 5; do
    outputs="$(swaymsg -t get_outputs 2>/dev/null)"
    echo "$outputs" | grep -q "$MODEL" && break
    sleep 1
done
echo "$outputs" | grep -q "$MODEL" || exit 0
conn="$(echo "$outputs" | jq -r --arg m "$MODEL" '.[]|select(.model==$m)|.name' | head -1)"
[ -n "$conn" ] || exit 0

# --- reserve the top third (720px) on Dell workspaces (ergonomic gap) — idempotent ---
for n in 6 7 8 9; do swaymsg "workspace number $n; gaps top current set 720" >/dev/null; done
swaymsg "workspace number 1" >/dev/null

# --- eww overlay (idempotent) ---
# Backend: eww-x11. eww-wayland renders BLANK on this NVIDIA box (GTK/EGL layer-shell).
# eww-x11 needs GDK forced to X11 (else, with WAYLAND_DISPLAY set, GTK makes a wayland
# window and eww-x11 errors "failed to get x11 window") and a valid DISPLAY.
export GDK_BACKEND=x11
export DISPLAY="${DISPLAY:-$(ls /tmp/.X11-unix/X* 2>/dev/null | head -1 | sed 's#.*/X#:#')}"
# The Dell's GDK/X monitor index == its position among sway's ACTIVE outputs.
scr="$(echo "$outputs" | jq -r '[.[]|select(.active==true)]|map(.model)|index("'"$MODEL"'") // 0')"
if command -v eww-x11 >/dev/null; then
    pgrep -x eww-x11 >/dev/null || { eww-x11 daemon >/dev/null 2>&1; sleep 1; }
    eww-x11 active-windows 2>/dev/null | grep -q dell-hud \
        || eww-x11 open dell-hud --screen "$scr" >/dev/null 2>&1
fi

# --- wallpaper: fetch one now, then arm the 20-min rotation timer ---
"$D/art-fetch.sh" &
systemctl --user start dell-hud-art.timer 2>/dev/null || true
