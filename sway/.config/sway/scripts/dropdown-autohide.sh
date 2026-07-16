#!/bin/bash
# Auto-hide dropdown terminal and developer notes when they lose focus

swaymsg -t subscribe -m '["window"]' | while read -r event; do
    # Hide either utility when focus moves to a regular window. Do not hide one
    # merely because focus moved directly to the other.
    if echo "$event" | jq -e \
        '.change == "focus" and (.container.app_id | IN("dropdown", "org.gnome.gitlab.somas.Apostrophe") | not)' \
        > /dev/null 2>&1; then
        swaymsg '[app_id="dropdown"]' move to scratchpad 2>/dev/null
        swaymsg '[app_id="org.gnome.gitlab.somas.Apostrophe"]' move to scratchpad 2>/dev/null
    fi
done
