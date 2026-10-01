# Sway keyboard shortcuts

`Super` is the Windows/Mod4 key. The active bindings come from `config` plus this
machine's `config.d/local.conf`. Open the generated binding helper with `Super+F1`.

## Apps and workflows

| Keys | Action |
|---|---|
| `Super+Return` / `Super+T` | Focus a Kitty window or launch Kitty |
| `Super+Space` | Rofi app/window/command launcher |
| `Super+B` | Chrome on workspace 7 |
| `Super+E` | Thunar on workspace 4 |
| `Super+D` | Nexus Deck in a dedicated terminal |
| ``Super+` `` | Toggle dropdown terminal |
| `Super+N` | Open/focus Zettlr Notes on workspace 8; press again to return |
| `Super+Y` | Yazi in Kitty |
| `Super+2` | Open/focus devserver-aks tmux workspace lazily |
| `Super+3` | Open/focus telisky-ai Codex workspace lazily |

## Windows and layouts

| Keys | Action |
|---|---|
| `Alt+Tab` / `Alt+Shift+Tab` | Focus next/previous window |
| `Super+H/J/K/L` | Focus left/down/up/right |
| `Super+Shift+H/J/K/L` | Move window left/down/up/right |
| `Super+Ctrl+H/J/K/L` | Resize by 20 px |
| `Super+Q` | Close focused window |
| `Super+F` | Toggle fullscreen |
| `Super+Shift+F` | Toggle floating |
| `Super+Shift+S` | Toggle sticky |
| `Super+V` / `Super+S` | Horizontal/vertical split |
| `Super+W` | Tabbed layout |
| `Super+Shift+W` | Toggle split orientation |
| `Super+-` | Move window to scratchpad |
| `Super+=` | Show/cycle scratchpad |
| `Super+Tab` | Search and jump to any window |
| `Super+Shift+Tab` | Previous workspace on this output |

## Workspaces

| Keys | Action |
|---|---|
| `Super+1…9` | Switch workspace (`2` and `3` lazy-launch their workflows) |
| `Super+Shift+1…9` | Move focused window to workspace |
| `Super+mouse wheel` | Previous/next workspace |

Layout: `1:local tmux  2:devserver  3:Codex  4:files  5:dev GUI  6:monitoring  7:browser  8:notes  9:flex`.
Workspace 10 is disabled on this laptop.

## Clipboard and screenshots

| Keys | Action |
|---|---|
| `Super+Alt+V` | Search clipboard history |
| `Super+Shift+V` | Upload clipboard image and copy shared remote path |
| `Print` | Copy full output image |
| `Super+Print` | Save full output image |
| `Super+Shift+Print` | Select and edit an area in Swappy |
| `Alt+Print` | Copy focused window image |
| `Super+P` | Select and edit an area in Swappy |
| `Super+Shift+P` | Save full output image |
| `Super+Ctrl+P` | Copy focused window image |
| `Super+.` | Emoji picker |

## Session and hardware

| Keys | Action |
|---|---|
| `Ctrl+Alt+L` / `Super+Shift+X` | Lock manually; inactivity does not lock or suspend |
| `Super+Shift+R` | Reload Sway configuration |
| `Super+Shift+E` | Exit Sway after confirmation |
| `Ctrl+Alt+Delete` | Power menu |
| `Super+Shift+N` | Toggle SwayNC notification center |
| `Super+Shift+G` | Toggle optional Dell ambient HUD |
| Waybar `KVM → …` | Switch Dell display, keyboard, and mouse between computers |
| `Ctrl+Alt+F12` | Dell KVM keyboard fallback |
| Media keys | Volume, microphone mute, playback, and brightness (5% steps) |
