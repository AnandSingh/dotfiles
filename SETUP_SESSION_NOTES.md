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

2. Install remaining clipboard package if not done:
   sudo apt install -y wl-clipboard

3. Install recommended developer terminal. Current recommendation: kitty.
   sudo apt install -y kitty

4. Test shell/tmux/nvim:
   zsh -i -c 'echo zsh ok'
   tmux -V
   nvim --version | head

5. In tmux, install plugins: prefix + I. Prefix is Ctrl-a.

6. Commit local dotfiles fixes:
   cd ~/dotfiles
   git status
   git add bootstrap.sh install.sh zsh/.zshrc zsh/.bashrc_private tmux/.tmux.conf SETUP_SESSION_NOTES.md
   git commit -m 'Fix Ubuntu dev environment bootstrap and shell configs'

7. Continue with terminal config and Hyprland audit.
