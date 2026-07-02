#!/usr/bin/env python3
"""Simple bottom-up rainbow audio EQ on an iDotMatrix 32x32 BLE display.

Minimal + smooth: cava (source=auto -> the default sink's monitor, so it follows
laptop/Sonos routing) -> 16 rainbow bars -> push each frame over BLE. No per-frame
subprocess polling, no temp configs — that machinery made it laggy/unreactive.

Robustness: scan+retry connect; keep the BLE link; restart cava if it dies; blank
the panel on exit. Needs the idotmatrix venv + cava. Address via $IDM_MAC.
"""
import asyncio, subprocess, colorsys, os, sys, tempfile, signal, shutil, contextlib
from PIL import Image as PImage
from idotmatrix import ConnectionManager, Image, FullscreenColor

MAC = os.environ.get("IDM_MAC", "51:A3:BC:97:69:68")
BARS, W, H = 16, 32, 32
CONF = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "idm-cava.conf")
FRAME = os.path.join(tempfile.gettempdir(), "idm-frame.png")
COLS = [tuple(int(c * 255) for c in colorsys.hsv_to_rgb((i / BARS) * 0.82, 1, 1)) for i in range(BARS)]
_stop = False


def render(vals):
    im = PImage.new("RGB", (W, H))
    px = im.load()
    for i, v in enumerate(vals[:BARS]):
        v = max(0, min(H, v))
        x = i * 2
        c = COLS[i]
        for y in range(H - v, H):
            px[x, y] = c
            px[x + 1, y] = c
    im.save(FRAME, format="PNG")


async def connect(conn):
    for _ in range(15):
        if _stop:
            return False
        try:
            await conn.scan()
            await conn.connectByAddress(MAC)
            return True
        except Exception as e:
            print(f"idm-viz: connect retry ({e})", file=sys.stderr)
            await asyncio.sleep(2)
    return False


async def main():
    conn = ConnectionManager()
    if not await connect(conn):
        return
    img = Image()
    await img.setMode(mode=1)
    loop = asyncio.get_event_loop()
    try:
        while not _stop:
            proc = subprocess.Popen(["cava", "-p", CONF], stdout=subprocess.PIPE,
                                    text=True, stderr=subprocess.DEVNULL)
            try:
                while not _stop:
                    line = await loop.run_in_executor(None, proc.stdout.readline)
                    if not line:
                        break  # cava died -> restart
                    clean = "".join(ch for ch in line if ch.isdigit() or ch == ";").rstrip(";")
                    if not clean:
                        continue
                    try:
                        vals = [int(x) for x in clean.split(";")]
                    except ValueError:
                        continue
                    render(vals)
                    await img.uploadProcessed(FRAME, pixel_size=32)
            finally:
                proc.terminate()
            if not _stop:
                await asyncio.sleep(1)
    finally:
        with contextlib.suppress(Exception):
            await FullscreenColor().setMode(r=0, g=0, b=0)
        with contextlib.suppress(Exception):
            await conn.disconnect()


def _sig(*_):
    global _stop
    _stop = True


if __name__ == "__main__":
    if not shutil.which("cava"):
        sys.exit("cava not installed")
    signal.signal(signal.SIGTERM, _sig)
    signal.signal(signal.SIGINT, _sig)
    with contextlib.suppress(KeyboardInterrupt):
        asyncio.run(main())
