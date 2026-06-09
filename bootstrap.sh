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
                fzf

            # bat is called batcat on Ubuntu
            if ! command -v bat &> /dev/null && command -v batcat &> /dev/null; then
                mkdir -p ~/.local/bin
                ln -sf /usr/bin/batcat ~/.local/bin/bat
            fi
            ;;
    esac

    log_info "Packages installed successfully!"
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

    local template
    case "$OS" in
        fedora) template="$examples/local.fedora-desktop.conf" ;;
        ubuntu) template="$examples/local.ubuntu-laptop.conf" ;;
        *)      template="$examples/local.conf.example" ;;
    esac

    [ -f "$template" ] || template="$examples/local.conf.example"

    mkdir -p "$conf_dir"
    cp "$template" "$target"
    log_info "Seeded Sway local.conf from $(basename "$template")"
}

# Main installation flow
main() {
    log_info "Starting dotfiles bootstrap process..."
    echo

    detect_os
    echo

    install_packages
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

    log_info "Bootstrap complete!"
    log_info "Next steps:"
    echo "  1. Run './install.sh' to symlink your dotfiles"
    echo "  2. Restart your terminal or run 'exec zsh'"
    echo "  3. Run 'p10k configure' to set up your prompt"
    echo "  4. Open tmux and press prefix+I to install plugins"
    echo "  5. Create ~/.zshrc.local for machine-specific config (CUDA, etc.)"
}

main "$@"
