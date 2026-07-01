#!/usr/bin/env bash
# Rofi power menu — Catppuccin-friendly, matches the waybar power button.
# Wired to the waybar custom/power module and Control+Alt+Delete.

set -euo pipefail

options="\
 Lock
 Logout
 Suspend
 Reboot
 Shutdown"

chosen=$(printf '%s' "$options" | rofi -dmenu -i -p "Power" \
    -theme-str 'window {width: 14%;} listview {lines: 5;}')

case "$chosen" in
    *Lock)     swaylock -f ;;
    *Logout)   swaymsg exit ;;
    *Suspend)  systemctl suspend ;;
    *Reboot)   systemctl reboot ;;
    *Shutdown) systemctl poweroff ;;
esac
