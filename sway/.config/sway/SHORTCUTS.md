# Sway keyboard shortcuts

`Super` = the Windows/Mod4 key. Generated from `~/.config/sway/config`.
Open this file anytime with **`Super+Shift+/`**.

## Apps & launchers
| Keys | Action |
|------|--------|
| `Super+Return` | Terminal (kitty) |
| `Super+Space` | App launcher (fuzzel) |
| `Super+B` | Browser (Chrome) → ws2 |
| `Super+E` | File manager (Thunar) → ws4 |
| `Super+Shift+E` | Edit dotfiles (kitty + nvim) |
| `Super+V` | Clipboard history (cliphist) |

## Session
| Keys | Action |
|------|--------|
| `Super+Shift+X` | Lock screen |
| `Super+Shift+C` | Reload Sway config |
| `Super+Shift+R` | Restart Sway in place |
| `Super+Shift+Q` | Exit Sway (confirm prompt) |

## Screenshots
| Keys | Action |
|------|--------|
| `Print` | Full screen |
| `Super+Print` | Active window |
| `Shift+Print` | Select area |

## Focus (move cursor between windows)
| Keys | Action |
|------|--------|
| `Super+H / J / K / L` | Focus left / down / up / right |
| `Super+←/↓/↑/→` | Focus left / down / up / right |
| `Super+A` | Focus parent container |

## Move windows
| Keys | Action |
|------|--------|
| `Super+Shift+H/J/K/L` | Move window left / down / up / right |
| `Super+Shift+←/↓/↑/→` | Move window left / down / up / right |

## Layout
| Keys | Action |
|------|--------|
| `Super+\` | Split horizontal |
| `Super+Shift+\` | Split vertical |
| `Super+F` | Fullscreen toggle |
| `Super+S` | Stacking layout |
| `Super+W` | Tabbed layout |
| `Super+T` | Toggle split (h/v) |
| `Super+Shift+Space` | Floating toggle |
| `Super+R` | Resize mode (H/J/K/L or arrows to resize, Enter/Esc to exit) |

## Scratchpad
| Keys | Action |
|------|--------|
| `Super+Shift+-` | Move window to scratchpad |
| `Super+-` | Show / cycle scratchpad |
| `Super+N` | Toggle developer Markdown notes |
| `Super+Shift+N` | Toggle notification center |

## Workspaces
| Keys | Action |
|------|--------|
| `Super+1..0` | Switch to workspace 1–10 |
| `Super+Shift+1..0` | Move window to workspace 1–10 |

Workspace layout: `1:term  2:web  3:code  4:ops  5:docs  6:chat  7:media  8:vm  9:misc  10:float`

Auto-routed apps: Chrome/Firefox → 2:web · VS Code → 3:code · Thunar → 4:ops · Slack/Discord → 6:chat · Remmina → 8:vm

## Media & brightness (laptop function keys)
| Keys | Action |
|------|--------|
| `Volume Up/Down/Mute` | Sink volume ±5% / mute |
| `Mic Mute` | Toggle mic mute |
| `Brightness Up/Down` | Backlight ±10% |
| `Play / Next / Prev` | playerctl media control |
