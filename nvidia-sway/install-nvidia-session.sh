#!/usr/bin/env bash
# Install the "Sway (Nvidia)" session: wrapper + gdm session entry.
# These live in root-owned /usr/local (not $HOME) so they are NOT stowed.
# Run on a host with the proprietary Nvidia driver where you want Sway on Nvidia.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing Sway-on-Nvidia wrapper + session (requires sudo)..."

sudo install -Dm755 "$DIR/sway-nvidia" /usr/local/bin/sway-nvidia
sudo install -Dm644 "$DIR/sway-nvidia.desktop" \
  /usr/local/share/wayland-sessions/sway-nvidia.desktop

echo "Done. Verify:"
echo "  cat /usr/local/bin/sway-nvidia"
echo "  cat /usr/local/share/wayland-sessions/sway-nvidia.desktop"
echo
echo "Log out, then pick 'Sway (Nvidia)' from the gdm gear menu."
echo
echo "Prerequisites (already true on the original host, check on new ones):"
echo "  - nvidia_drm modeset=1  (/etc/modprobe.d/nvidia-graphics-drivers-kms.conf)"
echo "  - gdm Wayland not force-disabled  (#WaylandEnable=false in /etc/gdm3/custom.conf)"
