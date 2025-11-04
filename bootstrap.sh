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

            log_info "Installing packages..."
            sudo dnf install -y \
                stow \
                zsh \
                tmux \
                neovim \
                git \
                util-linux-user \
                ncurses-devel \
                libevent-devel \
                htop \
                fzf \
                bat
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

# Main installation flow
main() {
    log_info "Starting dotfiles bootstrap process..."
    echo

    detect_os
    echo

    install_packages
    echo

    install_oh_my_zsh
    echo

    install_vim_plug
    echo

    set_default_shell
    echo

    log_info "Bootstrap complete!"
    log_info "Next steps:"
    echo "  1. Run './install.sh' to symlink your dotfiles"
    echo "  2. Restart your terminal or run 'exec zsh'"
    echo "  3. Run 'p10k configure' to set up your prompt"
}

main "$@"
