#!/usr/bin/env bash
# window-switcher — jump to any open window across all workspaces by name.
# Sway-native (rofi's built-in window mode only sees X11 windows). Lists every
# real window from the sway tree, shows name + app + workspace in rofi, and
# focuses the chosen one.

set -euo pipefail

tree=$(swaymsg -t get_tree)

# id<TAB>display  — one line per real window, annotated with its workspace.
entries=$(printf '%s' "$tree" | jq -r '
  [ .. | objects | select(.type? == "workspace")
    | .name as $ws
    | [ recurse(.nodes[]?, .floating_nodes[]?)
        | select((.type? == "con" or .type? == "floating_con")
                 and ((.name // "") != "")) ]
    | .[] | {id, name, app: (.app_id // .window_properties.class // "?"), ws: $ws}
  ]
  | .[] | "\(.id)\t\(.name)  ·  \(.app)  ·  [\(.ws)]"')

[ -n "$entries" ] || exit 0

idx=$(printf '%s\n' "$entries" | cut -f2- | rofi -dmenu -i -p "window" -format i \
    -kb-select-1 "Alt+1" -kb-select-2 "Alt+2" -kb-select-3 "Alt+3" \
    -kb-select-4 "Alt+4" -kb-select-5 "Alt+5" -kb-select-6 "Alt+6" \
    -kb-select-7 "Alt+7" -kb-select-8 "Alt+8" -kb-select-9 "Alt+9" \
    -kb-select-10 "Alt+0" \
    -theme-str '
        * { font: "JetBrainsMono Nerd Font 14"; }
        window        { width: 48%; }
        listview      { lines: 12; }
        element       { padding: 10px; children: [ element-index, element-text ]; }
        element-index { padding: 0 12px 0 0; text-color: #f9e2af; }
        inputbar      { padding: 12px; }
    ')
[[ "$idx" =~ ^[0-9]+$ ]] || exit 0

id=$(printf '%s\n' "$entries" | sed -n "$((idx + 1))p" | cut -f1)
[ -n "$id" ] && swaymsg "[con_id=$id] focus"
