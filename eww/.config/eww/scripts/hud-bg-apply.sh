#!/usr/bin/env bash
# Re-apply the last cached wallpaper to the Dell without re-fetching. Called via
# `exec_always` so a `swaymsg reload` (which re-runs `output * bg #1e1e2e` and would
# blank the art) instantly restores the current image. Cheap, no network.
set -u

MODEL="DELL P3222QE"
CACHE="$HOME/.cache/dell-hud"

if [ -z "${SWAYSOCK:-}" ] || [ ! -S "${SWAYSOCK:-}" ]; then
    SWAYSOCK="$(ls "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"/sway-ipc.*.sock 2>/dev/null | head -1)"
    export SWAYSOCK
fi
[ -S "${SWAYSOCK:-}" ] || exit 0

img="$(ls -t "$CACHE"/current.* 2>/dev/null | head -1)"
[ -n "$img" ] || exit 0

outputs="$(swaymsg -t get_outputs 2>/dev/null)" || exit 0
echo "$outputs" | grep -q "$MODEL" || exit 0
conn="$(echo "$outputs" | jq -r --arg m "$MODEL" '.[]|select(.model==$m)|.name' | head -1)"
[ -n "$conn" ] && swaymsg output "$conn" bg "$img" fill >/dev/null
