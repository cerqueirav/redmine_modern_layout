#!/usr/bin/env python3
"""Generates the sample partner banner and login background of Redmine Modern Layout.

"Acme Health" and the partner names are fictional. The sample logo and icon are
the official Redmine logo (see README.md in this folder), not generated here. Requires Pillow and the
Ubuntu Sans font (https://design.ubuntu.com/font, Ubuntu Font Licence).
Usage: python3 generate_samples.py [path/to/UbuntuSans[wdth,wght].ttf]
"""
import math
import os
import random
import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
FONT = sys.argv[1] if len(sys.argv) > 1 else '/usr/share/fonts/truetype/ubuntu/UbuntuSans[wdth,wght].ttf'
SS = 4  # supersampling for smooth edges

GREEN, TEAL, BLUE, SLATE, MUTED = '#2f9e44', '#0f9d8f', '#0093c5', '#1e293b', '#64748b'


def font(size, weight='Bold'):
    f = ImageFont.truetype(FONT, size)
    f.set_variation_by_name(weight)
    return f


def rgb(h):
    return tuple(int(h[i:i + 2], 16) for i in (1, 3, 5))


def gradient(size, c1, c2, diagonal=True):
    w, h = size
    a, b = rgb(c1), rgb(c2)
    g = Image.new('RGBA', size)
    px = g.load()
    for y in range(h):
        for x in range(w):
            t = ((x / max(1, w - 1)) + (y / max(1, h - 1))) / 2 if diagonal else x / max(1, w - 1)
            px[x, y] = tuple(round(a[i] + (b[i] - a[i]) * t) for i in range(3)) + (255,)
    return g


