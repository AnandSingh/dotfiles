# Per-machine Sway overrides

The base config ends with:

    include ~/.config/sway/config.d/*.conf

Anything in this directory ending in `.conf` is merged into the portable base
config. Use it for things that differ per machine and must NOT be committed to
the shared repo:

- monitor layout (`output ...`)
- input quirks (keyboard layout, touchpad)
- machine-only autostart apps

## `local.conf` is git-ignored

`local.conf` is the active per-machine file. It is **git-ignored** (see
`.gitignore`) so the Fedora desktop and the Ubuntu laptop do not clobber each
other's monitor setup.

`bootstrap.sh` seeds it on first install by copying the matching template from
`../examples/` based on the detected OS. To do it by hand:

    cp ~/.config/sway/examples/local.ubuntu-laptop.conf \
       ~/.config/sway/config.d/local.conf

Edit the copy freely — it stays local to this host.
