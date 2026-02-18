#!/usr/bin/env python3
"""Generate beautiful gradient background images for JBTV dashboard."""

from PIL import Image, ImageDraw, ImageFilter, ImageChops, ImageEnhance
import math
import os

WIDTH, HEIGHT = 1920, 1080
OUTPUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'roku', 'images')


def hex_to_rgb(h):
    h = h.lstrip('#')
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))


def lerp_color(c1, c2, t):
    t = max(0.0, min(1.0, t))
    return tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(3))


def multi_stop_lerp(stops, t):
    t = max(0.0, min(1.0, t))
    if t <= stops[0][0]:
        return stops[0][1]
    if t >= stops[-1][0]:
        return stops[-1][1]
    for i in range(len(stops) - 1):
        if stops[i][0] <= t <= stops[i+1][0]:
            local_t = (t - stops[i][0]) / (stops[i+1][0] - stops[i][0])
            local_t = local_t * local_t * (3 - 2 * local_t)
            return lerp_color(stops[i][1], stops[i+1][1], local_t)
    return stops[-1][1]


def distance(x1, y1, x2, y2):
    return math.sqrt((x2 - x1)**2 + (y2 - y1)**2)


def create_layer(width, height, pixel_func):
    img = Image.new('RGB', (width, height))
    pixels = img.load()
    for y in range(height):
        for x in range(width):
            pixels[x, y] = pixel_func(x, y)
    return img


def blend_additive(base, overlay, strength=0.5):
    overlay_adj = ImageEnhance.Brightness(overlay).enhance(strength)
    inv_base = ImageChops.invert(base)
    inv_overlay = ImageChops.invert(overlay_adj)
    result = ImageChops.invert(ImageChops.multiply(inv_base, inv_overlay))
    return result


def generate_morning():
    print("  Generating bg_morning.png...")
    indigo = hex_to_rgb('#1a0533')
    warm_purple = hex_to_rgb('#4a1942')
    coral = hex_to_rgb('#e8606a')
    golden = hex_to_rgb('#f4a261')
    hot_pink = hex_to_rgb('#c2185b')

    stops = [
        (0.0, indigo),
        (0.25, warm_purple),
        (0.5, hot_pink),
        (0.7, coral),
        (1.0, golden),
    ]

    def diagonal_pixel(x, y):
        t = (x / WIDTH + (1.0 - y / HEIGHT)) / 2.0
        return multi_stop_lerp(stops, t)

    base = create_layer(WIDTH, HEIGHT, diagonal_pixel)

    glow_cx, glow_cy = int(WIDTH * 0.72), int(HEIGHT * 0.28)
    glow_radius = WIDTH * 0.45

    def glow_pixel(x, y):
        d = distance(x, y, glow_cx, glow_cy) / glow_radius
        if d > 1.0:
            return (0, 0, 0)
        intensity = (1.0 - d) ** 2.0
        glow_color = lerp_color(coral, golden, intensity * 0.6)
        return tuple(int(c * intensity * 0.7) for c in glow_color)

    glow = create_layer(WIDTH, HEIGHT, glow_pixel)
    result = blend_additive(base, glow, strength=0.6)

    glow2_cx, glow2_cy = int(WIDTH * 0.4), int(HEIGHT * 0.65)
    glow2_radius = WIDTH * 0.5

    def glow2_pixel(x, y):
        d = distance(x, y, glow2_cx, glow2_cy) / glow2_radius
        if d > 1.0:
            return (0, 0, 0)
        intensity = (1.0 - d) ** 2.5
        return tuple(int(c * intensity * 0.4) for c in warm_purple)

    glow2 = create_layer(WIDTH, HEIGHT, glow2_pixel)
    result = blend_additive(result, glow2, strength=0.3)
    result = result.filter(ImageFilter.GaussianBlur(radius=2))
    return result


