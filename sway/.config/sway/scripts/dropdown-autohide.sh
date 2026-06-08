#!/bin/bash
# Auto-hide dropdown terminal when it loses focus

swaymsg -t subscribe -m '["window"]' | while read -r event; do
    # When a window gets focused, check if it's NOT the dropdown
    if echo "$event" | jq -e '.change == "focus" and .container.app_id != "dropdown"' > /dev/null 2>&1; then
        # Hide dropdown if it's visible (not in scratchpad)
        swaymsg '[app_id="dropdown"]' move to scratchpad 2>/dev/null
    fi
done
