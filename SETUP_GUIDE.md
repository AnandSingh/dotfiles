# Setup Guide

## Fresh PC Setup (from scratch)

On a brand new Fedora machine, run this single command:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/AnandSingh/dotfiles/main/remote-install.sh)
```

Or manually:

```bash
git clone git@github.com:AnandSingh/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh   # install packages, dev tools, sudoers, oh-my-zsh, TPM
./install.sh      # stow all configs
```

### After install

```bash
# Reload shell
exec zsh

# Configure prompt theme
p10k configure

# Open tmux and install plugins
tmux
# Press Ctrl+a, then I (capital i) to install tmux plugins

# Create machine-specific config (if needed)
nvim ~/.zshrc.local
```

Example `~/.zshrc.local` for a CUDA machine:

```bash
export PATH=/usr/local/cuda-12.8/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64:${LD_LIBRARY_PATH}
```

---

## Update Existing PC

When you've made changes on another machine and want to sync:

```bash
cd ~/dotfiles
./update.sh
```

This pulls latest changes, installs any new packages, and re-stows configs.

---

## What Gets Installed

### Packages (via bootstrap.sh)

| Category | Tools |
|----------|-------|
| **Core** | stow, zsh, tmux, neovim, git |
| **Search** | fzf, ripgrep, fd-find |
| **Viewing** | bat, eza, glow, delta |
| **Navigation** | zoxide |
| **Git** | lazygit (via COPR) |
| **System** | btop, dust, duf |
| **Docs** | tldr |
| **JSON** | jq |

### Configs (via install.sh)

| Package | What it configures |
|---------|-------------------|
| **zsh** | Shell aliases, dev shortcuts, tool integrations, p10k theme |
| **git** | Delta pager, side-by-side diffs, aliases |
| **tmux** | Prefix `Ctrl+a`, vim nav, auto-save/restore, plugins |
| **kitty** | Catppuccin theme, auto-attach tmux, clipboard |
| **sway** | Tiling WM, dropdown terminal, tabbed Chrome, auto-focus |
| **waybar** | Status bar |
| **nvim** | Neovim config |

### Sudoers (passwordless)

These commands won't need a password:
- `dnf` — package management
- `systemctl` — services
- `reboot` / `poweroff`
- `mount` / `umount`
- `dmesg` / `journalctl`
- `nmap`

---

## Key Bindings Cheatsheet

### Sway

| Binding | Action |
|---------|--------|
| `Super+Return` | Focus existing terminal (or open new) |
| `` Super+` `` | Toggle dropdown terminal |
| `Super+h/j/k/l` | Focus left/down/up/right |
| `Super+Shift+h/j/k/l` | Move window |
| `Super+1-9` | Switch workspace |
| `Super+Shift+r` | Reload sway config |
| `Super+b` | Open browser |
| `Super+e` | Open file manager |
| `Super+w` | Toggle tabbed layout |

### Tmux (prefix = Ctrl+a)

| Binding | Action |
|---------|--------|
| `Ctrl+a, \|` | Split horizontal |
| `Ctrl+a, -` | Split vertical |
| `Ctrl+a, h/j/k/l` | Navigate panes |
| `Ctrl+a, c` | New window |
| `Shift+Left/Right` | Switch window |
| `Ctrl+a, Ctrl+s` | Save session |
| `Ctrl+a, Ctrl+r` | Restore session |

### Shell Aliases

| Alias | Command |
|-------|---------|
| `ll` | `eza -la --icons --git` |
| `lt` | `eza -T --icons --level=2` |
| `cat` | `bat --paging=never` |
| `lg` | `lazygit` |
| `top` | `btop` |
| `z <dir>` | `zoxide` — smart cd |
| `dots` | `cd ~/dotfiles` |
| `zrc` | Edit zshrc |
| `src` | Reload zshrc |
| `glog` | Pretty git log |
| `gd` | Git diff (with delta) |
| `Ctrl+t` | fzf file search |
| `Ctrl+r` | fzf history search |

---

## Troubleshooting

### Stow conflicts

```bash
cd ~/dotfiles
stow --adopt zsh    # adopts existing file into dotfiles
git diff            # review what changed
git checkout -- .   # revert if the dotfiles version was better
stow -R zsh         # re-stow
```

### Tools not found after install

```bash
source ~/.zshrc
```

### Tmux plugins not loading

Inside tmux: `Ctrl+a`, then `Shift+I` to install plugins.

### Lazygit not in dnf

```bash
sudo dnf copr enable atim/lazygit -y
sudo dnf install -y lazygit
```

### Delta theme not found

```bash
delta --list-syntax-themes    # list available themes
# Edit ~/.gitconfig and change syntax-theme if needed
```
