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
- Installed tmux TPM at ~/.tmux/plugins/tpm.
- Installed vim-plug for Neovim.
- Applied stow packages: git, zsh, tmux, vim, nvim.
- Existing generated ~/.zshrc was backed up to ~/.dotfiles-backup-20260529-081034.

## Dotfiles changes made locally

- install.sh: no longer hides stow errors.
- bootstrap.sh: added useful Ubuntu packages: ripgrep, fd-find, bat, jq, unzip, ca-certificates, wl-clipboard, xclip, bc.
- zsh/.zshrc: removed hardcoded /home/anandsingh/anaconda3; added portable conda detection; added batcat/fdfind compatibility aliases.
- zsh/.bashrc_private: removed unsafe sudo password pattern and Fedora-only aliases; added safe apt/dnf aliases and editor defaults.
- tmux/.tmux.conf: clipboard copy now supports wl-copy, xclip, or xsel.
- bootstrap.sh: installs kitty on Ubuntu, installs missing Oh My Zsh plugins even if Oh My Zsh already exists, and checks the actual login shell before chsh.
- install.sh/kitty: added kitty as a core stow package with a basic portable kitty config.
- hyprland/.config/hypr/hyprland.conf: switched default terminal to kitty and commented machine-specific monitor layout in favor of portable autodetection.

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

## Next steps after login

1. Confirm zsh is default:
   echo $SHELL
   ps -p $$ -o comm=

2. Shell/tmux/nvim smoke tests passed after login:
   zsh -i -c 'echo zsh ok'
   tmux -V
   nvim --version | head

3. In tmux, install plugins: prefix + I. Prefix is Ctrl-a.

4. Change login shell to zsh when ready:
   chsh -s /usr/bin/zsh

5. Continue Hyprland audit before stowing the hyprland package on this Ubuntu/NVIDIA hybrid laptop.