def generate_afternoon():
    print("  Generating bg_afternoon.png...")
    deep_blue = hex_to_rgb('#0c2340')
    ocean_blue = hex_to_rgb('#1565c0')
    cyan = hex_to_rgb('#00bcd4')
    light_teal = hex_to_rgb('#4dd0e1')
    sky_white = hex_to_rgb('#b3e5fc')

    stops = [
        (0.0, light_teal),
        (0.3, cyan),
        (0.6, ocean_blue),
        (1.0, deep_blue),
    ]

    def vert_pixel(x, y):
        t = y / HEIGHT + (x / WIDTH - 0.5) * 0.1
        return multi_stop_lerp(stops, t)

    base = create_layer(WIDTH, HEIGHT, vert_pixel)

    sun_cx, sun_cy = int(WIDTH * 0.55), int(HEIGHT * 0.15)
    sun_radius = WIDTH * 0.5

    def sun_pixel(x, y):
        d = distance(x, y, sun_cx, sun_cy) / sun_radius
        if d > 1.0:
            return (0, 0, 0)
        intensity = (1.0 - d) ** 3.0
        glow_color = lerp_color(light_teal, sky_white, intensity)
        return tuple(int(c * intensity * 0.6) for c in glow_color)

    sun = create_layer(WIDTH, HEIGHT, sun_pixel)
    result = blend_additive(base, sun, strength=0.5)

    for corner_x_frac in [0.1, 0.9]:
        cx = int(WIDTH * corner_x_frac)
        cy = HEIGHT
        r = WIDTH * 0.4

        def corner_pixel(x, y, cx=cx, cy=cy, r=r):
            d = distance(x, y, cx, cy) / r
            if d > 1.0:
                return (0, 0, 0)
            intensity = (1.0 - d) ** 2.5
            return tuple(int(c * intensity * 0.3) for c in deep_blue)

        corner = create_layer(WIDTH, HEIGHT, corner_pixel)
        result = blend_additive(result, corner, strength=0.2)

    result = result.filter(ImageFilter.GaussianBlur(radius=2))
    return result


def generate_evening():
    print("  Generating bg_evening.png...")
    deep_purple = hex_to_rgb('#1a0a2e')
    magenta = hex_to_rgb('#880e4f')
    burnt_orange = hex_to_rgb('#e65100')
    warm_amber = hex_to_rgb('#ff8f00')
    rose = hex_to_rgb('#ad1457')
    dark_plum = hex_to_rgb('#2c0a3a')

    stops = [
        (0.0, deep_purple),
        (0.2, dark_plum),
        (0.4, magenta),
        (0.6, rose),
        (0.8, burnt_orange),
        (1.0, warm_amber),
    ]

    def diagonal_pixel(x, y):
        t = (x / WIDTH * 0.6 + (1.0 - y / HEIGHT) * 0.4)
        t = t ** 0.9
        return multi_stop_lerp(stops, t)

    base = create_layer(WIDTH, HEIGHT, diagonal_pixel)

    sun_cx, sun_cy = int(WIDTH * 0.85), int(HEIGHT * 0.15)
    sun_radius = WIDTH * 0.55

    def sun_pixel(x, y):
        d = distance(x, y, sun_cx, sun_cy) / sun_radius
        if d > 1.0:
            return (0, 0, 0)
        intensity = (1.0 - d) ** 2.2
        glow_color = lerp_color(burnt_orange, warm_amber, intensity * 0.8)
        return tuple(int(c * intensity * 0.65) for c in glow_color)

    sun = create_layer(WIDTH, HEIGHT, sun_pixel)
    result = blend_additive(base, sun, strength=0.55)

    glow_cx, glow_cy = int(WIDTH * 0.3), HEIGHT
    glow_radius = WIDTH * 0.5

    def deep_pixel(x, y):
        d = distance(x, y, glow_cx, glow_cy) / glow_radius
        if d > 1.0:
            return (0, 0, 0)
        intensity = (1.0 - d) ** 2.0
        return tuple(int(c * intensity * 0.5) for c in deep_purple)

    deep = create_layer(WIDTH, HEIGHT, deep_pixel)
    result = blend_additive(result, deep, strength=0.25)

    accent_cx, accent_cy = int(WIDTH * 0.35), int(HEIGHT * 0.5)
    accent_radius = WIDTH * 0.35

    def accent_pixel(x, y):
        d = distance(x, y, accent_cx, accent_cy) / accent_radius
        if d > 1.0:
            return (0, 0, 0)
        intensity = (1.0 - d) ** 2.5
        return tuple(int(c * intensity * 0.3) for c in magenta)

    accent = create_layer(WIDTH, HEIGHT, accent_pixel)
    result = blend_additive(result, accent, strength=0.2)
    result = result.filter(ImageFilter.GaussianBlur(radius=2))
    return result


