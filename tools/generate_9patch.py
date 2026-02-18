#!/usr/bin/env python3
"""Generate 9-patch PNG images for Roku SceneGraph glass card components."""

from PIL import Image, ImageDraw
import os

OUTPUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "roku", "images")

# Inner image dimensions (without 9-patch border)
RADIUS = 15
SIZE = RADIUS * 2 + 18  # 48px
PADDING = 8


def draw_9patch_guides(img, inner_w, inner_h, radius, padding):
    """Draw the 1px 9-patch guide marks on the border of a (w+2, h+2) image."""
    total_w, total_h = img.size
    black = (0, 0, 0, 255)

    # Top border: horizontal stretch region (between rounded corners)
    stretch_left = radius + 1
    stretch_right = inner_w - radius
    for x in range(stretch_left, stretch_right + 1):
        img.putpixel((x, 0), black)

    # Left border: vertical stretch region
    stretch_top = radius + 1
    stretch_bottom = inner_h - radius
    for y in range(stretch_top, stretch_bottom + 1):
        img.putpixel((0, y), black)

    # Bottom border: horizontal content/padding area
    content_left = radius + padding + 1
    content_right = inner_w - radius - padding
    for x in range(content_left, content_right + 1):
        img.putpixel((x, total_h - 1), black)

    # Right border: vertical content/padding area
    content_top = radius + padding + 1
    content_bottom = inner_h - radius - padding
    for y in range(content_top, content_bottom + 1):
        img.putpixel((total_w - 1, y), black)


def generate_fill():
    """Generate glass_card_fill.9.png - solid white rounded rectangle."""
    inner_w, inner_h = SIZE, SIZE
    img = Image.new("RGBA", (inner_w + 2, inner_h + 2), (0, 0, 0, 0))

    inner = Image.new("RGBA", (inner_w, inner_h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(inner)
    draw.rounded_rectangle(
        [(0, 0), (inner_w - 1, inner_h - 1)],
        radius=RADIUS,
        fill=(255, 255, 255, 255),
    )
    img.paste(inner, (1, 1))

    draw_9patch_guides(img, inner_w, inner_h, RADIUS, PADDING)

    path = os.path.join(OUTPUT_DIR, "glass_card_fill.9.png")
    img.save(path)
    print(f"Saved: {path} ({img.size[0]}x{img.size[1]})")


def generate_border():
    """Generate glass_card_border.9.png - white stroke rounded rectangle."""
    inner_w, inner_h = SIZE, SIZE
    img = Image.new("RGBA", (inner_w + 2, inner_h + 2), (0, 0, 0, 0))

    inner = Image.new("RGBA", (inner_w, inner_h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(inner)
    draw.rounded_rectangle(
        [(0, 0), (inner_w - 1, inner_h - 1)],
        radius=RADIUS,
        fill=None,
        outline=(255, 255, 255, 255),
        width=1,
    )
    img.paste(inner, (1, 1))

    draw_9patch_guides(img, inner_w, inner_h, RADIUS, PADDING)

    path = os.path.join(OUTPUT_DIR, "glass_card_border.9.png")
    img.save(path)
    print(f"Saved: {path} ({img.size[0]}x{img.size[1]})")


if __name__ == "__main__":
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    generate_fill()
    generate_border()
    print("Done.")
