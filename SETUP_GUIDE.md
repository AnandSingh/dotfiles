# Setup Guide

This guide explains how to use your improved dotfiles on a new machine.

## What Changed?

Your dotfiles have been reorganized for easier setup across platforms:

- **Cross-platform support**: Now works on macOS, Fedora, and Ubuntu
- **GNU Stow integration**: Clean symlink management
- **Modular packages**: Install only what you need
- **Automated setup**: One-command installation

## File Structure

```
dotfiles/
├── bootstrap.sh          # Install dependencies (run first)
├── install.sh            # Install dotfiles with stow
├── quickstart.sh         # All-in-one setup script
├── README.md             # Full documentation
├── git/                  # Git configuration
├── zsh/                  # Zsh configuration
├── tmux/                 # Tmux configuration
├── vim/                  # Vim configuration
├── nvim/                 # Neovim configuration
└── [linux-wm packages]   # i3, hyprland, waybar, etc.
```

## Setup on New Machine

### Option 1: Fully Automated (Recommended)

```bash
# Clone your dotfiles
git clone https://github.com/AnandSingh/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run the quickstart script (does everything)
./quickstart.sh
```

### Option 2: Step-by-Step

```bash
# Clone your dotfiles
git clone https://github.com/AnandSingh/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Step 1: Install dependencies
./bootstrap.sh

# Step 2: Install safe default dotfiles (core/editor)
./install.sh
```

### Option 3: Selective Installation

```bash
# After running bootstrap.sh, install only what you need:

./install.sh core        # Just git, zsh, tmux, kitty
./install.sh editors     # Just vim and nvim
./install.sh linux-wm    # Just window managers (Linux only)
./install.sh all         # Everything, including window managers
```

## Platform-Specific Instructions

### macOS

```bash
cd ~/dotfiles
./bootstrap.sh  # Installs Homebrew if needed
./install.sh
```

### Fedora

```bash
cd ~/dotfiles
./bootstrap.sh  # Uses dnf
./install.sh
```

### Ubuntu

```bash
cd ~/dotfiles
./bootstrap.sh  # Uses apt
./install.sh
```

## Updating Your Dotfiles

After making changes to your configs:

```bash
cd ~/dotfiles
git pull              # Get latest changes
./install.sh restow   # Update symlinks
```

## Common Tasks

### Add a new config file

```bash
# 1. Add file to appropriate package
echo "alias ll='ls -la'" >> ~/dotfiles/zsh/.zshrc

# 2. Restow the package
cd ~/dotfiles
stow -R zsh

# 3. Commit changes
git add .
git commit -m "Add ll alias to zsh"
git push
```

### Create a new package

```bash
cd ~/dotfiles

# 1. Create package directory
mkdir -p myapp

# 2. Add config file
echo "config=value" > myapp/.myapprc

# 3. Stow it
stow myapp

# 4. Update install.sh to include it (optional)
```

### Remove/Unstow a package

```bash
cd ~/dotfiles
stow -D zsh  # Removes symlinks for zsh package
```

## Troubleshooting

### "Stow conflicts" error

If stow reports conflicts with existing files:

```bash
# Backup existing files
mv ~/.zshrc ~/.zshrc.backup
mv ~/.tmux.conf ~/.tmux.conf.backup

# Try again
./install.sh restow
```

### Zsh plugins not loading

Make sure Oh My Zsh is installed:

```bash
ls -la ~/.oh-my-zsh
# If not found, run:
./bootstrap.sh
```

### Neovim config not found

```bash
# Check symlink
ls -la ~/.config/nvim

# If broken, restow
cd ~/dotfiles
stow -R nvim
```

## Tips

1. **Keep it in sync**: Commit and push changes regularly
2. **Test on VM**: Try your setup on a fresh VM first
3. **Document changes**: Add comments to your configs
4. **Use private file**: Put sensitive configs in `~/.bashrc_private`

## What Gets Installed?

### bootstrap.sh installs:
- GNU Stow (symlink manager)
- Zsh (shell)
- Tmux (terminal multiplexer)
- Neovim (editor)
- Git (version control)
- Oh My Zsh + plugins
- Powerlevel10k theme
- fzf, bat (optional tools)

### install.sh creates symlinks for:
- All your configuration files
- From ~/dotfiles/* to your home directory

## Next Steps After Installation

1. Restart your terminal or run: `exec zsh`
2. Configure Powerlevel10k: `p10k configure`
3. Check neovim plugins: `nvim +PlugInstall +qall`
4. Customize as needed!

## Quick Reference

```bash
# Full setup on new machine
./quickstart.sh

# Install everything
./install.sh

# Install specific parts
./install.sh core
./install.sh editors
./install.sh linux-wm

# Update after changes
./install.sh restow

# Remove all symlinks
./install.sh uninstall

# Manual stow
stow package_name
stow -R package_name  # Restow
stow -D package_name  # Unstow
```

## Need Help?

- See [README.md](README.md) for detailed documentation
- Check [GNU Stow manual](https://www.gnu.org/software/stow/manual/stow.html)
- Review individual config files for tool-specific settings
