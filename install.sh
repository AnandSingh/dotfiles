#!/bin/bash

# Dotfiles installer using GNU Stow
# This script symlinks dotfiles to your home directory

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if stow is installed
check_stow() {
    if ! command -v stow &> /dev/null; then
        log_error "GNU Stow is not installed!"
        log_info "Please run ./bootstrap.sh first to install dependencies"
        exit 1
    fi
}

# Define package categories
CORE_PACKAGES=(
    "git"
    "zsh"
    "tmux"
    "kitty"
    "bin"
)

EDITOR_PACKAGES=(
    "vim"
    "nvim"
)

GNOME_PACKAGES=(
    "gnome"
)

LINUX_WM_PACKAGES=(
    "sway"
    "swaync"
    "kitty"
    "gtk"
    "pipewire"
    "waybar"
    "i3"
    "hyprland"
    "polybar"
    "picom"
    "xprofile"
    "xresources"
    "volumeicon"
    "screenz"
)

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
            fedora|ubuntu|debian)
                OS="linux"
                ;;
            *)
                OS="linux"
                ;;
        esac
    else
        OS="unknown"
    fi
}

# Stow a package
stow_package() {
    local package=$1
    local action=${2:-"stow"}  # stow or restow

    if [ -d "$DOTFILES_DIR/$package" ]; then
        log_info "${action}ing $package..."

        # Tolerate per-package conflicts: warn and continue instead of letting
        # 'set -e' abort the whole run (e.g. ~/.xprofile is a real file, not a link).
        local rc=0
        if [ "$action" == "restow" ]; then
            stow -R -d "$DOTFILES_DIR" -t "$HOME" "$package" || rc=$?
        else
            stow -d "$DOTFILES_DIR" -t "$HOME" "$package" || rc=$?
        fi
        if [ "$rc" -ne 0 ]; then
            log_warn "conflict on '$package' (stow rc=$rc) — skipped. Resolve manually, e.g. an existing real file shadowing a symlink."
        fi
    else
        log_warn "Package $package does not exist, skipping..."
    fi
}

# Unstow a package
unstow_package() {
    local package=$1

    if [ -d "$DOTFILES_DIR/$package" ]; then
        log_info "Unstowing $package..."
        stow -D -d "$DOTFILES_DIR" -t "$HOME" "$package"
    fi
}

# Install core packages
install_core() {
    log_info "Installing core packages..."
    for package in "${CORE_PACKAGES[@]}"; do
        stow_package "$package"
    done
}

# Install editor packages
install_editors() {
    log_info "Installing editor packages..."
    for package in "${EDITOR_PACKAGES[@]}"; do
        stow_package "$package"
    done
}

# Warn before installing Hyprland/desktop configs if expected tools are missing.
check_linux_wm_tools() {
    local missing=()
    local tool

    for tool in Hyprland waybar rofi wl-paste; do
        if ! command -v "$tool" &> /dev/null; then
            missing+=("$tool")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        log_warn "Missing Linux WM tools: ${missing[*]}"
        log_warn "Stowing configs is OK, but Hyprland won't be launch-ready until these are installed."
    fi
}

# Install GNOME desktop customizations
install_gnome() {
    if [ "$OS" == "linux" ]; then
        log_info "Installing GNOME desktop customizations..."
        for package in "${GNOME_PACKAGES[@]}"; do
            stow_package "$package"
        done
    else
        log_warn "Skipping GNOME packages on macOS"
    fi
}

# Install Linux window manager packages
install_linux_wm() {
    if [ "$OS" == "linux" ]; then
        check_linux_wm_tools
        log_info "Installing Linux window manager packages..."
        for package in "${LINUX_WM_PACKAGES[@]}"; do
            stow_package "$package"
        done
    else
        log_warn "Skipping Linux WM packages on macOS"
    fi
}

# Install safe default packages
install_default() {
    install_core
    install_editors
}

# Install all packages, including desktop/window-manager configs
install_all() {
    install_default
    install_linux_wm
}

# Unstow all packages
uninstall_all() {
    log_info "Unstowing all packages..."
    for package in "${CORE_PACKAGES[@]}" "${EDITOR_PACKAGES[@]}" "${GNOME_PACKAGES[@]}" "${LINUX_WM_PACKAGES[@]}"; do
        unstow_package "$package"
    done
}

# Show usage
usage() {
    cat << EOF
Usage: $0 [OPTION]

Options:
    install             Install core/editor packages (default, safe)
    all                 Install all packages including Linux WM/desktop configs
    core                Install only core packages (git, zsh, tmux, kitty)
    editors             Install only editor packages (vim, nvim)
    gnome               Install only GNOME desktop customizations
    linux-wm            Install only Linux window manager packages
    uninstall           Remove all symlinks
    restow              Restow all packages (useful after updates)
    help                Show this help message

Examples:
    $0                  # Install core/editor packages
    $0 all              # Install everything, including Linux WM/desktop configs
    $0 core             # Install only core packages
    $0 gnome            # Install GNOME desktop customizations
    $0 restow           # Restow all packages
    $0 uninstall        # Remove all symlinks

EOF
}

# Main function
main() {
    cd "$DOTFILES_DIR"

    detect_os
    check_stow

    local command=${1:-install}

    case "$command" in
        install)
            log_info "Installing default dotfiles..."
            install_default
            ;;
        all)
            log_info "Installing all dotfiles..."
            install_all
            ;;
        core)
            install_core
            ;;
        editors)
            install_editors
            ;;
        gnome)
            install_gnome
            ;;
        linux-wm)
            install_linux_wm
            ;;
        uninstall)
            uninstall_all
            ;;
        restow)
            log_info "Restowing all packages..."
            for package in "${CORE_PACKAGES[@]}" "${EDITOR_PACKAGES[@]}" "${GNOME_PACKAGES[@]}" "${LINUX_WM_PACKAGES[@]}"; do
                if [ -d "$DOTFILES_DIR/$package" ]; then
                    stow_package "$package" "restow"
                fi
            done
            ;;
        help|--help|-h)
            usage
            exit 0
            ;;
        *)
            log_error "Unknown command: $command"
            usage
            exit 1
            ;;
    esac

    echo
    log_info "Done! Your dotfiles have been installed."
    log_info "You may need to restart your terminal for changes to take effect."
}

main "$@"