def icon(size):
    """Rounded square with a pulse line: the Acme Health mark."""
    s = size * SS
    mask = Image.new('L', (s, s))
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, s - 1, s - 1), radius=int(s * 0.26), fill=255)
    tile = Image.new('RGBA', (s, s))
    tile.paste(gradient((s // 8, s // 8), GREEN, BLUE).resize((s, s), Image.BICUBIC), (0, 0), mask)
    d = ImageDraw.Draw(tile)
    pts = [(0.16, 0.54), (0.36, 0.54), (0.45, 0.30), (0.56, 0.74), (0.65, 0.46), (0.70, 0.54), (0.84, 0.54)]
    d.line([(x * s, y * s) for x, y in pts], fill='white', width=int(s * 0.075), joint='curve')
    r = s * 0.0375
    for x, y in (pts[0], pts[-1]):
        d.ellipse((x * s - r, y * s - r, x * s + r, y * s + r), fill='white')
    return tile.resize((size, size), Image.LANCZOS)


def text_img(text, f, color):
    box = f.getbbox(text)
    im = Image.new('RGBA', (box[2] - box[0], box[3] - box[1]))
    ImageDraw.Draw(im).text((-box[0], -box[1]), text, font=f, fill=color)
    return im


def logo(height=300):
    ic = icon(height)
    name = text_img('Acme', font(int(height * 0.50), 'Bold'), SLATE)
    sub = text_img('Health', font(int(height * 0.50), 'Light'), TEAL)
    gap = int(height * 0.12)
    w = height + gap + name.width + int(height * 0.08) + sub.width
    out = Image.new('RGBA', (w, height))
    out.alpha_composite(ic, (0, 0))
    y = (height - name.height) // 2
    out.alpha_composite(name, (height + gap, y))
    out.alpha_composite(sub, (height + gap + name.width + int(height * 0.08), y + name.height - sub.height))
    return out


def partner(shape, color, label, h=120):
    s = int(h * 0.62)
    mark = Image.new('RGBA', (s * SS, s * SS))
    d = ImageDraw.Draw(mark)
    S = s * SS
    if shape == 'circle':
        d.ellipse((0, 0, S - 1, S - 1), fill=color)
        d.ellipse((S * .3, S * .3, S * .7, S * .7), fill='white')
    elif shape == 'peak':
        d.polygon([(0, S), (S * .38, S * .18), (S * .58, S * .52), (S * .72, S * .34), (S, S)], fill=color)
    elif shape == 'wave':
        d.rounded_rectangle((0, 0, S - 1, S - 1), radius=S * .22, fill=color)
        for k in range(3):
            y = S * (.32 + k * .18)
            d.line([(S * .15 + i * S * .07, y + math.sin(i) * S * .05) for i in range(11)], fill='white', width=int(S * .06))
    else:  # hexagon
        d.polygon([(S * .5 + S * .5 * math.cos(math.pi / 3 * i + math.pi / 6), S * .5 + S * .5 * math.sin(math.pi / 3 * i + math.pi / 6)) for i in range(6)], fill=color)
        d.ellipse((S * .36, S * .36, S * .64, S * .64), fill='white')
    mark = mark.resize((s, s), Image.LANCZOS)
    txt = text_img(label, font(int(h * 0.34), 'Medium'), SLATE)
    out = Image.new('RGBA', (s + int(h * .14) + txt.width, h))
    out.alpha_composite(mark, (0, (h - s) // 2))
    out.alpha_composite(txt, (s + int(h * .14), (h - txt.height) // 2))
    return out


def partners_strip(h=120):
    items = [logo(int(h * 0.62)),
             partner('peak', BLUE, 'Bluepeak', h),
             partner('wave', '#7c3aed', 'Riverstone', h),
             partner('hex', '#f59e0b', 'Nova Lab', h)]
    gap = int(h * 0.55)
    w = sum(i.width for i in items) + gap * (len(items) - 1) * 2
    out = Image.new('RGBA', (w, h))
    d = ImageDraw.Draw(out)
    x = 0
    for n, im in enumerate(items):
        out.alpha_composite(im, (x, (h - im.height) // 2))
        x += im.width + gap
        if n < len(items) - 1:
            d.line([(x, h * .22), (x, h * .78)], fill='#cbd5e1', width=2)
            x += gap
    return out


def background(w=1920, h=1280):
    """Abstract background: brand gradient, soft light blobs, dot grid and rings."""
    random.seed(7)
    bg = gradient((w // 16, h // 16), '#0b3d2e', '#063a5c').resize((w, h), Image.BICUBIC)
    glow = Image.new('RGBA', (w, h))
    d = ImageDraw.Draw(glow)
    for (cx, cy, r, c, a) in [(.18, .22, .42, GREEN, 150), (.85, .80, .48, BLUE, 140), (.70, .18, .26, TEAL, 110), (.30, .90, .30, '#84cc16', 70)]:
        d.ellipse(((cx - r) * w, (cy - r) * w + (cy * h - cy * w), (cx + r) * w, (cy + r) * w + (cy * h - cy * w)), fill=rgb(c) + (a,))
    bg.alpha_composite(glow.filter(ImageFilter.GaussianBlur(160)))
    over = Image.new('RGBA', (w, h))
    d = ImageDraw.Draw(over)
    for y in range(0, h, 32):
        for x in range(0, w, 32):
            fade = max(0, 1 - math.hypot(x / w - .75, y / h - .3) * 1.6)
            if fade > 0:
                d.ellipse((x - 1.6, y - 1.6, x + 1.6, y + 1.6), fill=(255, 255, 255, int(70 * fade)))
    for (cx, cy, r) in [(.78, .30, 260), (.78, .30, 380), (.20, .78, 200)]:
        d.ellipse((cx * w - r, cy * h - r, cx * w + r, cy * h + r), outline=(255, 255, 255, 38), width=2)
    bg.alpha_composite(over)
    return bg.convert('RGB')


if __name__ == '__main__':
    out = lambda name: os.path.join(HERE, name)
    partners_strip(120).save(out('sample-partners.png'), optimize=True)
    background().save(out('sample-login-background.jpg'), quality=86, optimize=True, progressive=True)
    for f in sorted(os.listdir(HERE)):
        if f.startswith('sample-'):
            im = Image.open(out(f))
            print(f, im.size, os.path.getsize(out(f)) // 1024, 'KB')
