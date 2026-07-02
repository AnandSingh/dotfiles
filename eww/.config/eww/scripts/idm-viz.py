#!/usr/bin/env python3
"""Live audio EQ on an iDotMatrix 32x32 BLE display.

Reads cava on the CURRENT default sink's monitor (same audio as the on-screen HUD,
incl. audio routed to Sonos via the viz_tap sink) and pushes 16 rainbow bars to the
matrix over BLE at ~20fps.

Robustness:
- connects BLE once, then keeps the link (reconnects only if it drops);
- follows the default sink: re-resolves its monitor and restarts cava when the
  default changes (route laptop<->Sonos without freezing);
- if cava exits, restarts it without dropping the BLE link;
- blanks the panel on exit (SIGTERM/SIGINT) so it doesn't freeze on the last frame.

Needs the idotmatrix venv (bootstrap install_hud_tools). Address via $IDM_MAC. The
matrix must NOT be connected to its phone app (BLE allows one link).
"""
import asyncio, subprocess, colorsys, os, sys, tempfile, signal, shutil, contextlib
from PIL import Image as PImage
from idotmatrix import ConnectionManager, Image, FullscreenColor

MAC = os.environ.get("IDM_MAC", "51:A3:BC:97:69:68")
BARS, W, H = 16, 32, 32
BASE_CONF = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "idm-cava.conf")
FRAME = os.path.join(tempfile.gettempdir(), "idm-frame.png")
COLS = [tuple(int(c * 255) for c in colorsys.hsv_to_rgb((i / BARS) * 0.82, 1, 1)) for i in range(BARS)]

_stop = False


def default_monitor():
    out = subprocess.run(["pactl", "get-default-sink"], capture_output=True, text=True)
    return out.stdout.strip() + ".monitor"


def cava_conf_for(monitor):
    conf = tempfile.NamedTemporaryFile("w", suffix=".conf", delete=False)
    with open(BASE_CONF) as f:
        for line in f:
            conf.write("source = %s\n" % monitor if line.startswith("source") else line)
    conf.close()
    return conf.name


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
    im.save(FRAME, format="PNG")


async def feed(img):
    """Run cava on the current default monitor, pushing frames, until the default
    changes or cava dies. Returns so the caller can restart it."""
    mon = default_monitor()
    conf = cava_conf_for(mon)
    proc = subprocess.Popen(["cava", "-p", conf], stdout=subprocess.PIPE,
                            text=True, stderr=subprocess.DEVNULL)
    loop = asyncio.get_event_loop()
    frames = 0
    try:
        while not _stop:
            line = await loop.run_in_executor(None, proc.stdout.readline)
            if not line:
                return  # cava died -> restart
            frames += 1
            if frames % 20 == 0 and default_monitor() != mon:
                return  # output switched -> rebind
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
        with contextlib.suppress(Exception):
            os.unlink(conf)


async def connect(conn):
    # A fresh scan repopulates BlueZ's cache — after an unclean disconnect the
    # device drops out and connectByAddress raises BleakDeviceNotFoundError.
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
    try:
        while not _stop:
            await feed(img)
            if not _stop:
                await asyncio.sleep(0.5)  # cava restart / rebind backoff
    finally:
        with contextlib.suppress(Exception):
            await FullscreenColor().setMode(r=0, g=0, b=0)  # blank the panel
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
