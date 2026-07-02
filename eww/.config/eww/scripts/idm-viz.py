#!/usr/bin/env python3
"""Live audio visualizer on an iDotMatrix 32x32 BLE display.

Reads cava on the CURRENT default sink's monitor (same audio as the on-screen HUD,
incl. audio routed to Sonos via viz_tap) and renders one of several styles to the
matrix at ~20fps, auto-rotating every ROTATE_SEC. Send SIGUSR1 to skip to the next
style ($mod+Shift+n).

Styles: mirror EQ, radial spectrum, peak-hold bars, spectrum scope, beat particles,
plasma. All driven by the 16 cava bins.

Robustness: scan+retry connect; keep the BLE link; restart cava if it dies or the
default sink changes; blank the panel on exit.

Needs the idotmatrix venv. Address via $IDM_MAC. Matrix must not be on its phone app.
"""
import asyncio, subprocess, colorsys, os, sys, tempfile, signal, shutil, contextlib, math, time, random
from PIL import Image as PImage, ImageDraw
from idotmatrix import ConnectionManager, Image, FullscreenColor

MAC = os.environ.get("IDM_MAC", "51:A3:BC:97:69:68")
BARS, W, H = 16, 32, 32
ROTATE_SEC = 18
BASE_CONF = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "idm-cava.conf")
FRAME = os.path.join(tempfile.gettempdir(), "idm-frame.png")
COLS = [tuple(int(c * 255) for c in colorsys.hsv_to_rgb((i / BARS) * 0.82, 1, 1)) for i in range(BARS)]

_stop = False
_skip = 0  # SIGUSR1 bumps this to advance style


def hsv(h, s, v):
    return tuple(int(c * 255) for c in colorsys.hsv_to_rgb(h % 1.0, s, v))


