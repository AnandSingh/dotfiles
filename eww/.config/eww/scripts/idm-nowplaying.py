#!/usr/bin/env python3
"""Now-playing music info on an iDotMatrix 32x32 BLE display.

Polls playerctl (MPRIS) and, when the track (or play/pause state) changes, pushes
a scrolling "Title — Artist" to the matrix. The device does the scrolling itself,
so we only send on change → almost no BLE traffic → no stalling (unlike the
real-time EQ, which the BLE link can't sustain). Shows a paused marker when
paused and a clock when nothing is playing.

Needs the idotmatrix venv + playerctl. Address via $IDM_MAC. Matrix must not be on
its phone app.
"""
import asyncio, subprocess, os, sys, signal, contextlib
from idotmatrix import ConnectionManager, Text, Clock

MAC = os.environ.get("IDM_MAC", "51:A3:BC:97:69:68")
COLOR = (137, 180, 250)  # Catppuccin blue
# Text.setMode needs a real font file (font_path=None -> "cannot open resource").
FONT = next((p for p in (
    "/usr/share/fonts/liberation-sans-fonts/LiberationSans-Regular.ttf",
    "/usr/share/fonts/jetbrains-mono-fonts/JetBrainsMono-Regular.otf",
    "/usr/share/fonts/dejavu-sans-fonts/DejaVuSans.ttf",
) if os.path.exists(p)), None)
_stop = False


def player_state():
    """(status, 'Title — Artist') from the first active player, or ('', '')."""
    try:
        status = subprocess.run(["playerctl", "status"], capture_output=True,
                                text=True, timeout=2).stdout.strip()
    except Exception:
        return "", ""
    if status not in ("Playing", "Paused"):
        return status, ""
    meta = subprocess.run(["playerctl", "metadata", "--format", "{{title}} — {{artist}}"],
                          capture_output=True, text=True, timeout=2).stdout.strip()
    return status, meta


async def connect(conn):
    for _ in range(15):
        if _stop:
            return False
        try:
            await conn.scan(); await conn.connectByAddress(MAC); return True
        except Exception as e:
            print(f"idm-nowplaying: connect retry ({e})", file=sys.stderr)
            await asyncio.sleep(2)
    return False


async def main():
    conn = ConnectionManager()
    if not await connect(conn):
        return
    text = Text(); clock = Clock()
    last = None
    try:
        while not _stop:
            status, meta = player_state()
            key = (status, meta)
            if key != last:
                last = key
                with contextlib.suppress(Exception):
                    if status == "Playing" and meta:
                        await text.setMode(meta, font_size=16, font_path=FONT, speed=60,
                                           text_color=COLOR)
                    elif status == "Paused" and meta:
                        await text.setMode("|| " + meta, font_size=16, font_path=FONT,
                                           speed=60, text_color=(148, 148, 148))
                    else:
                        await clock.setMode(style=1)  # nothing playing -> clock
            await asyncio.sleep(2)
    finally:
        with contextlib.suppress(Exception):
            await clock.setMode(style=1)  # leave a clock, not a frozen frame
        with contextlib.suppress(Exception):
            await conn.disconnect()


def _sig(*_):
    global _stop; _stop = True


if __name__ == "__main__":
    if not __import__("shutil").which("playerctl"):
        sys.exit("playerctl not installed")
    signal.signal(signal.SIGTERM, _sig)
    signal.signal(signal.SIGINT, _sig)
    with contextlib.suppress(KeyboardInterrupt):
        asyncio.run(main())
