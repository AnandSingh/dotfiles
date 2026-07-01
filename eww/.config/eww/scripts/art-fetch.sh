#!/usr/bin/env bash
# Fetch a random SFW wallhaven image and set it as the Dell (top monitor) wallpaper
# via sway's own `output bg`. Only the top 720px of the Dell is visible (the rest is
# under tiled windows), so we CENTER-CROP each image to that band and pin it to the
# top of a full-height canvas — the visible strip shows the subject, not empty sky.
#
# Runs both from the sway session and from a systemd --user timer (which does NOT
# inherit SWAYSOCK — self-detected below, mirroring bin/.local/bin/tmux-paste-image).
set -u

MODEL="DELL P3222QE"
CACHE="$HOME/.cache/dell-hud"
TAG="${DELL_HUD_TAG:-}"       # optional wallhaven search tag; empty = any SFW
STRIP_W=3840                  # Dell width (logical)
STRIP_H=720                   # visible top strip (the gap)
FULL_H=2160                   # Dell height (logical)
SCRIM="#1e1e2e"               # fill colour for the hidden lower canvas

# --- self-detect sway socket if absent (systemd timer path) ---
if [ -z "${SWAYSOCK:-}" ] || [ ! -S "${SWAYSOCK:-}" ]; then
    SWAYSOCK="$(ls "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"/sway-ipc.*.sock 2>/dev/null | head -1)"
    export SWAYSOCK
fi
[ -S "${SWAYSOCK:-}" ] || { echo "art-fetch: no sway socket" >&2; exit 0; }

# --- Dell docked? else no-op (undock-safe: no download, no journal spam) ---
outputs="$(swaymsg -t get_outputs 2>/dev/null)" || exit 0
echo "$outputs" | grep -q "$MODEL" || exit 0
conn="$(echo "$outputs" | jq -r --arg m "$MODEL" '.[]|select(.model==$m)|.name' | head -1)"
[ -n "$conn" ] || exit 0

mkdir -p "$CACHE"

# --- query wallhaven (SFW → no API key). ratios ~16x3 so results already suit the
#     wide strip band; fall back to plain 16x9 if the strip search returns nothing. ---
base="https://wallhaven.cc/api/v1/search?purity=100&sorting=random&atleast=${STRIP_W}x${STRIP_H}"
url="${base}&ratios=32x9"
[ -n "$TAG" ] && url="${url}&q=$(printf '%s' "$TAG" | jq -sRr @uri)"
img="$(curl -fsSL --max-time 20 "$url" | jq -r '.data[0].path // empty')"
if [ -z "$img" ]; then
    img="$(curl -fsSL --max-time 20 "${base}&ratios=16x9" | jq -r '.data[0].path // empty')"
fi
if [ -z "$img" ]; then
    echo "art-fetch: wallhaven fetch failed, keeping current image" >&2
    exit 0
fi

ext="${img##*.}"; [ "${#ext}" -le 4 ] || ext=jpg
raw="$CACHE/.raw.$ext"
out="$CACHE/current.png"
if ! curl -fsSL --max-time 60 -o "$raw" "$img"; then
    echo "art-fetch: download failed, keeping current image" >&2
    rm -f "$raw"; exit 0
fi

# --- center-crop to the strip band, pin to top of a full-height canvas ---
rm -f "$CACHE"/current.*
if magick "$raw" -resize "${STRIP_W}x${STRIP_H}^" -gravity center -extent "${STRIP_W}x${STRIP_H}" \
        -gravity north -background "$SCRIM" -extent "${STRIP_W}x${FULL_H}" "$out" 2>/dev/null; then
    rm -f "$raw"
    swaymsg output "$conn" bg "$out" fill >/dev/null
else
    # crop failed → fall back to the raw image, filled
    mv -f "$raw" "$CACHE/current.$ext"
    swaymsg output "$conn" bg "$CACHE/current.$ext" fill >/dev/null
fi
