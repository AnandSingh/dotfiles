#!/usr/bin/env python3
"""Live audio EQ on an iDotMatrix 32x32 BLE display.

Reads cava (default sink monitor — same audio as the on-screen HUD, incl. audio
sent to Sonos) and pushes 16 rainbow bars to the matrix over BLE at ~20fps.
Runs until killed; auto-reconnects if the BLE link or cava drops.

Needs the idotmatrix venv (see bootstrap install_hud_tools). Device address via
$IDM_MAC or the default below. The matrix must NOT be connected to its phone app
(BLE allows one link at a time).
"""
import asyncio, subprocess, colorsys, os, sys, tempfile
from PIL import Image as PImage
from idotmatrix import ConnectionManager, Image

MAC = os.environ.get("IDM_MAC", "51:A3:BC:97:69:68")
BARS, W, H = 16, 32, 32
CONF = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "idm-cava.conf")
COLS = [tuple(int(c * 255) for c in colorsys.hsv_to_rgb((i / BARS) * 0.82, 1, 1)) for i in range(BARS)]
# uploadProcessed takes a FILE PATH (not a buffer) — overwrite one temp PNG per frame.
FRAME = os.path.join(tempfile.gettempdir(), "idm-frame.png")


def render(vals):
    im = PImage.new("RGB", (W, H))
    px = im.load()
    for i, v in enumerate(vals[:BARS]):
        v = max(0, min(H, v))
        x = i * 2
        col = COLS[i]
        for y in range(H - v, H):
            px[x, y] = col
            px[x + 1, y] = col
    return im


async def run_once():
    conn = ConnectionManager()
    await conn.connectByAddress(MAC)
    img = Image()
    await img.setMode(mode=1)  # DIY/image mode
    proc = subprocess.Popen(["cava", "-p", CONF], stdout=subprocess.PIPE,
                            text=True, stderr=subprocess.DEVNULL)
    loop = asyncio.get_event_loop()
    try:
        while True:
            line = await loop.run_in_executor(None, proc.stdout.readline)
            if not line:
                break
            clean = "".join(ch for ch in line if ch.isdigit() or ch == ";").rstrip(";")
            if not clean:
                continue
            try:
                vals = [int(x) for x in clean.split(";")]
            except ValueError:
                continue
            render(vals).save(FRAME, format="PNG")
            await img.uploadProcessed(FRAME, pixel_size=32)
    finally:
        proc.terminate()
        try:
            await conn.disconnect()
        except Exception:
            pass


async def main():
    while True:
        try:
            await run_once()
        except Exception as e:
            print(f"idm-viz: {e}", file=sys.stderr)
        await asyncio.sleep(3)  # reconnect backoff


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        pass
