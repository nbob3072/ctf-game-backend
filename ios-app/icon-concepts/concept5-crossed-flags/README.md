# Crossed Flags Icon - Concept 5

## Design Overview

Bold, prominent crossed flags design that fills the icon space effectively. This design addresses feedback about previous icons being too small.

### Visual Elements

- **Two triangular pennant flags** crossed in an X pattern (like crossed swords)
- **Blue flag** (RGB: 41, 128, 255) - top-right to bottom-left
- **Orange flag** (RGB: 255, 149, 0) - top-left to bottom-right
- **Light gray poles** (RGB: 240, 240, 245) - visible on both light and dark backgrounds
- **Bold sizing**: Uses ~90% of canvas with only 5% margin on each side

### Design Philosophy

**FILLS THE SPACE**: Unlike previous concepts, these flags are LARGE and PROMINENT
- Flags extend almost to the edges
- Thick, visible poles (4% of icon size)
- Large flag triangles (~45% width × 35% height of usable space)
- Center overlap detail where poles cross

**Works at all sizes**:
- ✓ 1024px - crisp and detailed
- ✓ 120px - clear and recognizable
- ✓ 40px - still readable (smallest iOS size)

**Background compatibility**:
- ✓ Light backgrounds - pole color chosen to contrast
- ✓ Dark backgrounds - vibrant colors pop
- ✓ Transparent - production ready

### Color Choices

- **Blue**: Bright, energetic team color
- **Orange**: Apple's signature orange, provides strong contrast with blue
- **Poles**: Light gray that works on both light and dark backgrounds

### Files

**Production Ready:**
- `icon-1024.png` - 1024×1024px transparent PNG (main deliverable)
- `icon-120.png` - 120×120px preview

**Test Files:**
- `icon-1024-light-bg.png` - On white background
- `icon-1024-dark-bg.png` - On dark background (iOS dark mode)
- `icon-40-light-bg.png` - Smallest iOS size on light
- `icon-40-dark-bg.png` - Smallest iOS size on dark

### Technical Specs

- Format: PNG with transparency
- Size: 1024×1024px
- Color space: sRGB
- Channels: RGBA
- Generated programmatically for pixel-perfect precision

### Comparison to Apple Icons

This design follows Apple's modern icon philosophy:
- **Music app**: Bold, simple symbol fills the space
- **Maps app**: Large, clear icon with minimal padding
- **Compass**: Simple geometric shape, maximum visibility

The crossed flags are immediately recognizable even at 40px, just like Apple's own icons.

## Regenerating

```bash
cd ~/Projects/ctf-game/ios-app/icon-concepts/concept5-crossed-flags
source venv/bin/activate
python generate_icon.py
```

## Design Decisions

1. **Crossed pattern**: More dynamic than parallel flags
2. **Triangular pennants**: More iconic than rectangular flags
3. **Blue + Orange**: Strong contrast, team-oriented colors
4. **Thick poles**: Ensures visibility at small sizes
5. **90% fill**: Addressed "too small" feedback directly
6. **Center overlap detail**: Adds polish and reinforces the "crossed" concept