def generate_night():
    print("  Generating bg_night.png...")
    near_black = hex_to_rgb('#0a0a1a')
    deep_navy = hex_to_rgb('#0d1b2a')
    deep_purple = hex_to_rgb('#1b1040')
    dark_blue = hex_to_rgb('#162447')
    midnight_blue = hex_to_rgb('#0f1a30')
    subtle_indigo = hex_to_rgb('#1a1245')
    teal_hint = hex_to_rgb('#0a2535')
    warm_accent = hex_to_rgb('#1a1030')

    stops = [
        (0.0, dark_blue),
        (0.25, deep_purple),
        (0.5, midnight_blue),
        (0.75, deep_navy),
        (1.0, near_black),
    ]

    def base_pixel(x, y):
        vert_t = y / HEIGHT
        horiz_offset = (x / WIDTH - 0.5) * 0.08
        t = vert_t + horiz_offset
        return multi_stop_lerp(stops, t)

    base = create_layer(WIDTH, HEIGHT, base_pixel)

    glow1_cx, glow1_cy = int(WIDTH * 0.5), int(HEIGHT * 0.2)
    glow1_radius = WIDTH * 0.55

    def glow1_pixel(x, y):
        d = distance(x, y, glow1_cx, glow1_cy) / glow1_radius
        if d > 1.0:
            return (0, 0, 0)
        intensity = (1.0 - d) ** 3.0
        return tuple(int(c * intensity * 0.5) for c in subtle_indigo)

    glow1 = create_layer(WIDTH, HEIGHT, glow1_pixel)
    result = blend_additive(base, glow1, strength=0.4)

    glow2_cx, glow2_cy = int(WIDTH * 0.8), int(HEIGHT * 0.75)
    glow2_radius = WIDTH * 0.4

    def glow2_pixel(x, y):
        d = distance(x, y, glow2_cx, glow2_cy) / glow2_radius
        if d > 1.0:
            return (0, 0, 0)
        intensity = (1.0 - d) ** 2.8
        return tuple(int(c * intensity * 0.35) for c in teal_hint)

    glow2 = create_layer(WIDTH, HEIGHT, glow2_pixel)
    result = blend_additive(result, glow2, strength=0.35)

    glow3_cx, glow3_cy = int(WIDTH * 0.15), int(HEIGHT * 0.85)
    glow3_radius = WIDTH * 0.35

    def glow3_pixel(x, y):
        d = distance(x, y, glow3_cx, glow3_cy) / glow3_radius
        if d > 1.0:
            return (0, 0, 0)
        intensity = (1.0 - d) ** 2.5
        return tuple(int(c * intensity * 0.3) for c in deep_navy)

    glow3 = create_layer(WIDTH, HEIGHT, glow3_pixel)
    result = blend_additive(result, glow3, strength=0.3)

    accent_cx, accent_cy = int(WIDTH * 0.1), 0
    accent_radius = WIDTH * 0.3

    def accent_pixel(x, y):
        d = distance(x, y, accent_cx, accent_cy) / accent_radius
        if d > 1.0:
            return (0, 0, 0)
        intensity = (1.0 - d) ** 2.5
        return tuple(int(c * intensity * 0.4) for c in warm_accent)

    accent = create_layer(WIDTH, HEIGHT, accent_pixel)
    result = blend_additive(result, accent, strength=0.25)
    result = result.filter(ImageFilter.GaussianBlur(radius=3))
    return result


def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    print("Generating JBTV background images (1920x1080)...\n")

    images = {
        'bg_morning.png': generate_morning,
        'bg_afternoon.png': generate_afternoon,
        'bg_evening.png': generate_evening,
        'bg_night.png': generate_night,
    }

    for filename, gen_func in images.items():
        img = gen_func()
        path = os.path.join(OUTPUT_DIR, filename)
        img.save(path, 'PNG', optimize=True)
        size_kb = os.path.getsize(path) / 1024
        print(f"  Saved: {path} ({size_kb:.0f} KB)\n")

    print("All backgrounds generated successfully!")


if __name__ == '__main__':
    main()
