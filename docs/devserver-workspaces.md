# devserver workspaces (ws8 terminal / ws9 desktop stream)

The laptop acts as a window into `devserver-aks` (the Fedora desktop PC):

| Workspace | App | What it is |
|---|---|---|
| 8 | kitty → `et devserver-aks -c "tmux new -As main"` | Persistent PC terminal. Eternal Terminal survives wifi drops/roaming; tmux session `main` survives everything else. |
| 9 | Moonlight (flatpak) | Full PC desktop streamed from Sunshine (VAAPI hardware encode) on the ultrawide. |

## Pieces

- **`bin/.local/bin/ws-launch <num>`** — focuses the workspace; if it has no
  windows, relaunches its assigned app. Bound to `$mod+8` / `$mod+9`.
- **Machine config** (git-ignored `sway/.config/sway/config.d/local.conf` on the
  laptop) carries the autostart + assigns + bindings:

```
assign [title="^devserver-main$"] workspace number 8
assign [app_id="com.moonlight_stream.Moonlight"] workspace number 9
exec kitty --title devserver-main -e et devserver-aks -c 'tmux new -As main'
exec flatpak run com.moonlight_stream.Moonlight
bindsym $mod+8 exec ~/.local/bin/ws-launch 8
bindsym $mod+9 exec ~/.local/bin/ws-launch 9
```

## Host side (devserver-aks)

- Sunshine runs as a user service (`~/.config/systemd/user/sunshine.service`,
  WantedBy=graphical-session.target), web UI :47990, VAAPI encoders via RPM
  Fusion `intel-media-driver`.
- `et.service` (Eternal Terminal server) enabled, port 2022 open in firewalld.
- tmux with resurrect + continuum keeps the `main` session alive across reboots.
