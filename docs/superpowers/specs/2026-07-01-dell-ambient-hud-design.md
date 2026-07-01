# Dell Ambient HUD — Design

**Date:** 2026-07-01
**Status:** Approved design, revised after adversarial review (rev 2)
**Machine scope:** Fedora NVIDIA ThinkPad (laptop) only — the shared desktop must not get this.

## Purpose

The laptop runs two stacked 4K externals; the **Dell (top monitor)** is mounted high
and neck-unfriendly. Its workspaces (6–9) already reserve the top third (720px) as an
empty strip (windows tile in the lower two-thirds). This project fills that strip with
an **ambient, eye-candy HUD**: rotating art, a minimal clock, rotating quotes, and a
no-audio ambient animation.

Explicitly **ambient / aesthetic**, not an info dashboard.

## Non-goals

- No real audio/cava visualizer (audio plays elsewhere) — CSS animation instead.
- No info-dense dashboard. Not for the desktop. Not shown when undocked (Dell absent).

## Architecture

Two draw layers inside the Dell top strip (3840×720 at output origin — Dell is the top
output at y=0, `transform 180`, connector currently `DP-1`, model `DELL P3222QE`):

1. **Wallpaper via sway itself** — `swaymsg output <Dell-connector> bg <file> fill`.
   sway owns the background layer per-output and swaps it live. Auto-fetched wallhaven
   art. **No swww** (archived 2025-10-31, renamed `awww`, CLI removed) and **no manual
   swaybg** process juggling. Trade-off: hard cut between images, **no fade** (accepted).
2. **`eww`** — layer-shell widget overlay, anchored to the **top 720px** of the Dell,
   transparent background (art shows through), layer `bottom`, non-exclusive, not
   focusable. Hosts clock, quote, ambient animation. `bottom` layer renders **above**
   the sway background but **below** xdg windows, so it shows in the empty strip and can
   never cover the tiled windows in the lower two-thirds. (Verified: layer order is
   `background < bottom < top < overlay`.)

```
┌─────────────────────────────────────────────────────────────┐ y=0
│  14:32                                            Tue 1 Jul   │
│  Wed Jul 01          ▁▃▅▇▅▃▁ ▁▃▅▇▅▃▁  (ambient anim)          │
│  "The best way out is always through." — Frost               │
│   [ scrim gradient for legibility ] [ art behind everything ]│
└─────────────────────────────────────────────────────────────┘ y=720
   ── seam (waybar sits here) ──   ws6–9 windows tile below (y≈724)
```

Note: **waybar already renders on the Dell** (position bottom, at the seam ~y2128) —
no overlap with the strip, but the Dell is not truly bare. Leaving waybar as-is.

## Components

### 1. art-fetch.sh  (the piece the adversarial review flagged hardest)
- **Self-detect the sway socket** (a `systemd --user` oneshot does NOT inherit
  `SWAYSOCK`/`WAYLAND_DISPLAY`): if unset, derive
  `SWAYSOCK="$(ls "$XDG_RUNTIME_DIR"/sway-ipc.*.sock | head -1)"` — mirrors the repo's
  existing env-recovery idiom in `bin/.local/bin/tmux-paste-image`.
- **Early-exit if the Dell is absent**:
  `swaymsg -t get_outputs | grep -q "DELL P3222QE" || exit 0` — skips the download too,
  so an armed timer after undock does nothing (no journal spam, no wasted GET).
- **Resolve the Dell connector by model** (never trust index/`DP-1`):
  `conn=$(swaymsg -t get_outputs | jq -r '.[]|select(.model=="DELL P3222QE").name')`.
- Query wallhaven: `GET https://wallhaven.cc/api/v1/search?purity=100&sorting=random&atleast=3840x2160&ratios=16x9` (SFW → **no API key**). Parse the first result's
  `path` with `jq`. Optional search `&q=<tag>` (default empty; tunable var).
- Download to `~/.cache/dell-hud/current.<ext>` (temp then atomic move). On any network
  failure: log + keep the current image (never blank).
- Apply: `swaymsg output "$conn" bg "$file" fill`.

### 2. quote.sh + quotes.txt
- `quotes.txt` — one `text — author` per line, ~30 seeded, user-editable, tracked.
- `quote.sh` — `shuf -n1 quotes.txt`. Offline, no flaky quote API.

### 3. eww widgets (eww.yuck + eww.scss)
- **clock** — `HH:MM` big (JetBrains Mono Light ~64px) + date; `defpoll` time 1s, date 60s.
- **quote** — `defpoll quote.sh` every 30s; SCSS fade on change.
- **ambient animation** — pure SCSS `@keyframes` fake-EQ bars (staggered heights). No
  data source. (NVIDIA note below — may fall back to software GTK rendering.)
