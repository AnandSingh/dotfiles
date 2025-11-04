#!/bin/bash

# One-command dotfiles setup
# This script runs both bootstrap and install in sequence

set -e

echo "=========================================="
echo "  Dotfiles Quick Start"
echo "=========================================="
echo

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$SCRIPT_DIR"

# Run bootstrap
if [ -f "bootstrap.sh" ]; then
    echo "Step 1/2: Running bootstrap..."
    echo
    ./bootstrap.sh
else
    echo "ERROR: bootstrap.sh not found!"
    exit 1
fi

echo
echo "=========================================="
echo

# Run install
if [ -f "install.sh" ]; then
    echo "Step 2/2: Installing dotfiles..."
    echo
    ./install.sh
else
    echo "ERROR: install.sh not found!"
    exit 1
fi

echo
echo "=========================================="
echo "  Setup Complete!"
echo "=========================================="
echo
echo "Next steps:"
echo "  1. Restart your terminal or run: exec zsh"
echo "  2. Configure your prompt: p10k configure"
echo "  3. Enjoy your new dev environment!"
echo
