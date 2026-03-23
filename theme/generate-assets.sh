#!/bin/bash
# Generate all BruceOS theme assets from SVGs
# Requires: rsvg-convert (librsvg2-tools) and imagemagick
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Generating BruceOS theme assets ==="

# Check for rsvg-convert
if ! command -v rsvg-convert &> /dev/null; then
    echo "ERROR: rsvg-convert not found. Install librsvg2-tools."
    exit 1
fi

#--- Wallpaper (3840x2160 PNG from SVG) ---
echo "Generating wallpaper..."
rsvg-convert -w 3840 -h 2160 "${SCRIPT_DIR}/wallpaper.svg" -o "${SCRIPT_DIR}/wallpaper.png"

#--- Branding logos (white-label replacements for Fedora logos) ---
echo "Generating branding logos..."
LOGO="${SCRIPT_DIR}/bruceos-logo.svg"

# GDM logo (48x48)
rsvg-convert -w 48 -h 48 "${LOGO}" -o "${SCRIPT_DIR}/branding/fedora-gdm-logo.png"

# Small logo (16x16)
rsvg-convert -w 16 -h 16 "${LOGO}" -o "${SCRIPT_DIR}/branding/fedora-logo-small.png"

# Standard logo (256x256)
rsvg-convert -w 256 -h 256 "${LOGO}" -o "${SCRIPT_DIR}/branding/fedora-logo.png"

# System logo white (for dark backgrounds, 128x128)
rsvg-convert -w 128 -h 128 "${LOGO}" -o "${SCRIPT_DIR}/branding/system-logo-white.png"

# Sprite (used by some GNOME components, 256x256)
rsvg-convert -w 256 -h 256 "${LOGO}" -o "${SCRIPT_DIR}/branding/fedora-logo-sprite.png"

# SVG copies
cp "${LOGO}" "${SCRIPT_DIR}/branding/fedora-logo-sprite.svg"
cp "${LOGO}" "${SCRIPT_DIR}/branding/fedora_logo.svg"
cp "${LOGO}" "${SCRIPT_DIR}/branding/fedora_logo_darkbackground.svg"
cp "${LOGO}" "${SCRIPT_DIR}/branding/fedora_logo_lightbackground.svg"

#--- Plymouth assets ---
echo "Generating Plymouth assets..."
PLYMOUTH_DIR="${SCRIPT_DIR}/plymouth/bruceos"

# Logo for boot splash (200x200)
rsvg-convert -w 200 -h 200 "${LOGO}" -o "${PLYMOUTH_DIR}/logo.png"

# Spinner frames
if command -v convert &> /dev/null; then
    for i in $(seq 0 35); do
        angle=$((i * 10))
        convert -size 48x48 xc:none \
            -fill 'rgba(16,185,129,0.15)' -draw "circle 24,24 24,4" \
            -fill '#10b981' -draw "translate 24,24 rotate ${angle} circle 0,-20 3,-20" \
            "${PLYMOUTH_DIR}/spinner-${i}.png"
    done
    echo "Generated 36 spinner frames"
else
    echo "WARN: ImageMagick not found, skipping spinner frames"
fi

echo "=== Done ==="