- **scrim** — the widget container gets `background: linear-gradient(rgba(0,0,0,.45),
  rgba(0,0,0,.15))` + `text-shadow: 0 2px 6px rgba(0,0,0,.8)` on clock/quote so text
  stays legible over bright/busy random art. (Adversarial: real defect without this.)
- **window** — `defwindow dell-hud`: geometry top-anchored 3840×720, `:stacking "bottom"`,
  `:exclusive false`, `:focusable false`. `:monitor` is **not hardcoded** — passed at
  launch via `eww open dell-hud --screen "$conn"` (verify installed eww supports
  `--screen <name>`; else fall back to resolved index).

### 4. hud-start.sh  (single idempotent launcher — the redock/idempotency fix)
One guarded helper, both exec'd once at login AND bound to a key for dock-after-login:
- Guard: `swaymsg -t get_outputs | grep -q "DELL P3222QE"` — else exit (undocked → no HUD,
  no wasted daemons; all daemon starts live inside this one guard).
- Resolve `conn` by model.
- `pgrep -x eww >/dev/null || eww daemon` (eww refuses double-start).
- Idempotent open: `eww active-windows | grep -q dell-hud || eww open dell-hud --screen "$conn"`.
- `systemctl --user start dell-hud-art.timer`.
- Immediate first fetch with readiness (sway bg is always ready; just run art-fetch.sh once).
- Also runs the ws6–9 gap loop (fold the existing `$mod+Shift+g` logic in here).

## Packaging

- New **tracked** stow package `eww/` → `~/.config/eww/`:
  `eww.yuck`, `eww.scss`, `scripts/{art-fetch.sh,quote.sh,hud-start.sh}`, `quotes.txt`,
  and systemd units `dell-hud-art.service` + `dell-hud-art.timer`
  (stowed to `~/.config/systemd/user/`).
- **Laptop-only launch** in git-ignored `sway/.config/sway/config.d/local.conf`:
  - `exec <path>/hud-start.sh` (once at login; daemons persist across `swaymsg reload`,
    so **not** `exec_always` — a bare `eww open` under exec_always would error each reload).
  - Replace the current gaps-only `$mod+Shift+g` bind with `bindsym $mod+Shift+g exec
    <path>/hud-start.sh` (now also (re)starts the HUD after docking).
  - Optional (nice-to-have, not required): an output-hotplug IPC listener modeled on
    `sway/scripts/dropdown-autohide.sh` to auto-start/stop on dock/undock.
- **bootstrap.sh** — `install_hud_tools()`: `dnf copr enable -y varlad/eww` + `dnf install
  -y eww` (Fedora 44 chroot confirmed). No wallpaper install needed (sway/swaybg present).
  Add `eww` to `LINUX_WM_PACKAGES` in install.sh.

## NVIDIA risk (revised)

- Wallpaper path is **NVIDIA-safe** (sway/swaybg, shm) — the swww-black-screen fear was
  overstated and now moot (swww dropped).
- **eww is the NVIDIA test item**: GTK3 + `wlr-layer-shell` + GDK-EGL has a history of
  issues on NVIDIA-Wayland. Worst case = software GTK rendering (works, slower); the SCSS
  animation may not be GPU-composited. Mitigation env if it misrenders:
  `GSK_RENDERER=cairo` / `GDK_BACKEND=wayland`. Gate acceptance on a real `grim` capture.

## Edge cases

- **Undocked**: guard skips everything → no HUD, no daemons. Verified pattern
  (`local.conf` already wraps the gap in one `grep DELL && { … }`).
- **Reload**: `exec` doesn't re-run; daemons persist; gap persists. No relaunch storm.
- **Dock mid-session**: `$mod+Shift+g` → `hud-start.sh` (re)starts everything idempotently.
- **Undock while timer armed**: art-fetch early-exits (Dell absent) → no spam/waste.
- **Network down**: art-fetch keeps last image; never blanks.

## Verification

1. Launch on Dell → `grim -o <conn>` → clock+date+quote+animation render upright in the
   top 720px, art visible behind, text legible (scrim working).
2. ws6–9 windows still start y≈724 (strip intact).
3. `systemctl --user start dell-hud-art.service` → wallpaper changes (proves the
   SWAYSOCK self-detect works from the systemd path — the blocker-#3 regression test).
4. Disable Dell (simulate undock) → HUD absent, timer fire is a clean no-op.
5. `swaymsg reload` → HUD persists, no duplicate daemons.
6. eww renders correctly on NVIDIA (or software-fallback env applied).

## Decisions locked

- Wallpaper: **sway `output bg` + fetch timer** (swww dropped; no fades).
- Widgets: **eww** from `varlad/eww` COPR.
- Quotes: **local file** (offline).
- Animation: **fake-EQ SCSS bars**.
- Fetch interval: **20 min** (systemd user timer).
- Monitor targeting: **model→connector resolved at launch**, never hardcoded index.
