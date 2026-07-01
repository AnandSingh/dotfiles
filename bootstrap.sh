#!/bin/bash

# Bootstrap script for setting up dotfiles across different platforms
# Supports: macOS, Fedora, Ubuntu

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
            fedora)
                OS="fedora"
                ;;
            ubuntu|debian)
                OS="ubuntu"
                ;;
            *)
                log_error "Unsupported Linux distribution: $ID"
                exit 1
                ;;
        esac
    else
        log_error "Unable to detect OS"
        exit 1
    fi

    log_info "Detected OS: $OS"
}

# Install tools that aren't in Ubuntu apt, from GitHub release tarballs, into
# ~/.local/bin. Tolerant: any failure warns and continues (never aborts bootstrap).
install_github_binaries() {
    command -v curl >/dev/null 2>&1 || { log_warn "curl missing; skipping extra tool binaries"; return 0; }
    local bindir="$HOME/.local/bin"; mkdir -p "$bindir"
    local arch; arch="$(uname -m)"
    if [ "$arch" != "x86_64" ]; then
        log_warn "arch '$arch': skipping lazygit/dust/glow binaries — install manually."
        return 0
    fi

    _gh_install() {  # $1=binary name  $2=owner/repo  $3=asset-url regex
        local name="$1" repo="$2" regex="$3"
        if command -v "$name" >/dev/null 2>&1; then
            log_info "$name already installed, skipping."
            return 0
        fi
        local url
        url="$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" \
               | grep -ioE "https://[^\"]*${regex}[^\"]*" | head -1)" || true
        if [ -z "$url" ]; then
            log_warn "no matching $name release asset ($repo); skipping."
            return 0
        fi
        log_info "Installing $name from $repo ..."
        local d; d="$(mktemp -d)"
        if curl -fsSL "$url" -o "$d/a.tar.gz" && tar -xzf "$d/a.tar.gz" -C "$d" 2>/dev/null; then
            local bin; bin="$(find "$d" -type f -name "$name" | head -1)"
            if [ -n "$bin" ]; then
                install -m 0755 "$bin" "$bindir/$name"
                log_info "$name installed to $bindir/$name"
            else
                log_warn "$name binary not found in archive; skipping."
            fi
        else
            log_warn "download/extract failed for $name; skipping."
        fi
        rm -rf "$d"
    }

    _gh_install lazygit jesseduffield/lazygit 'linux_x86_64\.tar\.gz'
    _gh_install dust    bootandy/dust         'x86_64-unknown-linux-gnu\.tar\.gz'
    _gh_install glow    charmbracelet/glow    'linux_x86_64\.tar\.gz'
}

# Install packages based on OS
install_packages() {
    log_info "Installing required packages for $OS..."

    case "$OS" in
        macos)
            # Check if Homebrew is installed
            if ! command -v brew &> /dev/null; then
                log_info "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi

            # Install packages
            brew install stow zsh tmux neovim git fzf bat
            ;;

        fedora)
            log_info "Updating package cache..."
            sudo dnf update -y

            log_info "Installing core packages..."
            sudo dnf install -y \
                stow \
                zsh \
                tmux \
                neovim \
                git \
                util-linux-user \
                ncurses-devel \
                libevent-devel \
                fzf \
                bat \
                ripgrep \
                jq

            log_info "Installing dev tools..."
            sudo dnf install -y \
                eza \
                fd-find \
                zoxide \
                git-delta \
                btop \
                tldr \
                dust \
                duf \
                glow

            # lazygit is not in Fedora repos, install from COPR
            if ! command -v lazygit &>/dev/null; then
                log_info "Installing lazygit from COPR..."
                sudo dnf copr enable atim/lazygit -y
                sudo dnf install -y lazygit
            fi
            ;;

        ubuntu)
            log_info "Updating package cache..."
            sudo apt update

            log_info "Installing packages..."
            sudo apt install -y \
                stow \
                zsh \
                tmux \
                neovim \
                git \
                curl \
                wget \
                build-essential \
                htop \
                fzf \
                ripgrep \
                jq \
                bat \
                fd-find \
                eza \
                zoxide \
                git-delta \
                btop \
                duf \
                tldr

            mkdir -p ~/.local/bin
            # bat is called batcat on Ubuntu
            if ! command -v bat &> /dev/null && command -v batcat &> /dev/null; then
                ln -sf "$(command -v batcat)" ~/.local/bin/bat
            fi
            # fd is called fdfind on Ubuntu
            if ! command -v fd &> /dev/null && command -v fdfind &> /dev/null; then
                ln -sf "$(command -v fdfind)" ~/.local/bin/fd
            fi
            ;;
    esac

    log_info "Packages installed successfully!"
}

