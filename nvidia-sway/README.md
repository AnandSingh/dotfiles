# Sway on NVIDIA

wlroots (Sway's backend) rejects the proprietary NVIDIA driver unless launched
with `--unsupported-gpu` plus a few Wayland env vars set *before* Sway starts.
gdm's session picker only runs a `.desktop` file's `Exec=` line — it can't pass
flags or env — so this directory ships a wrapper and a session entry.

## Files

| File | Purpose | Installed to |
|------|---------|--------------|
| `install-nvidia-driver.sh`  | Proprietary driver via RPM Fusion + `nvidia_drm modeset=1` | (system) |
| `install-nvidia-session.sh` | Installs the wrapper + gdm session entry | `/usr/local/...` |
| `sway-nvidia`               | Launch wrapper: env vars + `sway --unsupported-gpu` | `/usr/local/bin/` |
| `sway-nvidia.desktop`       | gdm "Sway (Nvidia)" session entry | `/usr/local/share/wayland-sessions/` |

These live in root-owned `/usr/local` (not `$HOME`), so they are **not** stowed.

## Setup order on a fresh NVIDIA host

```bash
cd ~/dotfiles
./bootstrap.sh                              # shell/dev tools + Sway packages
./install.sh all                            # stow configs (incl. sway/config.d/local.conf)
bash nvidia-sway/install-nvidia-driver.sh   # proprietary driver + modeset (Fedora)
bash nvidia-sway/install-nvidia-session.sh  # 'Sway (Nvidia)' gdm session
sudo reboot
```

After reboot: `nvidia-smi` should list the GPU. At the gdm login screen, click
the gear icon and pick **Sway (Nvidia)**.

On AMD/Intel-only hosts, skip this directory entirely — plain `sway` works.
