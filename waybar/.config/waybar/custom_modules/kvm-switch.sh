#!/usr/bin/env bash
# Waybar control for the Dell U4025QW KVM. Each host switches toward the other.
set -euo pipefail

host=$(hostname -s)
case "$host" in
    devserver-aks)
        target="Laptop"
        switch_cmd=("$HOME/.config/sway/scripts/dell-kvm-switch.sh" usbc)
        ;;
    *)
        target="Devserver"
        switch_cmd=(ddcutil --model "DELL U4025QW" --sn CR1KHJ4 setvcp 60 0x0f --noverify)
        ;;
esac

case "${1:-status}" in
    status)
        jq -cn --arg text "KVM → $target" \
            --arg tooltip "Switch Dell U4025QW display, keyboard and mouse to $target" \
            --arg class "kvm-${target,,}" \
            '{text:$text, tooltip:$tooltip, class:$class}'
        ;;
    switch)
        exec 9>"${XDG_RUNTIME_DIR:-/tmp}/dell-kvm-switch.lock"
        flock -n 9 || exit 0
        if ! "${switch_cmd[@]}"; then
            notify-send -u critical "Dell KVM" "Could not switch to $target" 2>/dev/null || true
            exit 1
        fi
        ;;
    *)
        echo "usage: ${0##*/} [status|switch]" >&2
        exit 2
        ;;
esac
