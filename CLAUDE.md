# CLAUDE.md — Dotfiles repo context

## What this repo is

Personal dotfiles managed with GNU Stow on Fedora Linux (Wayland/Sway). Each top-level directory is a stow package — its contents get symlinked to `$HOME`.

## Architecture

```
dotfiles/
├── bootstrap.sh          # Installs system packages, dev tools, sudoers, oh-my-zsh, TPM
├── install.sh            # Stows packages as symlinks to $HOME
├── update.sh             # Pull + bootstrap + restow (sync existing PC)
├── remote-install.sh     # One-liner for fresh PC setup via curl
├── git/.gitconfig        # Git config — delta pager, side-by-side diffs, aliases
├── zsh/.zshrc            # Zsh — oh-my-zsh, p10k, aliases, tool integrations
├── tmux/.tmux.conf       # Tmux — prefix Ctrl+a, vim nav, resurrect+continuum auto-save
├── kitty/.config/kitty/  # Kitty terminal — Catppuccin Mocha, auto-attach tmux
├── sway/.config/sway/    # Sway WM — tiling, dropdown terminal, tabbed Chrome
│   ├── config            # Main sway config
│   └── scripts/          # Helper scripts (dropdown-autohide.sh)
├── waybar/.config/waybar/# Waybar status bar
├── nvim/                 # Neovim config
├── vim/                  # Vim config
├── i3/                   # i3 WM (X11 fallback)
├── hyprland/             # Hyprland compositor
├── polybar/              # Polybar (X11)
├── picom/                # Picom compositor (X11)
└── .gitignore            # Ignores *.bak.* files
```

## Key conventions

- **Stow-based**: each directory mirrors `$HOME`. E.g., `zsh/.zshrc` → `~/.zshrc`, `sway/.config/sway/config` → `~/.config/sway/config`.
- **Machine-specific config** goes in `~/.zshrc.local` (not tracked). Used for CUDA paths, local env vars.
- **Sudoers**: `/etc/sudoers.d/nopasswd-safe` — passwordless sudo for dnf, systemctl, reboot, poweroff, mount, umount, dmesg, journalctl, nmap. Created by `bootstrap.sh`.
- **Lazygit** is installed from COPR (`atim/lazygit`), not Fedora repos.
- **Catppuccin Mocha** is the color theme across kitty, sway borders, and delta.

## When editing configs

- After changing a stow package, run `stow -R <package>` to re-symlink, or `./install.sh restow` for all.
- After changing `.zshrc`, user runs `source ~/.zshrc` or `src` alias.
- After changing sway config, user presses `Super+Shift+r` to reload.
- After changing kitty config, user restarts kitty.
- After changing tmux config, user runs `prefix+R` (Ctrl+a, then Shift+r).

## Dev tools installed via bootstrap

eza, fd-find, zoxide, git-delta, lazygit, fzf, ripgrep, bat, btop, tldr, dust, duf, glow, jq.

All wired into zsh via aliases in `.zshrc`:
- `ls/ll/lt` → eza
- `cat` → bat
- `ff/fdir` → fd
- `lg` → lazygit
- `top` → btop
- `du` → dust
- `df` → duf
- `z` → zoxide (smart cd)
- `gd/gds/glog` → git with delta
- `Ctrl+t` → fzf file picker
- `Ctrl+r` → fzf history search

## Sway details

- Primary WM, Wayland-only
- `Super+Return` / `Super+t` — focus existing kitty or launch new
- `` Super+` `` — toggle dropdown terminal (50% width, centered, 2px border, plain zsh, auto-hides on focus loss)
- Chrome profiles open tabbed on workspace 2
- Apps auto-focus their assigned workspace when opened
- Dropdown autohide script: `sway/scripts/dropdown-autohide.sh` (runs as sway IPC listener)

## Tmux details

- Prefix: `Ctrl+a`
- Plugins via TPM: resurrect, continuum, vim-tmux-navigator, yank, copycat, pain-control
- Auto-save every 15 minutes (continuum)
- Auto-restore on startup (continuum-restore)
- Systemd service starts tmux server at login (`~/.config/systemd/user/tmux.service`)
- Kitty auto-attaches to session `main` via `shell tmux new-session -A -s main`

## Git details

- Pager: delta (side-by-side, line numbers, Catppuccin Mocha theme)
- Merge conflict style: zdiff3
- Extensive alias set in `.gitconfig`

## Scripts

| Script | When to use |
|--------|-------------|
| `remote-install.sh` | Brand new PC — curl one-liner |
| `bootstrap.sh` | Fresh clone — install all system deps |
| `install.sh` | Stow/restow/unstow configs |
| `fixmylinux` | Doctor/repair/sync this machine. `fixmylinux doctor` (read-only health check), `fixmylinux fix` (restow + reseed), bare `fixmylinux` (full sync). Stowed to `~/.local/bin` via the `bin` package. |
| `update.sh` | Thin shim → `fixmylinux` (kept for compatibility) |

`fixmylinux` also has a Claude skill at `.claude/skills/fixmylinux/SKILL.md` (tracked; the rest of `.claude/` is git-ignored) — say "fix my linux" / `/fixmylinux` and Claude runs the doctor, explains failures, and confirms before any mutating command.
