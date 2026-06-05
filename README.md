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
- **Tmux**: Terminal multiplexer with auto-save/restore (resurrect + continuum)

### Editors
- **Vim**: Classic text editor with sensible defaults
- **Neovim**: Modern Vim with plugins

### Terminal
- **Kitty**: GPU-accelerated terminal (auto-attaches to tmux)

### Linux Window Managers (Linux only)
- **Sway**: Wayland tiling compositor (primary) — quake dropdown terminal, tabbed Chrome profiles, auto-focus workspaces
- **i3**: Tiling window manager (X11 fallback)
- **Hyprland**: Wayland compositor
- **Waybar**: Status bar for Wayland
- **Polybar**: Status bar for X11
- **Picom**: Compositor for X11
- Additional: xprofile, xresources, volumeicon, screenz

### Dev Tools (installed via bootstrap)
- **eza**: Modern `ls` with icons and git status
- **fd**: Fast `find` replacement
- **ripgrep**: Fast `grep` replacement
- **fzf**: Fuzzy finder
- **bat**: `cat` with syntax highlighting
- **zoxide**: Smarter `cd` — learns your frequent dirs
- **delta**: Beautiful git diffs with syntax highlighting
- **lazygit**: Terminal UI for git
- **btop**: System monitor
- **dust**: Visual disk usage
- **duf**: Pretty `df` replacement
- **tldr**: Simplified man pages
- **glow**: Render markdown in terminal

## Quick Start

### Option 1: One-Command Remote Install (Easiest)

On a completely fresh machine, just run this single command:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/AnandSingh/dotfiles/main/remote-install.sh)
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
git clone https://github.com/AnandSingh/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

This will:
1. Detect your OS (macOS, Fedora, or Ubuntu)
2. Install required packages (stow, zsh, tmux, neovim, etc.)
3. Install dev tools (eza, fd, zoxide, delta, lazygit, btop, etc.)
4. Setup passwordless sudo for safe commands (dnf, systemctl, reboot, etc.)
5. Install Oh My Zsh with plugins and powerlevel10k theme
6. Install vim-plug for Neovim
7. Install TPM for Tmux
8. Set Zsh as your default shell

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
├── bootstrap.sh          # System setup (packages, sudoers, plugins)
├── install.sh            # Stow symlinks
├── git/                  # Git configuration
├── zsh/                  # Zsh + aliases + dev shortcuts
├── tmux/                 # Tmux with resurrect + continuum
├── kitty/                # Kitty terminal (auto-attach tmux)
├── vim/                  # Vim configuration
├── nvim/                 # Neovim configuration
├── sway/                 # Sway compositor + dropdown terminal
│   └── scripts/          # Sway helper scripts
├── waybar/               # Waybar status bar
├── i3/                   # i3 window manager
├── hyprland/             # Hyprland compositor
├── polybar/              # Polybar status bar
├── picom/                # Picom compositor
└── ...
```

## Customization

### Machine-Specific Configuration

For machine-specific settings (CUDA paths, local env vars), use `~/.zshrc.local`:

```bash
# ~/.zshrc.local (not tracked in git)
export PATH=/usr/local/cuda-12.8/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64:${LD_LIBRARY_PATH}
```

This file is sourced by `.zshrc` if it exists.

### Passwordless Sudo

Bootstrap configures passwordless sudo for safe commands:
- `dnf` — package management
- `systemctl` — service management
- `reboot` / `poweroff` — system control
- `mount` / `umount` — drives
- `dmesg` / `journalctl` — logs
- `nmap` — network scanning

Config lives at `/etc/sudoers.d/nopasswd-safe`.

### Powerlevel10k Theme

On first run, configure your prompt:

```bash
p10k configure
```

## Recommended Additional Tools

All recommended tools are now installed automatically via `bootstrap.sh`. No manual installation needed.

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
