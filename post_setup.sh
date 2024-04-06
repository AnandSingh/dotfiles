#!/bin/sh

sudo dnf install -y blackbox-terminal
exec zsh
p10k configure
