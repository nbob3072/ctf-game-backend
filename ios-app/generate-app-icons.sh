#!/bin/bash
# Generate all iOS app icon sizes from 1024x1024 source

SOURCE="icon-concepts/concept5-crossed-flags/icon-1024.png"
OUTPUT_DIR="CTFGame/Assets.xcassets/AppIcon.appiconset"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# iOS App Icon sizes (all required sizes)
declare -A SIZES=(
    ["icon-20@2x.png"]="40"
    ["icon-20@3x.png"]="60"
    ["icon-29@2x.png"]="58"
    ["icon-29@3x.png"]="87"
    ["icon-40@2x.png"]="80"
    ["icon-40@3x.png"]="120"
    ["icon-60@2x.png"]="120"
    ["icon-60@3x.png"]="180"
    ["icon-76@2x.png"]="152"
    ["icon-83.5@2x.png"]="167"
    ["icon-1024.png"]="1024"
)

echo "🎨 Generating iOS app icons from: $SOURCE"
echo ""

# Check if source exists
if [ ! -f "$SOURCE" ]; then
    echo "❌ Source file not found: $SOURCE"
    exit 1
fi

# Check if sips is available (macOS built-in)
if ! command -v sips &> /dev/null; then
    echo "❌ sips command not found (required on macOS)"
    exit 1
fi

# Generate each size
for filename in "${!SIZES[@]}"; do
    size="${SIZES[$filename]}"
    output="$OUTPUT_DIR/$filename"
    
    sips -z "$size" "$size" "$SOURCE" --out "$output" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo "✅ Generated ${size}x${size} → $filename"
    else
        echo "❌ Failed to generate $filename"
    fi
done

echo ""
echo "🎉 Icon generation complete!"
echo "📁 Output: $OUTPUT_DIR"
echo ""
echo "Next steps:"
echo "1. Open Xcode project"
echo "2. Icons should appear in Assets.xcassets/AppIcon"
echo "3. Clean build folder (Cmd+Shift+K)"
echo "4. Rebuild project"
