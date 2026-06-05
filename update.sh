#!/bin/bash

# Update dotfiles on an existing machine
# Pulls latest changes, installs new packages, re-stows configs

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
step() { echo -e "\n${BLUE}==>${NC} $1"; }

cd "$DOTFILES_DIR"

step "Pulling latest changes"
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    warn "You have uncommitted changes — stashing them"
    git stash
    STASHED=1
fi
git pull --rebase origin main
if [ "$STASHED" = "1" ]; then
    git stash pop || warn "Stash pop had conflicts — resolve manually"
fi
log "Up to date"

step "Installing any new packages"
./bootstrap.sh

step "Re-stowing configs"
./install.sh restow

step "Reloading shell config"
# Can't source in a script for the parent shell, just remind
log "Done! Run 'source ~/.zshrc' or open a new terminal to pick up changes."

echo ""
echo -e "${GREEN}✅ Dotfiles updated successfully!${NC}"
