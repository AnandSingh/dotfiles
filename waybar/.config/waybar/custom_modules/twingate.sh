#!/bin/bash
# Waybar custom/twingate module — reports the Twingate connection state.
# `twingate status` prints one of: online / authenticating / not-running / offline.

status="$(twingate status 2>/dev/null)"

case "$status" in
    online)
        # shield-check
        echo '{"text": "󰦝", "class": "online", "tooltip": "Twingate: online"}' ;;
    authenticating|connecting)
        echo '{"text": "󰦝", "class": "connecting", "tooltip": "Twingate: '"$status"'"}' ;;
    *)
        # not-running / offline / empty / anything else → shield-off
        echo '{"text": "󰦞", "class": "offline", "tooltip": "Twingate: '"${status:-offline}"'"}' ;;
esac
