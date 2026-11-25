# devserver workspace

The laptop uses workspace 2 as the persistent terminal view into `devserver-aks`.

| Workspace | App | Purpose |
|---|---|---|
| 2 | Ghostty when installed, otherwise `kitty-plain` | Attach to the persistent `devserver` tmux session on `devserver-aks`. |

The portable Sway config starts it lazily on the first `Super+2` press through
the named workspace manager:

```sway
bindsym $mod+2 exec ~/.local/bin/workspace open remote
```

The terminal runs `~/.local/bin/devserver`, which ensures the laptop's dedicated
browser-harness Chrome listener is running and then calls:

```bash
ts-devserver --browser --session devserver
```

The SSH reverse tunnel makes the laptop browser available to remote agents at
`127.0.0.1:49222`; `browser-harness --doctor` on the server verifies it. The
tunnel follows the terminal connection, while the host-side tmux session and
its jobs persist independently when the laptop disconnects or suspends.

Ghostty is preferred automatically when available and uses the dedicated
Wayland application ID `com.telisky.devserver`. Kitty remains the fallback with
application ID `kitty-plain`. Moonlight is no longer installed or launched by
this laptop configuration.
