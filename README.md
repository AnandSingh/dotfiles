# Dotfiles

Modern development environment configuration for macOS and Linux (Fedora, Ubuntu).

This dotfiles repository uses [GNU Stow](https://www.gnu.org/software/stow/) for clean, modular dotfile management.

## Features

- **Cross-platform**: Works on macOS, Fedora, and Ubuntu
- **Modular**: Install only what you need
- **Easy setup**: One-command installation
- **Version controlled**: Track all your configs in git

## What's Included

### Core Tools
- **Git**: Version control configuration
- **Zsh**: Shell with Oh My Zsh, powerlevel10k theme, and useful plugins
- **Tmux**: Terminal multiplexer for efficient workflow

### Editors
- **Vim**: Classic text editor with sensible defaults
- **Neovim**: Modern Vim with plugins

### Linux Window Managers (Linux only)
- **i3**: Tiling window manager
- **Hyprland**: Wayland compositor
- **Waybar**: Status bar for Wayland
- **Polybar**: Status bar for X11
- **Picom**: Compositor for X11
- Additional: xprofile, xresources, volumeicon, screenz

## Quick Start

### Option 1: One-Command Remote Install (Easiest)

On a completely fresh machine, just run this single command:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/remote-install.sh)
```

This will:
1. Install git (if needed)
2. Clone your dotfiles repository
3. Install all dependencies
4. Symlink your configurations
5. Prompt you for installation options

### Option 2: Manual Setup

Clone this repository and run the bootstrap script:

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

This will:
1. Detect your OS (macOS, Fedora, or Ubuntu)
2. Install required packages (stow, zsh, tmux, neovim, etc.)
3. Install Oh My Zsh with plugins and powerlevel10k theme
4. Install vim-plug for Neovim
5. Set Zsh as your default shell

### Install Dotfiles

After bootstrapping, install your dotfiles:

```bash
./install.sh
```

That's it! Restart your terminal and you're ready to go.

## Advanced Usage

### Install Specific Packages

```bash
# Install only core tools (git, zsh, tmux)
./install.sh core

# Install only editors (vim, nvim)
./install.sh editors

# Install Linux window manager configs (Linux only)
./install.sh linux-wm

# Install everything
./install.sh all
```

### Update Dotfiles

After making changes to your dotfiles:

```bash
./install.sh restow
```

### Uninstall

Remove all symlinks:

```bash
./install.sh uninstall
```

## Manual Installation

If you prefer to install specific packages manually:

```bash
# Using stow to install individual packages
cd ~/dotfiles
stow zsh      # Install zsh configuration
stow tmux     # Install tmux configuration
stow nvim     # Install neovim configuration
```

## Package Structure

Each directory is a "stow package" that contains dotfiles for a specific tool:

```
dotfiles/
├── git/              # Git configuration
├── zsh/              # Zsh configuration
├── tmux/             # Tmux configuration
├── vim/              # Vim configuration
├── nvim/             # Neovim configuration
├── i3/               # i3 window manager
├── hyprland/         # Hyprland compositor
├── waybar/           # Waybar status bar
├── polybar/          # Polybar status bar
├── picom/            # Picom compositor
└── ...
```

## Customization

### Private Configuration

For machine-specific or private settings, use `.bashrc_private`:

```bash
# ~/.bashrc_private
export PRIVATE_API_KEY="your-key-here"
```

This file is sourced by `.zshrc` if it exists.

### Powerlevel10k Theme

On first run, configure your prompt:

```bash
p10k configure
```

## Recommended Additional Tools

Consider installing these optional tools for enhanced productivity:

- [fzf](https://github.com/junegunn/fzf) - Fuzzy finder
- [bat](https://github.com/sharkdp/bat) - Better `cat` with syntax highlighting
- [z](https://github.com/rupa/z) - Quick directory navigation
- [diff-so-fancy](https://github.com/so-fancy/diff-so-fancy) - Better git diffs
- [autojump](https://github.com/wting/autojump) - Smart directory jumping
- [tmuxinator](https://github.com/tmuxinator/tmuxinator) - Tmux session manager
- [navi](https://github.com/denisidoro/navi) - Interactive cheatsheet tool
- [ripgrep](https://github.com/BurntSushi/ripgrep) - Fast grep alternative
- [fd](https://github.com/sharkdp/fd) - Fast find alternative

## Troubleshooting

### Stow Conflicts

If you get "existing target is not owned by stow" errors:

```bash
# Backup existing files
mv ~/.zshrc ~/.zshrc.backup
mv ~/.tmux.conf ~/.tmux.conf.backup

# Then restow
./install.sh restow
```

### Zsh Not Default Shell

If zsh isn't your default shell after installation:

```bash
chsh -s $(which zsh)
```

Then log out and back in.

### Neovim Plugins Not Installing

Run vim-plug manually:

```bash
nvim +PlugInstall +qall
```

## Platform-Specific Notes

### macOS
- Homebrew is installed automatically if not present
- Some Linux packages (window managers) are skipped

### Fedora
- Uses `dnf` package manager
- Installs development tools and dependencies

### Ubuntu
- Uses `apt` package manager
- `bat` is installed as `batcat`, automatically linked to `bat`

## Contributing

Feel free to fork this repository and customize it for your needs!

## License

MIT License - Feel free to use and modify as needed.
