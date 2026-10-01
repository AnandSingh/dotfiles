#!/usr/bin/env bash
# Toggle the optional Dell ambient HUD without changing the current workspace.
set -euo pipefail

D=$(dirname "$(readlink -f "$0")")
if eww-x11 active-windows 2>/dev/null | grep -qx 'dell-hud'; then
    exec "$D/hud-stop.sh"
fi
exec "$D/hud-start.sh"
