#!/usr/bin/env bash
# keybinding-help — searchable cheatsheet of all sway keybindings.
# Parses bindsym lines from the main config and any included files, tidies the
# variables for readability, and shows them in rofi. Display-only.

set -euo pipefail

files=(
    "$HOME/.config/sway/config"
    /etc/sway/config.d/*
    "$HOME"/.config/sway/config.d/*.conf
)

{
    for f in "${files[@]}"; do
        [ -f "$f" ] || continue
        grep -hE '^[[:space:]]*bindsym' "$f" 2>/dev/null || true
    done
} \
    | sed -E 's/^[[:space:]]*bindsym[[:space:]]+(--[a-z-]+[[:space:]]+)*//' \
    | sed -E 's/\$mod\b/Super/g; s/\bMod4\b/Super/g; s/\bMod1\b/Alt/g' \
    | sed -E 's/\$term\b/kitty/g; s/\$browser\b/google-chrome/g; s/\$menu\b/rofi/g; s/\$filemanager\b/thunar/g; s/\$lock\b/swaylock/g' \
    | awk '{ key=$1; $1=""; sub(/^ /,""); printf "%-26s  %s\n", key, $0 }' \
    | rofi -dmenu -i -p "keys" -format s \
        -theme-str '
            * { font: "JetBrainsMono Nerd Font 13"; }
            window   { width: 60%; }
            listview { lines: 18; }
            element  { padding: 6px; }
        ' >/dev/null || true
