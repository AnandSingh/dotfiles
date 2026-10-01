#!/usr/bin/env bash
set -euo pipefail

app_id="Zettlr"
notes_workspace=8

# When Notes is already focused, use Sway's workspace history to go back.
focused_app=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | .app_id // empty')
if [[ "$focused_app" == "$app_id" ]]; then
    exec swaymsg workspace back_and_forth
fi

# Migrate a window left in the old scratchpad setup on the first invocation.
if swaymsg -t get_tree | jq -e --arg app_id "$app_id" \
    '.. | objects | select(.app_id? == $app_id and ((.scratchpad_state? // "none") != "none"))' >/dev/null; then
    swaymsg "[app_id=\"$app_id\"]" move container to workspace number "$notes_workspace"
    swaymsg "[app_id=\"$app_id\"]" floating disable
    exec swaymsg "[app_id=\"$app_id\"]" focus
fi

# Follow Zettlr if the user has moved it away from its default workspace.
if swaymsg -t get_tree | jq -e --arg app_id "$app_id" \
    '.. | objects | select(.app_id? == $app_id)' >/dev/null; then
    exec swaymsg "[app_id=\"$app_id\"]" focus
fi

# First launch belongs on the dedicated Notes workspace.
swaymsg workspace number "$notes_workspace"
exec "$HOME/.config/sway/scripts/dev-notes.sh"
