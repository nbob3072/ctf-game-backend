#!/usr/bin/env python3
"""
Generate Crossed Flags iOS App Icon
Bold, prominent design that fills the icon space
"""

from PIL import Image, ImageDraw
import math

def create_crossed_flags_icon(size=1024):
    """Create a bold crossed flags icon"""
    
    # Create image with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Calculate dimensions - use ~90% of canvas (5% margin on each side)
    margin = int(size * 0.05)
    usable_size = size - (2 * margin)
    
    # Center point
    center_x = size // 2
    center_y = size // 2
    
    # Flag dimensions
    pole_length = int(usable_size * 0.85)  # Long poles
    pole_width = int(size * 0.04)  # Thick poles (4% of size)
    flag_width = int(usable_size * 0.45)  # Wide flags
    flag_height = int(usable_size * 0.35)  # Tall flags
    
    # Colors - bold blue and vibrant orange
    blue = (41, 128, 255)  # Bright blue
    orange = (255, 149, 0)  # Apple orange
    pole_color = (240, 240, 245)  # Light gray poles (works on both backgrounds)
    
    # Rotation angle (45 degrees for X pattern)
    angle1 = -45  # Top-left to bottom-right
    angle2 = 45   # Top-right to bottom-left
    
    def rotate_point(x, y, cx, cy, angle):
        """Rotate point around center"""
        angle_rad = math.radians(angle)
        cos_a = math.cos(angle_rad)
        sin_a = math.sin(angle_rad)
        
        # Translate to origin
        x -= cx
        y -= cy
        
        # Rotate
        new_x = x * cos_a - y * sin_a
        new_y = x * sin_a + y * cos_a
        
        # Translate back
        return new_x + cx, new_y + cy
    
    def draw_flag_with_pole(draw, cx, cy, angle, flag_color, pole_col):
        """Draw a flag with pole at given angle"""
        
        # Pole coordinates (from center outward)
        pole_start_x = cx
        pole_start_y = cy - pole_length // 2
        pole_end_x = cx
        pole_end_y = cy + pole_length // 2
        
        # Rotate pole points
        p1 = rotate_point(pole_start_x, pole_start_y, cx, cy, angle)
        p2 = rotate_point(pole_end_x, pole_end_y, cx, cy, angle)
        
        # Draw pole (thick line)
        # Create pole as a rectangle for thickness
        pole_half_width = pole_width // 2
        pole_corners = [
            rotate_point(cx - pole_half_width, cy - pole_length // 2, cx, cy, angle),
            rotate_point(cx + pole_half_width, cy - pole_length // 2, cx, cy, angle),
            rotate_point(cx + pole_half_width, cy + pole_length // 2, cx, cy, angle),
            rotate_point(cx - pole_half_width, cy + pole_length // 2, cx, cy, angle)
        ]
        draw.polygon(pole_corners, fill=pole_col)
        
        # Flag position (at top of pole)
        # Triangular pennant flag
        flag_top_x = cx
        flag_top_y = cy - pole_length // 2
        
        # Three points of triangular flag
        flag_points = [
            (flag_top_x, flag_top_y),  # Attached to pole
            (flag_top_x, flag_top_y + flag_height),  # Bottom of attachment
            (flag_top_x + flag_width, flag_top_y + flag_height // 2)  # Point of flag
        ]
        
        # Rotate flag points
        flag_points_rotated = [
            rotate_point(x, y, cx, cy, angle) for x, y in flag_points
        ]
        
        # Draw flag
        draw.polygon(flag_points_rotated, fill=flag_color)
        
        # Add subtle border to flag for definition
        border_color = tuple(max(0, c - 40) for c in flag_color)
        draw.line(flag_points_rotated + [flag_points_rotated[0]], 
                 fill=border_color, width=int(size * 0.008))
    
    # Draw both flags
    # Back flag first (blue)
    draw_flag_with_pole(draw, center_x, center_y, angle2, blue, pole_color)
    
    # Front flag (orange)
    draw_flag_with_pole(draw, center_x, center_y, angle1, orange, pole_color)
    
    # Add center overlap circle for polish (where poles cross)
    overlap_radius = int(pole_width * 1.2)
    draw.ellipse(
        [center_x - overlap_radius, center_y - overlap_radius,
         center_x + overlap_radius, center_y + overlap_radius],
        fill=pole_color
    )
    
    return img

def add_background(img, bg_color):
    """Add background color to icon"""
    bg = Image.new('RGBA', img.size, bg_color)
    bg.paste(img, (0, 0), img)
    return bg.convert('RGB')

# Generate main icon (transparent background)
print("Generating 1024px icon...")
icon_1024 = create_crossed_flags_icon(1024)
icon_1024.save('icon-1024.png')

# Generate preview
print("Generating 120px preview...")
icon_120 = icon_1024.resize((120, 120), Image.Resampling.LANCZOS)
icon_120.save('icon-120.png')

# Generate test versions on different backgrounds
print("Generating test backgrounds...")
icon_light = add_background(icon_1024, (255, 255, 255))
icon_light.save('icon-1024-light-bg.png')

icon_dark = add_background(icon_1024, (28, 28, 30))
icon_dark.save('icon-1024-dark-bg.png')

# Small size test (40px - smallest iOS size)
icon_40 = icon_1024.resize((40, 40), Image.Resampling.LANCZOS)
icon_40_light = add_background(icon_40, (255, 255, 255))
icon_40_light.save('icon-40-light-bg.png')

icon_40_dark = add_background(icon_40, (28, 28, 30))
icon_40_dark.save('icon-40-dark-bg.png')

print("✓ All icons generated successfully!")
print("\nFiles created:")
print("  - icon-1024.png (transparent, production ready)")
print("  - icon-120.png (preview size)")
print("  - icon-1024-light-bg.png (test on light)")
print("  - icon-1024-dark-bg.png (test on dark)")
print("  - icon-40-light-bg.png (smallest iOS size test)")
print("  - icon-40-dark-bg.png (smallest iOS size test)")
