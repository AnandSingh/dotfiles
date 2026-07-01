#!/usr/bin/env bash
# Install the proprietary NVIDIA driver on a Fedora host (replaces nouveau).
# Run this on NVIDIA machines BEFORE install-nvidia-session.sh. Idempotent.
#
#   bash nvidia-sway/install-nvidia-driver.sh
#   # ...then install-nvidia-session.sh, then reboot.
#
# GPU drivers are host-specific (the AMD desktop must NOT run this), so this is
# a separate opt-in step, not part of bootstrap.sh.
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info() { echo -e "${GREEN}[nvidia]${NC} $1"; }
warn() { echo -e "${YELLOW}[nvidia]${NC} $1"; }

if ! grep -qi fedora /etc/os-release; then
  warn "This script targets Fedora (dnf + RPM Fusion). Aborting on non-Fedora host."
  exit 1
fi

FEDVER="$(rpm -E %fedora)"

info "Ensuring RPM Fusion free + nonfree are enabled (Fedora $FEDVER)..."
sudo dnf install -y \
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDVER}.noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDVER}.noarch.rpm" \
  || warn "RPM Fusion release rpms already present, continuing."

info "Installing akmod-nvidia + CUDA libraries (nvidia-smi, PRIME offload)..."
sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda

info "Building the kernel module now (avoids a black screen on first boot)..."
sudo akmods --force || warn "akmods returned non-zero; check its output."

# modeset=1 is required for Wayland/Sway on NVIDIA. Recent akmod-nvidia ships
# this in /usr/lib/modprobe.d, but write an explicit /etc override to be sure.
KMS=/etc/modprobe.d/nvidia-graphics-drivers-kms.conf
if ! grep -qs "nvidia_drm modeset=1" "$KMS" 2>/dev/null; then
  info "Enabling nvidia_drm modeset=1 ($KMS)..."
  echo "options nvidia_drm modeset=1" | sudo tee "$KMS" >/dev/null
fi

info "Rebuilding initramfs so the module loads at boot..."
sudo dracut --force

echo
info "Driver staged. Next:"
echo "  1. bash nvidia-sway/install-nvidia-session.sh   # adds 'Sway (Nvidia)' session"
echo "  2. sudo reboot"
echo "  3. After reboot:  nvidia-smi   (should list the GPU)"
