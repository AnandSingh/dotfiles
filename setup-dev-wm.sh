#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { printf '\033[0;32m[wm-dev]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[wm-dev]\033[0m %s\n' "$*"; }
err() { printf '\033[0;31m[wm-dev]\033[0m %s\n' "$*" >&2; }

usage() {
  cat <<'EOF'
Usage: ./setup-dev-wm.sh [--packages] [--stow] [--all]

  --packages  Install Ubuntu/Debian packages for Sway+i3 developer desktop
  --stow      Symlink wm-dev helpers, Sway config, Waybar dev profile
  --all       Do both

Hyprland note: Ubuntu 24.04 does not reliably ship Hyprland in main apt repos.
This script installs the stable Sway path and prepares the Hyprland dev layer
for use when Hyprland is installed by your preferred upstream method.
EOF
}

install_packages() {
  if [ ! -f /etc/os-release ]; then
    err "Cannot detect Linux distribution"
    exit 1
  fi
  . /etc/os-release
  case "${ID:-}" in
    ubuntu|debian|pop|linuxmint) ;;
    *) warn "This package list targets Ubuntu/Debian; continuing anyway." ;;
  esac

  # Sway-only developer desktop. (Hyprland/i3 retired to legacy/.)
  local packages=(
    sway swayidle swaylock xwayland xdg-desktop-portal-wlr xdg-desktop-portal-gtk
    kitty waybar fuzzel wofi rofi mako-notifier wlogout kanshi
    grim slurp wl-clipboard cliphist
    brightnessctl playerctl pulseaudio-utils pavucontrol
    network-manager-gnome blueman
    thunar thunar-volman tumbler
    mesa-utils
    fonts-jetbrains-mono
  )
  # Note: fonts-jetbrains-mono lacks Nerd glyphs. Install the patched
  # JetBrainsMono Nerd Font (waybar icons + p10k) separately:
  #   curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
  #   unzip -o JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMonoNerd && fc-cache -f

  log "Installing developer WM packages with apt"
  sudo apt-get update
  sudo apt-get install -y "${packages[@]}"

  if apt-cache policy hyprland 2>/dev/null | awk '/Candidate:/ { exit ($2 == "(none)") }'; then
    warn "Hyprland appears available from apt on this system. Install it manually if desired: sudo apt-get install hyprland xdg-desktop-portal-hyprland"
  else
    warn "Hyprland is not available from your current apt repos; Sway is the recommended Wayland baseline on Ubuntu 24.04."
  fi
}

stow_configs() {
  command -v stow >/dev/null 2>&1 || { err "GNU stow is required. Run ./bootstrap.sh or sudo apt-get install stow"; exit 1; }
  cd "$DOTFILES_DIR"

  local packages=(wm-dev sway waybar fuzzel)
  for package in "${packages[@]}"; do
    if [ -d "$DOTFILES_DIR/$package" ]; then
      log "Restowing $package"
      stow -R -d "$DOTFILES_DIR" -t "$HOME" "$package"
    fi
  done

  # Thunar: open every window in WinSCP-style dual-pane split view by default.
  if command -v xfconf-query >/dev/null 2>&1; then
    log "Configuring Thunar split-view default"
    xfconf-query -c thunar -p /misc-open-new-windows-in-split-view -n -t bool -s true 2>/dev/null || true
    xfconf-query -c thunar -p /last-splitview-separator-position -n -t int -s 480 2>/dev/null || true
  fi

  warn "Hyprland and i3 configs are retired under legacy/ (Sway-only setup)."
  warn "Nvidia laptops: run ./nvidia-sway/install-nvidia-session.sh for the 'Sway (Nvidia)' session."
}

if [ $# -eq 0 ]; then
  usage
  exit 0
fi

run_packages=false
run_stow=false
for arg in "$@"; do
  case "$arg" in
    --packages) run_packages=true ;;
    --stow) run_stow=true ;;
    --all) run_packages=true; run_stow=true ;;
    -h|--help) usage; exit 0 ;;
    *) err "Unknown argument: $arg"; usage; exit 1 ;;
  esac
done

$run_packages && install_packages
$run_stow && stow_configs
log "Done. Read WM_DEV_SETUP.md for keybindings and Hyprland notes."
