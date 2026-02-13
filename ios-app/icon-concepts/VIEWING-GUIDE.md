# Viewing Guide

## How to Review These Icons

### On Your Mac
1. Open Finder and navigate to this folder
2. Switch to Icon View (Cmd+1) or Gallery View (Cmd+4)
3. Compare the `*_120.png` files at actual app icon size

### On Your iPhone
1. AirDrop the `*_120.png` files to your iPhone
2. Save to Photos
3. View them on your home screen:
   - Screenshot your home screen
   - Edit the screenshot
   - Add the icon mockups over existing apps
   - See how they look in context

### For Mockups
Use this free tool to see icons on actual devices:
- https://www.appicon.co (paste your 1024px images)
- https://mockuphone.com (device mockups)

## Questions to Ask

1. **Recognition** - Can you tell what it is at a glance?
2. **Uniqueness** - Does it stand out from other apps?
3. **Scalability** - Does it look good at 40px (smallest iOS size)?
4. **Brand fit** - Does it match your game's personality?
5. **Dark/Light** - Does it work on both home screen modes?

## Testing Checklist

- [ ] View at 120px (actual app icon size)
- [ ] View at 40px (smallest iOS widget size)
- [ ] Test on light home screen background
- [ ] Test on dark home screen background
- [ ] Show to 5+ potential players
- [ ] Check against competitor apps in App Store
- [ ] Verify it's memorable (can people describe it later?)

## Quick Edit Guide

All icons are built from SVG files in this folder. To make changes:

1. Open `concept#_*.svg` in any vector editor (Figma, Illustrator, Inkscape)
2. Edit colors, shapes, proportions
3. Export as PNG at 1024×1024
4. Create 120px version: `sips -Z 120 your_icon.png --out icon_120.png`

## Color Codes (for reference)

**Titans (Blue):**
- Light: `#00aaff` / `#00d4ff`
- Dark: `#0066ff` / `#0033cc`

**Guardians (Orange):**
- Light: `#ffaa44` / `#ff8800`
- Dark: `#ff5522` / `#ff4400`

**Phantoms (Purple):**
- Light: `#dd66ff` / `#cc44ff`
- Dark: `#aa33cc` / `#8800aa`

**UI Cyan (targeting):**
- `#00ffdd` / `#00ffff`

**Backgrounds:**
- Navy: `#1a1a3e` → `#0f0f2e`
- Black: `#000000` → `#1a1a1a`
