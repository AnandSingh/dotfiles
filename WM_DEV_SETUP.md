# Developer window-manager setup

Goal: fast, keyboard-first development across Wayland and X11, while keeping the existing dotfiles layout intact.

## Recommendation

- **Primary on Ubuntu 24.04: Sway** — available from Ubuntu packages, stable Wayland, great with Waybar/fuzzel/kitty.
- **Hyprland: ready-to-enable** — your repo already has a large Hyprland config; `UserConfigs/Developer.conf` adds a focused developer layer once Hyprland is installed.
- **i3: X11 fallback** — `~/.config/i3/config.dev` is a modernized config you can launch with `i3 -c ~/.config/i3/config.dev` or promote to `config` later.

Research basis: Hyprland docs recommend explicitly running missing desktop pieces (notification daemon, portal, bar, idle/lock, wallpaper, launcher); Sway add-ons recommend fuzzel/wofi/rofi, mako, swayidle/swaylock, grim/slurp, wl-clipboard; i3 remains best as the X11 fallback.

## Quick setup

```bash
cd ~/dotfiles
./setup-dev-wm.sh --packages   # installs Ubuntu packages, asks sudo
./setup-dev-wm.sh --stow       # symlinks sway, waybar dev profile, helper scripts
```

Then log out and choose **Sway** from the display manager.

## Key bindings

| Action | Sway / Hyprland dev layer | i3 dev config |
|---|---|---|
| Terminal | Super+Enter | Super+Enter |
| Launcher | Super+Space | Super+Space |
| Browser | Super+B | Super+B |
| File manager | Super+E | Super+E |
| Dotfiles editor | Super+Shift+E | Super+Shift+E |
| Clipboard history | Super+V | Super+V |
| Screenshot area | Shift+Print | Shift+Print |
| Screenshot full | Print | Print |
| Lock | Super+Shift+X | Super+Shift+X |
| Reload WM | Super+Shift+C | Super+Shift+C |
| Exit | Super+Shift+E from WM prompt | Super+Shift+Q from prompt |

Workspaces are consistent: `1 term`, `2 web`, `3 code`, `4 ops`, `5 docs`, `6 chat`, `7 media`, `8 vm`, `9 misc`, `10 float`.

## Hyprland enablement

Your existing Hyprland config currently only sources `WindowRules.conf` at the end. To enable the developer layer, add this line near the other `UserConfigs` sources in `~/.config/hypr/hyprland.conf` (or in the dotfiles source and restow):

```ini
source= $UserConfigs/Developer.conf
```

The layer starts the Waybar dev profile, sets developer keybinds, scratchpad terminal shortcuts, workspace routing, floating utility windows, and safe Wayland environment import.

## Notes

- The setup does **not** overwrite your existing i3 or Hyprland config.
- `wm-dev-waybar` chooses Sway or Hyprland Waybar config based on the current session.
- `wm-dev-menu`, `wm-dev-clipboard`, `wm-dev-screenshot`, and `wm-dev-lock` gracefully fall back based on installed tools.