# Install the Sway desktop environment + companions (Linux only).
# bootstrap's core step installs the shell/dev tools but NOT the compositor or
# the apps the stowed configs actually launch: kitty ($term), rofi ($menu),
# waybar, the lock/idle/notification stack, screenshot tools, and a polkit agent.
# Without these, `./install.sh linux-wm` stows configs that can't launch.
# GPU drivers are deliberately out of scope (host-specific: AMD desktop vs
# NVIDIA laptop) — see nvidia-sway/ and the per-host graphics setup.
install_sway_desktop() {
    case "$OS" in
        fedora)
            log_info "Installing Sway desktop environment + companions..."
            sudo dnf install -y \
                sway swaybg swayidle swaylock \
                waybar rofi wofi fuzzel mako \
                grim slurp wl-clipboard \
                kitty thunar \
                brightnessctl playerctl pavucontrol \
                NetworkManager-tui network-manager-applet blueman \
                mate-polkit xdg-desktop-portal-wlr \
                jetbrains-mono-fonts fontawesome-fonts-all google-noto-emoji-fonts \
                || log_warn "Some Sway packages failed to install; review the output above."
            # swww (animated wallpaper) isn't always packaged — optional.
            sudo dnf install -y swww 2>/dev/null || log_warn "swww not in repos; wallpaper exec stays optional."
            ;;
        ubuntu)
            log_info "Installing Sway desktop environment + companions..."
            sudo apt install -y \
                sway swaybg swayidle swaylock \
                waybar rofi wofi fuzzel mako-notifier \
                grim slurp wl-clipboard \
                kitty thunar \
                brightnessctl playerctl pavucontrol \
                network-manager-gnome blueman \
                policykit-1-gnome xdg-desktop-portal-wlr \
                fonts-jetbrains-mono fonts-font-awesome fonts-noto-color-emoji \
                || log_warn "Some Sway packages failed to install; review the output above."
            ;;
        macos)
            : # No Sway on macOS — skip silently.
            ;;
    esac
}

# Install Oh My Zsh
install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log_info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

        # Install plugins
        log_info "Installing zsh plugins..."

        # zsh-autosuggestions
        if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
            git clone https://github.com/zsh-users/zsh-autosuggestions \
                ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        fi

        # zsh-syntax-highlighting
        if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
            git clone https://github.com/zsh-users/zsh-syntax-highlighting \
                ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        fi

        # powerlevel10k theme
        if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
            git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
                ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
        fi

        log_info "Oh My Zsh and plugins installed!"
    else
        log_warn "Oh My Zsh already installed, skipping..."
    fi
}

# Install vim-plug for Neovim
install_vim_plug() {
    local plug_path="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim"

    if [ ! -f "$plug_path" ]; then
        log_info "Installing vim-plug for Neovim..."
        sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
        log_info "vim-plug installed!"
    else
        log_warn "vim-plug already installed, skipping..."
    fi
}

# Install TPM (Tmux Plugin Manager)
install_tpm() {
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        log_info "Installing TPM (Tmux Plugin Manager)..."
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
        log_info "TPM installed! Run prefix+I in tmux to install plugins."
    else
        log_warn "TPM already installed, skipping..."
    fi
}

# Setup passwordless sudo for safe commands
setup_sudoers() {
    local sudoers_file="/etc/sudoers.d/nopasswd-safe"
    if [ ! -f "$sudoers_file" ]; then
        log_info "Setting up passwordless sudo for safe commands..."
        echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/dnf, /usr/bin/systemctl, /usr/bin/reboot, /usr/bin/poweroff, /usr/bin/mount, /usr/bin/umount, /usr/bin/dmesg, /usr/bin/journalctl, /usr/bin/nmap" \
            | sudo tee "$sudoers_file" > /dev/null
        sudo chmod 440 "$sudoers_file"
        log_info "Sudoers configured!"
    else
        log_warn "Sudoers already configured, skipping..."
    fi
}