# ---- styles: each draws into a fresh PIL image from the 16 bin values (0..H) ----
def s_mirror(im, vals, st):
    px = im.load()
    for i, v in enumerate(vals):
        half = max(0, min(H // 2, v // 2)); x = i * 2; c = COLS[i]
        for y in range(H // 2 - half, H // 2 + half):
            px[x, y] = c; px[x + 1, y] = c

def s_radial(im, vals, st):
    d = ImageDraw.Draw(im); cx = cy = 15.5
    for i, v in enumerate(vals):
        ang = 2 * math.pi * i / BARS; ln = max(0, min(15, v / 2.1))
        d.line([cx, cy, cx + math.cos(ang) * ln, cy + math.sin(ang) * ln], fill=COLS[i])

def s_peak(im, vals, st):
    px = im.load(); pk = st.setdefault("pk", [0.0] * BARS)
    for i, v in enumerate(vals):
        x = i * 2; c = COLS[i]
        for y in range(H - v, H):
            px[x, y] = c; px[x + 1, y] = c
        pk[i] = max(v, pk[i] - 0.6); py = max(0, H - 1 - int(pk[i]))
        px[x, py] = (255, 255, 255); px[x + 1, py] = (255, 255, 255)

def s_scope(im, vals, st):
    d = ImageDraw.Draw(im); prev = None
    for x in range(W):
        v = vals[min(BARS - 1, x // 2)]; y = max(0, H - 1 - min(H - 1, v))
        if prev:
            d.line([prev[0], prev[1], x, y], fill=hsv(x / W * 0.82, 1, 1))
        prev = (x, y)

def s_particles(im, vals, st):
    px = im.load(); parts = st.setdefault("p", []); avg = st.setdefault("avg", 5.0)
    bass = sum(vals[:3]) / 3.0; st["avg"] = avg * 0.9 + bass * 0.1
    if bass > st["avg"] * 1.5 and bass > 6:
        for _ in range(int(bass)):
            ang = random.uniform(0, 2 * math.pi); spd = random.uniform(0.6, 2.2)
            parts.append([15.5, 15.5, math.cos(ang) * spd, math.sin(ang) * spd,
                          1.0, hsv(random.random(), 1, 1)])
    alive = []
    for p in parts:
        p[0] += p[2]; p[1] += p[3]; p[4] -= 0.04
        if p[4] > 0 and 0 <= p[0] < W and 0 <= p[1] < H:
            c = tuple(int(ch * p[4]) for ch in p[5]); px[int(p[0]), int(p[1])] = c
            alive.append(p)
    st["p"] = alive[-120:]

def s_plasma(im, vals, st):
    px = im.load(); st["ph"] = st.get("ph", 0.0) + 0.05 + (sum(vals) / (BARS * H)) * 0.9
    ph = st["ph"]; energy = min(1.0, 0.25 + sum(vals) / (BARS * H))
    for y in range(H):
        for x in range(W):
            v = (math.sin(x / 4.0 + ph) + math.sin(y / 4.0 + ph * 1.3)
                 + math.sin((x + y) / 6.0 + ph * 0.7))
            px[x, y] = hsv((v + 3) / 6.0, 1, energy)

STYLES = [s_mirror, s_radial, s_peak, s_scope, s_particles, s_plasma]


def default_monitor():
    r = subprocess.run(["pactl", "get-default-sink"], capture_output=True, text=True)
    return r.stdout.strip() + ".monitor"

def cava_conf_for(mon):
    c = tempfile.NamedTemporaryFile("w", suffix=".conf", delete=False)
    with open(BASE_CONF) as f:
        for line in f:
            c.write("source = %s\n" % mon if line.startswith("source") else line)
    c.close(); return c.name


async def feed(img):
    mon = default_monitor(); conf = cava_conf_for(mon)
    proc = subprocess.Popen(["cava", "-p", conf], stdout=subprocess.PIPE, text=True,
                            stderr=subprocess.DEVNULL)
    loop = asyncio.get_event_loop()
    st = {}; cur = -1; n = 0
    try:
        while not _stop:
            line = await loop.run_in_executor(None, proc.stdout.readline)
            if not line:
                return
            n += 1
            if n % 20 == 0 and default_monitor() != mon:
                return
            clean = "".join(ch for ch in line if ch.isdigit() or ch == ";").rstrip(";")
            if not clean:
                continue
            try:
                vals = [int(x) for x in clean.split(";")]
            except ValueError:
                continue
            idx = (int(time.time() // ROTATE_SEC) + _skip) % len(STYLES)
            if idx != cur:
                cur = idx; st = {}  # reset per-style state on switch
            im = PImage.new("RGB", (W, H))
            STYLES[idx](im, vals, st)
            im.save(FRAME, format="PNG")
            await img.uploadProcessed(FRAME, pixel_size=32)
    finally:
        proc.terminate()
        with contextlib.suppress(Exception):
            os.unlink(conf)


async def connect(conn):
    for _ in range(15):
        if _stop:
            return False
        try:
            await conn.scan(); await conn.connectByAddress(MAC); return True
        except Exception as e:
            print(f"idm-viz: connect retry ({e})", file=sys.stderr); await asyncio.sleep(2)
    return False


async def main():
    conn = ConnectionManager()
    if not await connect(conn):
        return
    img = Image(); await img.setMode(mode=1)
    try:
        while not _stop:
            await feed(img)
            if not _stop:
                await asyncio.sleep(0.5)
    finally:
        with contextlib.suppress(Exception):
            await FullscreenColor().setMode(r=0, g=0, b=0)
        with contextlib.suppress(Exception):
            await conn.disconnect()


def _sig(*_):
    global _stop; _stop = True

def _next(*_):
    global _skip; _skip += 1


if __name__ == "__main__":
    if not shutil.which("cava"):
        sys.exit("cava not installed")
    signal.signal(signal.SIGTERM, _sig)
    signal.signal(signal.SIGINT, _sig)
    signal.signal(signal.SIGUSR1, _next)
    with contextlib.suppress(KeyboardInterrupt):
        asyncio.run(main())
