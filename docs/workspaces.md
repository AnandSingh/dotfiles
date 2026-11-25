# Sway workspace management

The workspace system uses one canonical map across Sway, Waybar, and the helper
commands:

| Workspace | Name | Purpose |
|---:|---|---|
| 1 | `terminal` | Local tmux session |
| 2 | `remote` | `devserver-aks` remote tmux |
| 3 | `ai` | Telisky AI/Codex workflow |
| 4 | `files` | Thunar/Yazi |
| 5 | `code` | Editors and coding tools |
| 6 | `ops` | Nexus, logs, and monitoring |
| 7 | `web` | Browser work |
| 8 | `notes` | Zettlr and research notes |
| 9 | `flex` | Temporary work |

## Commands

```bash
workspace open remote       # focus and lazily start a profile
workspace open notes
workspace status             # show window counts
workspace overview           # interactive Rofi workspace picker
workspace reset code         # confirm, close all windows, reopen profile
workspace reset code --yes   # non-interactive reset
```

`ws-launch NUMBER` remains as a compatibility wrapper for existing scripts.

## Keyboard shortcuts

### Long-running commands

Use `watchdone npm test` or `watchdone make build` in a tmux pane, then keep
working elsewhere. When the command exits, a desktop notification reports its
command, result, and elapsed seconds. Its tmux window shows `[OK]` or
`[FAIL:exit-code]`. Press `Ctrl+a`, then `g` to return to the most recently
completed command's pane in your current session and clear that window's marker.
Each window shows its latest completion; this is not a queue of every result.
An older window's marker is replaced by its next completion.

Input/output stay in the original terminal, and the command's exit code is
preserved. For pipelines, use `watchdone bash -c 'make build && make test'`.
Outside tmux, terminal output and desktop notifications still work. On a remote
host the helper must be installed there; desktop notifications require a usable
desktop notification service on that host and are not forwarded over SSH.

### Desktop navigation

- `Super+1…9`: switch to a workspace; launch its profile if absent there
- `Super+2`: switch to remote development
- `Super+3`: switch to the AI workflow
- `Super+Shift+Space`: open the workspace overview
- `Super+Tab`: search every open window

## Profile behavior

Workspace keys are predictable destinations. `Super+1…9` always switches to
that numbered workspace; if its profile app is not already there, it launches
there even when other windows are present. Windows on other workspaces are not
pulled away or silently focused. Use
`Super+Tab` to find and focus any existing window across workspaces. To move a
window deliberately, use `Super+Shift+1…9`.

Opening a profile workspace launches its app only if that app is not already
on the destination workspace (other windows may remain there). Current profiles
are:

- `remote`: Ghostty when installed, otherwise Kitty, running `~/.local/bin/devserver`
- `ai`: `~/.local/bin/telisky-ai-codex-workspace`
- `files`: `thunar`
- `code`: Kitty + tmux session `code`
- `ops`: `~/.local/bin/nexusctl dashboard --new-terminal`
- `web`: `google-chrome --new-window`
- `notes`: `~/.config/sway/scripts/notes-workspace.sh`

The `terminal` and `flex` workspaces are intentionally launch-free.

The manager checks whether the profile app is already on the destination
workspace before launching, uses a runtime lock to prevent duplicate launches
from repeated key presses, and waits for the new Sway window before explicitly
focusing it. This avoids stealing an app from a different workspace or leaving
focus on the previous application. Missing machine-specific launchers produce
a desktop notification instead of failing silently.

## Profile safety

Apps in other workspaces are left where they are; profile shortcuts never
silently move or focus them. Missing machine-specific launchers generate a
desktop notification rather than failing silently. Generic manually launched
windows are not force-focused.

## Remote sessions and lid-close behavior

Long-running agents, builds, and development servers must run inside a tmux
session on the remote host—not in a local terminal or an unwrapped SSH command.
The `devserver` shortcut attaches to the `devserver` tmux session on `devserver-aks`;
`Super+2` opens the same browser-enabled remote workspace. It uses SSH reverse
forwarding so server-side `browser-harness` controls the dedicated Chrome
instance on the laptop. Detaching or losing the SSH connection removes that
browser bridge but does not stop processes running in remote tmux. After the
laptop suspends on lid close, reopen the terminal and reattach to the same
session; the bridge is restored automatically.

This laptop is expected to suspend when its lid closes. Do not disable lid
suspend just to keep remote work running: the server-side tmux session continues
while the laptop sleeps, and sleeping saves power. Work running only in a local
shell, local tmux, or an SSH command without remote tmux is not protected from
client disconnects.

SSH uses a short-lived connection-sharing socket for repeated remote commands.
Tailscale may still relay traffic through DERP when it cannot negotiate a direct
peer path; SSH multiplexing reduces repeated connection setup but does not fix
that network path. A direct Tailscale route depends on both peers' networks and
firewalls.

## Tailscale direct path

`devserver-aks` has a direct Tailscale path through the pfSense UDP `41641`
forward to its reserved address. The host firewall allows that port; SSH/TCP 22
is not exposed to WAN. Verify with `tailscale ping devserver-aks`; direct paths
can fall back to DERP when the network changes or direct UDP is unavailable.

The remote tmux server has Continuum boot/restore enabled and saves every five
minutes. That protects session layout across tmux/server restarts where commands
can be relaunched, but a server reboot cannot preserve an arbitrary in-flight
process; use the server's own service manager for workloads that must survive
server reboots.
