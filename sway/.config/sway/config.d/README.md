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
`../examples/`. Selection is by OS, and for Fedora — where both the desktop and
the ThinkPad report `OS=fedora` — by `hostnamectl chassis`:

| Host                  | Template                     |
|-----------------------|------------------------------|
| Fedora, chassis laptop| `local.fedora-laptop.conf`   |
| Fedora, chassis desktop| `local.fedora-desktop.conf` |
| Ubuntu                | `local.ubuntu-laptop.conf`   |
| other                 | `local.conf.example`         |

Seeding is one-shot: if `local.conf` already exists it's left untouched, so a
`git pull` never clobbers a host's live tweaks. To re-seed by hand:

    cp ~/.config/sway/examples/local.fedora-laptop.conf \
       ~/.config/sway/config.d/local.conf

Edit the copy freely — it stays local to this host.
