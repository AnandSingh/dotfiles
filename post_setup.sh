#!/bin/sh

sudo dnf install -y blackbox-terminal
exec zsh
p10k configure

sudo dnf install -y fzf bat navi cheat peco nmap inotify-tools

wget https://raw.githubusercontent.com/tmuxinator/tmuxinator/master/completion/tmuxinator.zsh -O /usr/local/share/zsh/site-functions/_tmuxinator