# Initialize tldr cache
init_tldr() {
    if command -v tldr &>/dev/null; then
        log_info "Updating tldr cache..."
        tldr --update &>/dev/null &
    fi
}

# Set Zsh as default shell
set_default_shell() {
    if [ "$SHELL" != "$(which zsh)" ]; then
        log_info "Setting Zsh as default shell..."
        chsh -s $(which zsh)
        log_info "Zsh set as default shell. Please log out and back in for changes to take effect."
    else
        log_info "Zsh is already the default shell"
    fi
}

# Seed the per-machine Sway override (config.d/local.conf) from the OS template.
# local.conf is git-ignored so each host keeps its own monitors/inputs without
# clobbering the others. Skips if the host already has one.
seed_sway_local() {
    local repo_dir
    repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    local conf_dir="$repo_dir/sway/.config/sway/config.d"
    local examples="$repo_dir/sway/.config/sway/examples"
    local target="$conf_dir/local.conf"

    if [ ! -d "$examples" ]; then
        log_warn "Sway examples dir missing, skipping local.conf seed."
        return
    fi

    if [ -f "$target" ]; then
        log_info "Sway local.conf already exists, leaving it untouched."
        return
    fi

    # Both Fedora hosts share OS=fedora, so split them by chassis: the laptop
    # (ThinkPad) gets the DP-2-main + lid-switch profile, the desktop keeps its
    # monitor wall. `hostnamectl chassis` reports "laptop"/"desktop".
    local template
    case "$OS" in
        fedora)
            if [ "$(hostnamectl chassis 2>/dev/null)" = "laptop" ]; then
                template="$examples/local.fedora-laptop.conf"
            else
                template="$examples/local.fedora-desktop.conf"
            fi
            ;;
        ubuntu) template="$examples/local.ubuntu-laptop.conf" ;;
        *)      template="$examples/local.conf.example" ;;
    esac

    [ -f "$template" ] || template="$examples/local.conf.example"

    mkdir -p "$conf_dir"
    cp "$template" "$target"
    log_info "Seeded Sway local.conf from $(basename "$template")"
}

# Seed the per-machine xprofile override (~/.xprofile.local) from the OS template.
# The common ~/.xprofile sources it; it's git-ignored so each host keeps its own
# monitor/xrandr setup. X11 only. Skips if the host already has one.
seed_xprofile_local() {
    local repo_dir
    repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    local examples="$repo_dir/xprofile/examples"
    local target="$HOME/.xprofile.local"

    if [ ! -d "$examples" ]; then
        log_warn "xprofile examples dir missing, skipping .xprofile.local seed."
        return
    fi

    if [ -f "$target" ]; then
        log_info "~/.xprofile.local already exists, leaving it untouched."
        return
    fi

    local template
    case "$OS" in
        fedora) template="$examples/local.fedora-desktop.xprofile" ;;
        ubuntu) template="$examples/local.ubuntu-laptop.xprofile" ;;
        *)      template="$examples/local.xprofile.example" ;;
    esac

    [ -f "$template" ] || template="$examples/local.xprofile.example"

    cp "$template" "$target"
    log_info "Seeded ~/.xprofile.local from $(basename "$template")"
}

# Seed the per-machine kitty override (~/.config/kitty/local.conf) from the
# OS template. kitty.conf includes it last, so it overrides the 4K font_size
# default. Git-ignored; skips if the host already has one.
seed_kitty_local() {
    local repo_dir
    repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    local examples="$repo_dir/kitty/examples"
    local target="$HOME/.config/kitty/local.conf"

    if [ ! -d "$examples" ]; then
        log_warn "kitty examples dir missing, skipping local.conf seed."
        return
    fi

    if [ -f "$target" ]; then
        log_info "~/.config/kitty/local.conf already exists, leaving it untouched."
        return
    fi

    local template
    case "$OS" in
        fedora) template="$examples/local.fedora-desktop.conf" ;;
        ubuntu) template="$examples/local.ubuntu-laptop.conf" ;;
        *)      template="$examples/local.conf.example" ;;
    esac

    [ -f "$template" ] || template="$examples/local.conf.example"

    mkdir -p "$(dirname "$target")"
    cp "$template" "$target"
    log_info "Seeded ~/.config/kitty/local.conf from $(basename "$template")"
}

