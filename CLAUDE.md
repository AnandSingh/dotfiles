# CLAUDE.md — Dotfiles repo context

## What this repo is

Personal dotfiles managed with GNU Stow on Fedora Linux (Wayland/Sway). Most top-level tool directories are Stow packages; `legacy/` holds archived configs and is never stowed.

## Architecture

```
dotfiles/
├── bootstrap.sh          # Installs system packages, dev tools, Sway desktop, sudoers, oh-my-zsh, TPM
├── install.sh            # Stows packages as symlinks to $HOME
├── update.sh             # Pull + bootstrap + restow (sync existing PC)
├── remote-install.sh     # One-liner for fresh PC setup via curl
├── git/.gitconfig        # Git config — delta pager, side-by-side diffs, aliases
├── zsh/.zshrc            # Zsh — oh-my-zsh, p10k, aliases, tool integrations
├── tmux/.tmux.conf       # Tmux — prefix Ctrl+a, vim nav, resurrect+continuum auto-save
├── ghostty/.config/ghostty/ # Ghostty — preferred remote-development terminal
├── kitty/.config/kitty/  # Kitty fallback/local terminal — auto-attach tmux
├── sway/.config/sway/    # Sway WM — tiling, dropdown terminal, tabbed Chrome
│   ├── config            # Main sway config
│   └── scripts/          # Helper scripts (dropdown-autohide.sh)
├── waybar/.config/waybar/# Active Waybar status bar
├── vocalinux/            # Systemd service for remote GPU push-to-talk dictation
├── nvim/                 # Neovim config
├── vim/                  # Vim config
├── legacy/               # Archived i3/Hyprland/X11 configs and Waybar backups
└── .gitignore            # Ignores local/generated files
```

## Key conventions

- **Stow-based**: each directory mirrors `$HOME`. E.g., `zsh/.zshrc` → `~/.zshrc`, `sway/.config/sway/config` → `~/.config/sway/config`.
- **Machine-specific config** goes in `~/.zshrc.local` (not tracked). Used for CUDA paths, local env vars.
- **Sudoers**: `/etc/sudoers.d/nopasswd-safe` — passwordless sudo for dnf, systemctl, reboot, poweroff, mount, umount, dmesg, journalctl, nmap. Created by `bootstrap.sh`.
- **Lazygit** is installed from COPR (`atim/lazygit`), not Fedora repos.
- **Catppuccin Mocha** is the color theme across Ghostty, Kitty, Sway borders, and delta.

## When editing configs

- After changing a stow package, run `stow -R <package>` to re-symlink, or `./install.sh restow` for all.
- After changing `.zshrc`, user runs `source ~/.zshrc` or `src` alias.
- After changing sway config, user presses `Super+Shift+r` to reload.
- After changing Ghostty or Kitty config, user restarts that terminal.
- After changing tmux config, user runs `prefix+R` (Ctrl+a, then Shift+r).

## Dev tools installed via bootstrap

eza, fd-find, zoxide, git-delta, lazygit, fzf, ripgrep, bat, btop, tldr, dust, duf, glow, jq.

## Sway desktop installed via bootstrap (Linux)

`install_sway_desktop()` installs the compositor + the apps the stowed configs
launch: sway, swaybg/swayidle/swaylock, waybar, rofi/wofi/fuzzel, SwayNC (Mako fallback), grim,
slurp, wl-clipboard, Ghostty (remote workspace), Kitty ($term/fallback), Vocalinux (remote dictation), thunar ($filemanager), brightnessctl,
playerctl, pavucontrol, polkit-gnome, xdg-desktop-portal-wlr, fonts. GPU drivers
are NOT installed here (host-specific) — NVIDIA hosts run `nvidia-sway/install-nvidia-driver.sh`
then `install-nvidia-session.sh` (see nvidia-sway/README.md).

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

- Primary and supported WM, Wayland-only
- `Super+Return` / `Super+t` — focus existing kitty or launch new
- `` Super+` `` — toggle dropdown terminal (50% width, centered, 2px border, plain zsh, auto-hides on focus loss)
- `Super+1…9` switches to a stable workspace and launches its profile app if missing there; it never steals windows from another workspace
- `Super+Tab` searches globally; `Super+Shift+1…9` deliberately moves the focused window
- Hold the mic-mute media key (or `F10`) to dictate through private `devserver-aks` Whisper; release to paste
- GUI apps otherwise open on the currently focused workspace
- Dropdown autohide script: `sway/scripts/dropdown-autohide.sh` (runs as sway IPC listener)

## Tmux details

- Prefix: `Ctrl+a`
- Plugins via TPM: resurrect, continuum, vim-tmux-navigator, yank, copycat, pain-control
- Auto-save every 15 minutes (continuum)
- Auto-restore on startup (continuum-restore)
- Systemd service starts tmux server at login (`~/.config/systemd/user/tmux.service`)
- Ghostty opens the browser-enabled `devserver-aks` `devserver` session on workspace 2
- Kitty auto-attaches to the laptop's local `main` session via `shell tmux new-session -A -s main`

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
