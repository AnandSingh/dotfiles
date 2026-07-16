#!/usr/bin/env bash
set -euo pipefail

notes_dir="${XDG_STATE_HOME:-$HOME/.local/state}/dev-notes"
notes_file="$notes_dir/scratch.md"

mkdir -p "$notes_dir"

if [[ ! -e "$notes_file" ]]; then
    printf '# Scratch notes\n\n' >"$notes_file"
fi

exec flatpak run org.gnome.gitlab.somas.Apostrophe "$notes_file"
