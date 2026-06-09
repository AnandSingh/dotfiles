# xprofile per-machine overrides

`~/.xprofile` is **common** to every host (stowed from `xprofile/.xprofile`).
It ends by sourcing `~/.xprofile.local` if present.

`~/.xprofile.local` is **per-machine** and **git-ignored**. `bootstrap.sh`
(`seed_xprofile_local`) copies the matching template here on each host:

| Host type      | Template                          |
|----------------|-----------------------------------|
| Fedora desktop | `local.fedora-desktop.xprofile`   |
| Ubuntu laptop  | `local.ubuntu-laptop.xprofile`    |
| anything else  | `local.xprofile.example`          |

Seeding skips if `~/.xprofile.local` already exists, so your edits survive.

## Sync a machine's config back into the repo

To share a host's setup, copy its live file into the matching template and commit:

```sh
cp ~/.xprofile.local dotfiles/xprofile/examples/local.fedora-desktop.xprofile
```

Note: `.xprofile` is X11-only. Wayland/Sway sessions ignore it entirely.
