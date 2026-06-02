# Installation Commands

Quick reference for installing dotfiles on a new machine.

## One-Line Remote Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/AnandSingh/dotfiles/main/remote-install.sh)
```

**Note:** Replace `AnandSingh` with your GitHub username before using!

---

## Alternative Installation Methods

### Method 1: Quickstart (Automated)
```bash
git clone https://github.com/AnandSingh/dotfiles.git ~/dotfiles
cd ~/dotfiles
./quickstart.sh
```

### Method 2: Step-by-Step
```bash
git clone https://github.com/AnandSingh/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh  # Install dependencies
./install.sh    # Install safe default dotfiles (core/editor)
```

### Method 3: Selective Install
```bash
git clone https://github.com/AnandSingh/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
./install.sh core       # Just git, zsh, tmux, kitty
./install.sh editors    # Just vim, nvim
./install.sh linux-wm   # Just window managers
./install.sh all        # Everything, including window managers
```

---

## Platform-Specific One-Liners

### macOS
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/AnandSingh/dotfiles/main/remote-install.sh)
```

### Fedora
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/AnandSingh/dotfiles/main/remote-install.sh)
```

### Ubuntu
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/AnandSingh/dotfiles/main/remote-install.sh)
```

---

## Post-Installation

```bash
# Restart your shell
exec zsh

# Configure your prompt
p10k configure

# Install Neovim plugins
nvim +PlugInstall +qall
```

---

## Update Dotfiles

```bash
cd ~/dotfiles
git pull
./install.sh restow
```

---

## Uninstall

```bash
cd ~/dotfiles
./install.sh uninstall
```

---

## Need Help?

See [README.md](README.md) or [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed documentation.
