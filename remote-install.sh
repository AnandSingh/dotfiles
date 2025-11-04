#!/bin/bash

# Remote dotfiles installer
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/remote-install.sh)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/YOUR_USERNAME/dotfiles.git"
DOTFILES_DIR="${HOME}/dotfiles"
BRANCH="main"

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

log_section() {
    echo
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
}

# Check if git is installed
check_git() {
    if ! command -v git &> /dev/null; then
        log_error "Git is not installed!"
        log_info "Installing git..."

        # Detect OS and install git
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS - prompt for Xcode Command Line Tools
            log_info "Please install Xcode Command Line Tools when prompted..."
            xcode-select --install || true
            log_info "Waiting for Xcode installation to complete..."
            read -p "Press Enter once Xcode Command Line Tools are installed..."
        elif [[ -f /etc/os-release ]]; then
            . /etc/os-release
            case "$ID" in
                fedora)
                    sudo dnf install -y git
                    ;;
                ubuntu|debian)
                    sudo apt update
                    sudo apt install -y git
                    ;;
                *)
                    log_error "Unable to automatically install git on $ID"
                    log_error "Please install git manually and run this script again"
                    exit 1
                    ;;
            esac
        else
            log_error "Unable to detect OS to install git"
            log_error "Please install git manually and run this script again"
            exit 1
        fi
    fi

    log_info "Git is installed: $(git --version)"
}

# Clone or update dotfiles repository
clone_dotfiles() {
    if [ -d "$DOTFILES_DIR" ]; then
        log_warn "Dotfiles directory already exists at $DOTFILES_DIR"

        read -p "Do you want to update it? (y/N): " -n 1 -r
        echo

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Updating existing dotfiles..."
            cd "$DOTFILES_DIR"

            # Stash any local changes
            if ! git diff-index --quiet HEAD -- 2>/dev/null; then
                log_warn "You have uncommitted changes. Stashing them..."
                git stash
            fi

            git pull origin "$BRANCH"
            log_info "Dotfiles updated!"
        else
            log_info "Using existing dotfiles..."
        fi
    else
        log_info "Cloning dotfiles from $REPO_URL..."
        git clone "$REPO_URL" "$DOTFILES_DIR"
        log_info "Dotfiles cloned successfully!"
    fi
}

# Make scripts executable
make_executable() {
    log_info "Making scripts executable..."
    chmod +x "$DOTFILES_DIR"/*.sh 2>/dev/null || true
}

# Run bootstrap script
run_bootstrap() {
    if [ -f "$DOTFILES_DIR/bootstrap.sh" ]; then
        log_section "Running Bootstrap"
        cd "$DOTFILES_DIR"
        ./bootstrap.sh
    else
        log_error "bootstrap.sh not found in $DOTFILES_DIR"
        exit 1
    fi
}

# Run install script
run_install() {
    if [ -f "$DOTFILES_DIR/install.sh" ]; then
        log_section "Installing Dotfiles"
        cd "$DOTFILES_DIR"

        # Ask user what to install
        echo "What would you like to install?"
        echo "  1) Everything (recommended)"
        echo "  2) Core only (git, zsh, tmux)"
        echo "  3) Core + Editors (add vim, nvim)"
        echo "  4) Custom selection"
        read -p "Enter choice [1-4]: " -n 1 -r
        echo

        case $REPLY in
            1)
                ./install.sh all
                ;;
            2)
                ./install.sh core
                ;;
            3)
                ./install.sh core
                ./install.sh editors
                ;;
            4)
                echo "Available packages:"
                echo "  - core (git, zsh, tmux)"
                echo "  - editors (vim, nvim)"
                echo "  - linux-wm (i3, hyprland, etc.)"
                echo
                read -p "Enter packages separated by space: " packages
                for pkg in $packages; do
                    ./install.sh "$pkg"
                done
                ;;
            *)
                log_warn "Invalid choice. Installing everything..."
                ./install.sh all
                ;;
        esac
    else
        log_error "install.sh not found in $DOTFILES_DIR"
        exit 1
    fi
}

# Print completion message
print_completion() {
    log_section "Setup Complete!"

    cat << EOF
${GREEN}Your dotfiles have been successfully installed!${NC}

${YELLOW}Next steps:${NC}
  1. Restart your terminal or run: ${BLUE}exec zsh${NC}
  2. Configure your prompt: ${BLUE}p10k configure${NC}
  3. Install Neovim plugins: ${BLUE}nvim +PlugInstall +qall${NC}

${YELLOW}Your dotfiles are located at:${NC} ${BLUE}$DOTFILES_DIR${NC}

${YELLOW}To update your dotfiles in the future:${NC}
  ${BLUE}cd $DOTFILES_DIR${NC}
  ${BLUE}git pull${NC}
  ${BLUE}./install.sh restow${NC}

${YELLOW}For more information:${NC}
  ${BLUE}cat $DOTFILES_DIR/README.md${NC}
  ${BLUE}cat $DOTFILES_DIR/SETUP_GUIDE.md${NC}

${GREEN}Enjoy your new development environment!${NC}
EOF
}

# Main installation flow
main() {
    log_section "Dotfiles Remote Installer"

    log_info "This script will:"
    echo "  1. Clone your dotfiles repository"
    echo "  2. Install required dependencies"
    echo "  3. Symlink your configuration files"
    echo

    read -p "Continue? (y/N): " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Installation cancelled."
        exit 0
    fi

    check_git
    clone_dotfiles
    make_executable
    run_bootstrap
    run_install
    print_completion
}

# Run main function
main "$@"
