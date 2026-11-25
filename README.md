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
- **Ghostty**: preferred laptop terminal for the browser-enabled `devserver-aks` remote workspace
- **Kitty**: fallback terminal and local tmux auto-attach client

### Linux Desktop (primary)
- **Sway**: primary Wayland compositor, with Waybar and named workspaces
- **Waybar**: status bar (right-click volume to pick an output; middle-click opens pavucontrol)
- **Vocalinux**: one-key push-to-talk dictation through private GPU Whisper on `devserver-aks`
- Alternate i3/Hyprland and X11 Polybar/Picom configs are archived under `legacy/` and are not installed by default.
- Additional compatibility configs: xprofile, xresources, volumeicon, screenz

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

### Fresh PC — one command

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/AnandSingh/dotfiles/main/remote-install.sh)
```

### Existing PC — pull updates

```bash
cd ~/dotfiles && ./update.sh
```

### Manual setup

```bash
git clone git@github.com:AnandSingh/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh    # install packages, dev tools, sudoers, oh-my-zsh, TPM
./install.sh      # stow all configs
source ~/.zshrc
```

### Scripts

| Script | Purpose |
|--------|---------|
| `remote-install.sh` | One-liner for brand new PC (curl + run) |
| `bootstrap.sh` | Install all system packages, tools, shell plugins |
| `install.sh` | Stow/restow/unstow dotfile symlinks |
| `update.sh` | Pull + bootstrap + restow (for syncing changes) |

See [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed post-install steps and key bindings cheatsheet.

## Usage

```bash
./install.sh              # install all
./install.sh core         # just git, zsh, tmux
./install.sh editors      # just vim, nvim
./install.sh linux-wm     # sway, Kitty fallback, Waybar, etc.
./install.sh restow       # re-symlink after changes
./install.sh uninstall    # remove all symlinks
stow zsh                  # stow a single package
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
├── ghostty/              # Preferred remote-development terminal
├── kitty/                # Kitty fallback/local terminal (auto-attach tmux)
├── vim/                  # Vim configuration
├── nvim/                 # Neovim configuration
├── sway/                 # Sway compositor + dropdown terminal
│   └── scripts/          # Sway helper scripts
├── waybar/               # Active Waybar config and custom modules
├── legacy/               # Archived alternate WMs and Waybar backups
└── ...
```

## Customization

- **Machine-specific config**: `~/.zshrc.local` (CUDA, local paths — not tracked)
- **Sudoers**: `bootstrap.sh` sets up passwordless sudo for dnf, systemctl, reboot, mount, dmesg, journalctl, nmap
- **Prompt theme**: Run `p10k configure`

## Recommended Additional Tools

All recommended tools are now installed automatically via `bootstrap.sh`. No manual installation needed.

## Platform Notes

- **Fedora** (primary): dnf, lazygit via COPR
- **macOS**: Homebrew auto-installed, Linux WM packages skipped
- **Ubuntu**: apt, `batcat` auto-linked to `bat`

## License

MIT License - Feel free to use and modify as needed.
