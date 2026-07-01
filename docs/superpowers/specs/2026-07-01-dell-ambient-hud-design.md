# Dell Ambient HUD — Design

**Date:** 2026-07-01
**Status:** Approved (pending spec review)
**Machine scope:** Fedora NVIDIA ThinkPad (laptop) only — the shared desktop must not get this.

## Purpose

The laptop runs two stacked 4K externals; the **Dell (top monitor)** is mounted high
and is neck-unfriendly to look at. Its workspaces (6–9) already reserve the top
third (720px) as an empty strip (windows tile in the lower two-thirds). This project
fills that empty top strip with an **ambient, eye-candy HUD**: rotating art, a minimal
clock, rotating quotes, and a no-audio ambient animation.

Explicitly **ambient / aesthetic**, not an info dashboard. No system stats, no agenda,
no real audio visualizer (audio rarely plays on this machine).

## Non-goals

- No real audio/cava visualizer (audio plays elsewhere) — use a CSS animation instead.
- No info-dense dashboard (stats, calendar, mail).
- Not for the desktop machine. Not shown when undocked (Dell absent).

## Architecture

Two draw layers inside the Dell top strip (3840×720 at output origin, since Dell is
the top output at y=0):

1. **`swww`** — rotating wallpaper daemon. Draws auto-fetched wallhaven art across the
   whole Dell output as the background layer. Only the top 720px is visible; tiled
   windows in the lower two-thirds cover the rest. Fade transition on change.
2. **`eww`** — layer-shell widget overlay, anchored to the **top 720px** of the Dell,
   transparent background (art shows through), layer `bottom`, non-exclusive (the
   720px gap already reserves the space; the overlay must not add its own exclusive
   zone). Hosts the clock, quote, and ambient animation.

```
┌─────────────────────────────────────────────────────────────┐ y=0
│  14:32                                            Tue 1 Jul   │
│  Wed Jul 01          ▁▃▅▇▅▃▁ ▁▃▅▇▅▃▁  (ambient anim)          │
│  "The best way out is always through." — Frost               │
│        [ full-bleed wallhaven art behind everything ]        │
└─────────────────────────────────────────────────────────────┘ y=720
   ── seam ──   ws6–9 windows tile below (unchanged, start y≈724)
```

## Components

### 1. art-fetch.sh
- Queries the wallhaven API (`https://wallhaven.cc/api/v1/search`), params:
  purity=100 (SFW), sorting=random, `atleast=3840x2160`, ratios=16x9. Optional
  search tag (default: none / "nature landscape" — tunable in a variable).
- Downloads one random result to `~/.cache/dell-hud/current.<ext>` (temp then move).
- Calls `swww img --outputs <Dell connector> --transition-type fade
  --transition-duration 2 <file>`.
- No API key (SFW needs none). On network failure: log and keep the current image
  (never blank the screen).
- Trigger: a **systemd user timer** `dell-hud-art.timer` (OnUnit ~20 min) +
  `dell-hud-art.service` (oneshot). Chosen over a sleep-loop for reliability and
  because the box already uses user services (tmux.service).

### 2. quote.sh + quotes.txt
- `quotes.txt` — one quote per line, `text — author` format, seeded with ~30 quotes,
  user-editable. Tracked in the eww package.
- `quote.sh` — prints a random line (`shuf -n1`). Local/offline (no flaky quote API).
- eww polls it on an interval.

### 3. eww widgets (eww.yuck + eww.scss)
- **clock** — `HH:MM` big (JetBrains Mono Light ~64px) + date line, via eww `defpoll`
  on `date` (1s / 30s split: time 1s, date 60s).
- **quote** — `defpoll` on `quote.sh` every 30s, fades on change (SCSS transition).
- **ambient animation** — pure SCSS `@keyframes`: a row of bars with staggered
  height animation (fake-EQ) OR a slow drifting gradient. No data source, ~0 CPU.
- **window** — `defwindow dell-hud`: `:monitor` = Dell, `:geometry` top-anchored
  3840×720, `:stacking "bottom"`, `:exclusive false`, `:focusable false`.

## Packaging

- New **tracked** stow package `eww/` → `~/.config/eww/`:
  `eww.yuck`, `eww.scss`, `scripts/art-fetch.sh`, `scripts/quote.sh`, `quotes.txt`.
- Systemd units in the same package (stowed to `~/.config/systemd/user/`):
  `dell-hud-art.service`, `dell-hud-art.timer`.
- **Laptop-only launch** lives in git-ignored `sway/.config/sway/config.d/local.conf`,
  guarded on the Dell being docked (reuse the `grep "DELL P3222QE"` pattern):
  - start `swww-daemon` + `eww daemon` + `eww open dell-hud`,
  - `systemctl --user start dell-hud-art.timer` and do one immediate fetch.
  Runs once at login via `exec` (daemons persist across `swaymsg reload`).
- **bootstrap.sh**: new `install_hud_tools()` — install `eww` and `swww`
  (Fedora: not in base repos → COPR `atim/eww` / build via cargo; swww via COPR or
  cargo). Add `eww` to `LINUX_WM_PACKAGES` in install.sh.

## Edge cases

- **Undocked** (no Dell): guard skips launch → no HUD, no wasted daemons for the strip.
- **Reload** (`swaymsg reload`): daemons already running; `eww open` is idempotent; the
  gap persists. No relaunch storm.
- **Dock mid-session**: `$mod+Shift+g` re-applies the gap; add the HUD launch to that
  same helper (or a sibling bind) so docking restores the strip.
- **Network down**: art-fetch keeps the last image; never blanks.
- **Multi-monitor identity**: swww/eww target the Dell by connector at launch; if the
  connector name changes on replug, the launch guard greps by model, and swww/eww
  resolve the current Dell output.

## Resource budget

- swww idle: ~0 CPU, one decoded image in VRAM.
- eww idle: low; SCSS keyframe animation is GPU-composited, trivial.
- art-fetch: one HTTP GET + one image decode every ~20 min.

## Verification

1. Launch on Dell, `grim -o <Dell>` screenshot → confirm clock + date + quote + animation
   render in the top 720px, art visible behind.
2. Confirm ws6–9 windows still start at y≈724 (strip layout intact).
3. Trigger `dell-hud-art.service` manually → art changes with fade.
4. Simulate undocked (disable Dell) → HUD absent, no errors.
5. `swaymsg reload` → HUD persists, no duplicate daemons.

## Open tunables (defaults chosen, user can change later)

- Art tag/theme: default broad SFW landscape; editable in art-fetch.sh.
- Animation style: fake-EQ bars (default) vs drifting gradient.
- Fetch interval: 20 min default.
- Quote source: local file (chosen) vs online API (rejected for reliability).
