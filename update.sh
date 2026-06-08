#!/usr/bin/env bash
# Deprecated shim. The updater/doctor is now `fixmylinux`.
#   fixmylinux           full sync (this script's old behavior)
#   fixmylinux doctor    read-only health check
#   fixmylinux fix       repair configs without pulling
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$DOTFILES_DIR/bin/.local/bin/fixmylinux" "${1:-full}"
