# Ubuntu dev environment setup session notes

Date: 2026-05-29
Host user: aks
Repo: /home/aks/dotfiles
Working branch: setup-ubuntu-aks

## Completed

- Installed basic tools manually: git, stow, zsh, tmux, neovim, curl/wget, build-essential, htop, fzf, ripgrep, fd-find, bat, jq, unzip, ca-certificates.
- Cloned dotfiles repo to ~/dotfiles.
- Created branch: setup-ubuntu-aks.
- Installed Oh My Zsh, zsh-autosuggestions, zsh-syntax-highlighting, powerlevel10k.
- Installed tmux TPM at ~/.tmux/plugins/tpm and installed configured tmux plugins.
- Installed vim-plug for Neovim.
- Applied stow packages: git, zsh, tmux, vim, nvim.
- Existing generated ~/.zshrc was backed up to ~/.dotfiles-backup-20260529-081034.

## Dotfiles changes made locally

- install.sh: no longer hides stow errors.
- bootstrap.sh: added useful Ubuntu packages: ripgrep, fd-find, bat, jq, unzip, ca-certificates, wl-clipboard, xclip, bc.
- zsh/.zshrc: removed hardcoded /home/anandsingh/anaconda3; added portable conda detection; added batcat/fdfind compatibility aliases.
- zsh/.bashrc_private: removed unsafe sudo password pattern and Fedora-only aliases; added safe apt/dnf aliases and editor defaults.
- tmux/.tmux.conf: clipboard copy now supports wl-copy, xclip, or xsel.
- tmux/.tmux.conf: enabled mouse support, truecolor/kitty terminal support, current-directory pane/window creation, richer split/kill/layout/find/tree bindings, larger scrollback, and mouse/vi copy-mode clipboard integration.
- bootstrap.sh: installs kitty on Ubuntu, installs missing Oh My Zsh plugins even if Oh My Zsh already exists, and checks the actual login shell before chsh.
- install.sh/kitty: added kitty as a core stow package with a basic portable kitty config; made default install safe (core/editor only) and kept desktop/window-manager configs behind explicit linux-wm/all commands.
- hyprland/.config/hypr/hyprland.conf: switched default terminal to kitty and commented machine-specific monitor layout in favor of portable autodetection.
- kitty/.config/kitty/kitty.conf: added a softer dark-navy color palette instead of pure black.
- zsh/.p10k.zsh: added Powerlevel10k config to the repo; kept two-line prompt and changed prompt char to `$`.
- Hyprland config audit: changed default Ubuntu apps to firefox/nautilus, disabled optional missing startup components (ags, swaync, pyprland, hypridle), and moved QuickEdit to Super+Shift+E to avoid conflicting with file manager on Super+E.
- install.sh: linux-wm install now warns if key desktop tools such as Hyprland, waybar, rofi, or wl-paste are missing.
- GNOME dock: applied compact bottom auto-hide Ubuntu Dock settings as a stable default.
- GNOME/Plank: added `gnome` stow package with Plank autostart and helper scripts (`apply-gnome-dev-desktop`, `enable-plank-dock`, `apply-plank-dev-dock`); stowed it locally.
- Plank is installed and running. Ubuntu Dock disabled. Plank dev dock pinned apps are Kitty, Files, and Chrome; noisy defaults such as Videos, Calendar, Image Viewer, Remmina, Thunderbird, and Firefox were removed.

## Current symlinks

- ~/.zshrc -> ~/dotfiles/zsh/.zshrc
- ~/.tmux.conf -> ~/dotfiles/tmux/.tmux.conf
- ~/.gitconfig -> ~/dotfiles/git/.gitconfig
- ~/.vimrc -> ~/dotfiles/vim/.vimrc
- ~/.config/nvim -> ~/dotfiles/nvim/.config/nvim

## System notes

- Ubuntu 24.04.4 LTS.
- Current desktop session before logout was GNOME X11.
- GPU: Intel TigerLake-H UHD + NVIDIA RTX 3070 Mobile/Max-Q.
- Hyprland should be handled carefully because NVIDIA hybrid laptop + Ubuntu needs deliberate setup.
- Ubuntu apt did not show Hyprland from currently enabled repos.
- Current GNOME/X11 system has firefox, nautilus, nm-applet, wl-paste; missing Hyprland, waybar, rofi, swaync, ags, pyprland, cliphist, hypridle/hyprlock, wlogout, grim/slurp/swappy.

## Next steps after login

1. Confirm zsh is default:
   echo $SHELL
   ps -p $$ -o comm=

2. Shell/tmux/nvim smoke tests passed after login:
   zsh -i -c 'echo zsh ok'
   tmux -V
   nvim --version | head

3. Tmux plugins are installed. If plugins are changed later, use prefix + I. Prefix is Ctrl-a.

4. Change login shell to zsh when ready:
   chsh -s /usr/bin/zsh

5. Decide Hyprland installation route for Ubuntu 24.04/NVIDIA hybrid laptop. Do not stow/launch the full Hyprland desktop until Hyprland, waybar, rofi, xdg-desktop-portal-hyprland, screenshot/clipboard utilities, and NVIDIA Wayland prerequisites are installed.

## Reboot checkpoint - 2026-05-29

User is rebooting to test the desktop/session changes.

### Active/current choices

- Hyprland is paused. Prefer stable GNOME setup for now.
- GNOME Ubuntu Dock was disabled in favor of Plank.
- Plank is installed/running and managed through dotfiles package `gnome`.
- Current Plank pinned apps: Kitty, Files/Nautilus, Chrome. Firefox intentionally removed.
- Re-apply Plank setup with: `apply-plank-dev-dock`.
- Open Plank preferences with: `plank --preferences`.
- Restore stable Ubuntu bottom dock with: `apply-gnome-dev-desktop`.

### Terminal/shell choices

- Kitty uses softer dark-navy theme, not pure black.
- Kitty explicit close-tab key: Ctrl+Shift+Q.
- Zsh uses Powerlevel10k from `zsh/.p10k.zsh`, two-line prompt retained, prompt char changed to `$`.

### Tmux choices

- Prefix remains Ctrl-a for now.
- Tmux mouse enabled, richer split/copy/navigation config added.
- Tmux plugins installed.
- tmux-continuum/resurrect configured:
  - autosave interval: 10 minutes
  - auto restore: on
  - systemd boot: on
  - start command: `new-session -d -s main`
- User systemd tmux service exists at `~/.config/systemd/user/tmux.service` and is enabled.

### After reboot quick checks

```bash
pgrep -a plank
ls -l ~/.config/autostart/plank.desktop
systemctl --user status tmux.service --no-pager
tmux ls || true
gsettings get net.launchpad.plank.dock.settings:/net/launchpad/plank/docks/dock1/ dock-items
git -C ~/dotfiles status --short
```

### Uncommitted dotfiles work before reboot

```text
 M SETUP_SESSION_NOTES.md
 M hyprland/.config/hypr/UserConfigs/Startup_Apps.conf
 M hyprland/.config/hypr/hyprland.conf
 M install.sh
 M kitty/.config/kitty/kitty.conf
 M tmux/.tmux.conf
?? gnome/
?? zsh/.p10k.zsh
```