# Install the GTK theme + icon theme referenced by the stowed gtk/settings.ini.
# Both go into userspace dirs (~/.themes, ~/.local/share/icons) so no root/dnf is
# needed — Fedora's gtk3 ships no on-disk Adwaita CSS, so GTK apps (Thunar, etc.)
# fall back to light without a real dark theme present. Catppuccin Mocha matches
# the repo's kitty/sway/delta theme; Papirus-Dark is the paired icon set.
install_gtk_theme() {
    [ "$OS" = "linux" ] || return 0

    local gtk_theme="catppuccin-mocha-blue-standard+default"
    local gtk_ver="v1.0.3"

    if [ -d "$HOME/.themes/$gtk_theme" ]; then
        log_info "GTK theme $gtk_theme already present, skipping."
    else
        log_info "Installing Catppuccin Mocha GTK theme to ~/.themes..."
        mkdir -p "$HOME/.themes"
        local url="https://github.com/catppuccin/gtk/releases/download/${gtk_ver}/${gtk_theme}.zip"
        local tmp
        tmp="$(mktemp -d)"
        if curl -sL --max-time 60 -o "$tmp/theme.zip" "${url//+/%2B}" \
            && unzip -oq "$tmp/theme.zip" -d "$HOME/.themes/"; then
            log_info "Installed GTK theme $gtk_theme."
        else
            log_warn "Failed to fetch Catppuccin GTK theme; GTK apps may stay light."
        fi
        rm -rf "$tmp"
    fi

    if [ -d "$HOME/.local/share/icons/Papirus-Dark" ]; then
        log_info "Papirus-Dark icons already present, skipping."
    else
        log_info "Installing Papirus icon theme to ~/.local/share/icons..."
        mkdir -p "$HOME/.local/share/icons"
        if curl -sL https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/master/install.sh \
            | DESTDIR="$HOME/.local/share/icons" sh >/dev/null 2>&1; then
            log_info "Installed Papirus icon theme."
        else
            log_warn "Failed to install Papirus icons; falling back to default icon theme."
        fi
    fi
}

# Install eww for the Dell ambient HUD (Linux/Fedora only). eww isn't in Fedora's
# base repos; the varlad/eww COPR carries an F44 build. The HUD itself only runs on
# the NVIDIA laptop (guarded on the Dell being docked in sway/config.d/local.conf),
# but the eww package + config are portable, so we install the tool on any Fedora box.
# Wallpaper rotation uses sway's own `output bg` + ImageMagick (no swww — archived).
install_hud_tools() {
    [ "$OS" = "linux" ] || return 0
    command -v dnf >/dev/null 2>&1 || return 0

    if command -v eww-x11 >/dev/null 2>&1 || command -v eww >/dev/null 2>&1; then
        log_info "eww already installed, skipping."
    else
        log_info "Installing eww (varlad/eww COPR) for the Dell ambient HUD..."
        sudo dnf copr enable -y varlad/eww >/dev/null 2>&1 \
            && sudo dnf install -y eww >/dev/null 2>&1 \
            && log_info "Installed eww." \
            || log_warn "Failed to install eww; the Dell HUD overlay won't start."
    fi

    # ImageMagick powers the center-crop in art-fetch.sh; jq/curl parse wallhaven.
    command -v magick >/dev/null 2>&1 || sudo dnf install -y ImageMagick >/dev/null 2>&1 || true
}

# Main installation flow
main() {
    log_info "Starting dotfiles bootstrap process..."
    echo

    detect_os
    echo

    install_packages
    echo

    install_sway_desktop
    echo

    setup_sudoers
    echo

    install_oh_my_zsh
    echo

    install_vim_plug
    echo

    install_tpm
    echo

    set_default_shell
    echo

    init_tldr
    echo

    seed_sway_local
    echo

    seed_xprofile_local
    seed_kitty_local
    echo

    install_gtk_theme
    echo

    install_hud_tools

    log_info "Bootstrap complete!"
    log_info "Next steps:"
    echo "  1. Run './install.sh' to symlink your dotfiles"
    echo "  2. Restart your terminal or run 'exec zsh'"
    echo "  3. Run 'p10k configure' to set up your prompt"
    echo "  4. Open tmux and press prefix+I to install plugins"
    echo "  5. Create ~/.zshrc.local for machine-specific config (CUDA, etc.)"
}

main "$@"
