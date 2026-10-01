#!/usr/bin/env bash
# Sync internal panel(s) with the physical lid state after resume.
#
# sway can miss the libinput lid:off edge that wakes the machine — the event
# fires while the compositor is still frozen — leaving eDP-* disabled and the
# screen black even though the system resumed fine. Reading the ACPI lid STATE
# instead of relying on the edge makes resume deterministic:
#   lid open   -> enable internal panel(s)
#   lid closed -> leave them disabled (docked clamshell stays correct)
# Machines with no lid / no eDP output exit silently, so this is safe in the
# shared config. Wired in via swayidle's after-resume hook.

set -u

lid_state() {
    local f
    for f in /proc/acpi/button/lid/*/state; do
        [ -r "$f" ] || continue
        awk '{print $2; exit}' "$f"
        return 0
    done
    return 1
}

state=$(lid_state) || exit 0

case "$state" in
    open)   wanted=true;  action=enable ;;
    closed) wanted=false; action=disable ;;
    *)      exit 0 ;;
esac

# The IPC socket can lag for a moment right after resume — retry briefly.
panels=""
for _ in 1 2 3 4 5; do
    if panels=$(swaymsg -t get_outputs --raw 2>/dev/null \
            | jq -r '.[] | select(.name | startswith("eDP")) | [.name, .active] | @tsv'); then
        break
    fi
    sleep 0.5
done

while IFS=$'\t' read -r panel active; do
    [ -n "$panel" ] || continue
    [ "$active" = "$wanted" ] && continue
    swaymsg output "$panel" "$action"
done <<< "$panels"

# Undo any pre-suspend idle blanking so the lock screen is visible immediately.
swaymsg 'output * power on'
