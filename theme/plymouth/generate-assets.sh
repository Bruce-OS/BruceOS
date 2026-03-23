#!/bin/bash
# Generate Plymouth theme assets from SVG
# Requires: rsvg-convert (librsvg2-tools) or inkscape, and imagemagick
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_DIR="${SCRIPT_DIR}/bruceos"
LOGO_SVG="${SCRIPT_DIR}/../bruceos-logo.svg"

echo "=== Generating Plymouth assets ==="

# Generate logo PNG (200x200 for boot splash)
if command -v rsvg-convert &> /dev/null; then
    rsvg-convert -w 200 -h 200 "${LOGO_SVG}" -o "${THEME_DIR}/logo.png"
elif command -v inkscape &> /dev/null; then
    inkscape -w 200 -h 200 "${LOGO_SVG}" -o "${THEME_DIR}/logo.png"
else
    echo "ERROR: Need rsvg-convert or inkscape to generate PNGs"
    exit 1
fi
echo "Generated logo.png"

# Generate spinner frames (36 frames, blue dot on circle)
if command -v convert &> /dev/null; then
    for i in $(seq 0 35); do
        angle=$((i * 10))
        convert -size 48x48 xc:none \
            -fill 'rgba(53,132,228,0.15)' -draw "circle 24,24 24,4" \
            -fill '#3584e4' -draw "translate 24,24 rotate ${angle} circle 0,-20 3,-20" \
            "${THEME_DIR}/spinner-${i}.png"
    done
    echo "Generated 36 spinner frames"
else
    echo "WARN: ImageMagick not found, creating placeholder spinners"
    # Create minimal 1px PNGs as placeholders
    for i in $(seq 0 35); do
        printf '\x89PNG\r\n\x1a\n' > "${THEME_DIR}/spinner-${i}.png"
    done
fi

echo "=== Done ==="
