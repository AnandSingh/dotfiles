# devserver workspace

The laptop uses workspace 2 as the persistent terminal view into `devserver-aks`.

| Workspace | App | Purpose |
|---|---|---|
| 2 | `kitty-plain` → `remote-tmux-kitty` | One Kitty tab per remote tmux session on `devserver-aks`. |

The portable Sway config starts it lazily on the first `Super+2` press:

```sway
bindsym $mod+2 exec ~/.local/bin/ws-launch 2
assign [app_id="kitty-plain"] workspace number 2
```

`ws-launch` invokes `remote-tmux-kitty` only when workspace 2 has no windows.

The host-side tmux sessions persist independently of the laptop display session.
Moonlight is no longer installed or launched by this laptop configuration.
