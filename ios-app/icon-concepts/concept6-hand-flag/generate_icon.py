#!/usr/bin/env python3
"""
Generate "Hand Holding Flag" iOS App Icon
Bold, heroic, victorious style - claiming territory!
"""

from PIL import Image, ImageDraw
import math

def create_hand_flag_icon(size=1024):
    """Create the main icon at specified size"""
    # Create transparent canvas
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Scale factor for different sizes
    s = size / 1024
    
    # Color palette - vibrant flag with dark hand
    flag_color = (255, 69, 58)  # Bold red/orange
    flag_highlight = (255, 149, 0)  # Orange accent
    pole_color = (139, 87, 42)  # Brown pole
    hand_color = (45, 45, 45)  # Dark silhouette
    hand_shadow = (25, 25, 25)  # Deeper shadow
    
    # === FLAG POLE (slightly off-center for dynamic feel) ===
    pole_x = int(480 * s)
    pole_width = int(28 * s)
    pole_top = int(120 * s)
    pole_bottom = int(880 * s)
    
    # Draw pole with slight taper
    pole_coords = [
        (pole_x - pole_width//2, pole_top),
        (pole_x + pole_width//2, pole_top),
        (pole_x + pole_width//2 - 4*s, pole_bottom),
        (pole_x - pole_width//2 + 4*s, pole_bottom)
    ]
    draw.polygon(pole_coords, fill=pole_color)
    
    # Pole highlight for depth
    highlight_coords = [
        (pole_x - pole_width//2 + 3*s, pole_top),
        (pole_x - pole_width//2 + 8*s, pole_top),
        (pole_x - pole_width//2 + 6*s, pole_bottom),
        (pole_x - pole_width//2 + 3*s, pole_bottom)
    ]
    draw.polygon(highlight_coords, fill=(160, 100, 50, 180))
    
    # === WAVING FLAG (bold and prominent) ===
    # Flag uses bezier-like curve with wave
    flag_start_y = int(160 * s)
    flag_height = int(280 * s)
    flag_length = int(480 * s)
    
    # Create wavy flag shape
    flag_points = []
    wave_segments = 40
    
    # Top edge (waving)
    for i in range(wave_segments + 1):
        t = i / wave_segments
        x = pole_x + flag_length * t
        # Wave formula: creates flowing flag effect
        wave = math.sin(t * math.pi * 2.5) * 30 * s * (0.3 + 0.7 * t)
        y = flag_start_y + wave
        flag_points.append((x, y))
    
    # Bottom edge (waving, offset)
    for i in range(wave_segments, -1, -1):
        t = i / wave_segments
        x = pole_x + flag_length * t
        wave = math.sin(t * math.pi * 2.5) * 30 * s * (0.3 + 0.7 * t)
        y = flag_start_y + flag_height + wave * 0.8
        flag_points.append((x, y))
    
    # Draw flag with gradient effect
    draw.polygon(flag_points, fill=flag_color)
    
    # Add flag highlight/depth (lighter stripe at top)
    highlight_points = []
    for i in range(wave_segments + 1):
        t = i / wave_segments
        x = pole_x + flag_length * t
        wave = math.sin(t * math.pi * 2.5) * 30 * s * (0.3 + 0.7 * t)
        y = flag_start_y + wave
        highlight_points.append((x, y))
    
    for i in range(wave_segments, -1, -1):
        t = i / wave_segments
        x = pole_x + flag_length * t
        wave = math.sin(t * math.pi * 2.5) * 30 * s * (0.3 + 0.7 * t)
        y = flag_start_y + 90*s + wave * 0.9
        highlight_points.append((x, y))
    
    draw.polygon(highlight_points, fill=flag_highlight)
    
    # === FIST/HAND GRIPPING POLE (bold silhouette) ===
    # Hand positioned at lower 1/3 of pole
    hand_center_y = int(680 * s)
    hand_width = int(220 * s)
    hand_height = int(200 * s)
    
    # Thumb side (left)
    thumb_points = [
        (pole_x - pole_width//2 - 60*s, hand_center_y - 40*s),
        (pole_x - pole_width//2 - 85*s, hand_center_y - 60*s),
        (pole_x - pole_width//2 - 95*s, hand_center_y - 30*s),
        (pole_x - pole_width//2 - 75*s, hand_center_y + 20*s),
        (pole_x - pole_width//2 - 20*s, hand_center_y + 30*s),
    ]
    
    # Main fist body (wraps around pole)
    fist_left = [
        (pole_x - pole_width//2 - 20*s, hand_center_y - 80*s),
        (pole_x - pole_width//2 - 60*s, hand_center_y - 40*s),
    ] + thumb_points + [
        (pole_x - pole_width//2 - 20*s, hand_center_y + 30*s),
        (pole_x - pole_width//2, hand_center_y + 90*s),
    ]
    
    fist_right = [
        (pole_x + pole_width//2, hand_center_y + 90*s),
        (pole_x + pole_width//2 + 20*s, hand_center_y + 30*s),
        (pole_x + pole_width//2 + 85*s, hand_center_y),
        (pole_x + pole_width//2 + 90*s, hand_center_y - 40*s),
        (pole_x + pole_width//2 + 75*s, hand_center_y - 75*s),
        (pole_x + pole_width//2 + 20*s, hand_center_y - 85*s),
        (pole_x + pole_width//2, hand_center_y - 80*s),
    ]
    
    # Draw shadow first (offset)
    shadow_offset = int(8 * s)
    shadow_left = [(x + shadow_offset, y + shadow_offset) for x, y in fist_left]
    shadow_right = [(x + shadow_offset, y + shadow_offset) for x, y in fist_right]
    draw.polygon(shadow_left + shadow_right, fill=hand_shadow)
    
    # Draw main fist
    draw.polygon(fist_left + fist_right, fill=hand_color)
    
    # Knuckle highlights for definition
    knuckle_y = hand_center_y - 70*s
    for i in range(3):
        offset = (i - 1) * 28*s
        draw.ellipse([
            pole_x + pole_width//2 + offset - 10*s,
            knuckle_y - 8*s,
            pole_x + pole_width//2 + offset + 10*s,
            knuckle_y + 8*s
        ], fill=(65, 65, 65))
    
    # Wrist/arm extending down
    wrist_points = [
        (pole_x - pole_width//2, hand_center_y + 90*s),
        (pole_x + pole_width//2, hand_center_y + 90*s),
        (pole_x + pole_width//2 + 40*s, hand_center_y + 180*s),
        (pole_x + pole_width//2 + 10*s, size - 50*s),
        (pole_x - pole_width//2 - 10*s, size - 50*s),
        (pole_x - pole_width//2 - 40*s, hand_center_y + 180*s),
    ]
    draw.polygon(wrist_points, fill=hand_color)
    
    return img


def create_test_backgrounds(icon, output_dir):
    """Create test renders on light and dark backgrounds"""
    sizes = [(1024, "1024x1024"), (120, "120x120"), (40, "40x40")]
    
    for size, label in sizes:
        if size != 1024:
            test_icon = icon.resize((size, size), Image.Resampling.LANCZOS)
        else:
            test_icon = icon
        
        # Light background test
        light_bg = Image.new('RGB', (size, size), (245, 245, 245))
        light_bg.paste(test_icon, (0, 0), test_icon)
        light_bg.save(f"{output_dir}/test-light-{label}.png")
        
        # Dark background test
        dark_bg = Image.new('RGB', (size, size), (28, 28, 30))
        dark_bg.paste(test_icon, (0, 0), test_icon)
        dark_bg.save(f"{output_dir}/test-dark-{label}.png")


def main():
    output_dir = "."
    
    print("🎨 Generating Hand Holding Flag icon...")
    
    # Generate main icon at 1024x1024
    print("  → Creating 1024x1024 master...")
    icon_1024 = create_hand_flag_icon(1024)
    icon_1024.save(f"{output_dir}/icon-1024.png")
    
    # Generate preview at 120x120
    print("  → Creating 120x120 preview...")
    icon_120 = icon_1024.resize((120, 120), Image.Resampling.LANCZOS)
    icon_120.save(f"{output_dir}/icon-120.png")
    
    # Generate small test at 40x40
    print("  → Creating 40x40 small test...")
    icon_40 = icon_1024.resize((40, 40), Image.Resampling.LANCZOS)
    icon_40.save(f"{output_dir}/icon-40.png")
    
    # Create background tests
    print("  → Generating light/dark background tests...")
    create_test_backgrounds(icon_1024, output_dir)
    
    print("✅ Icon generation complete!")
    print(f"\n📁 Files saved to: {output_dir}/")
    print("   - icon-1024.png (master)")
    print("   - icon-120.png (preview)")
    print("   - icon-40.png (small)")
    print("   - test-light-*.png")
    print("   - test-dark-*.png")


if __name__ == "__main__":
    main()
