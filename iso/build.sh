#!/bin/bash
# BruceOS ISO Builder
# Usage: ./build.sh [kickstart-file]
# Default: bruceos-base.ks
#
# Requires: lorax, anaconda (for --no-virt mode)
# Run inside Podman container for reproducibility:
#   podman run --rm --privileged -v $(pwd):/build fedora:43 bash /build/iso/build.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "${SCRIPT_DIR}")"
KS_FILE="${1:-bruceos-base.ks}"
KS_PATH="${PROJECT_DIR}/kickstart/${KS_FILE}"
OUTPUT_DIR="${PROJECT_DIR}/output"

if [ ! -f "${KS_PATH}" ]; then
    echo "ERROR: Kickstart file not found: ${KS_PATH}"
    exit 1
fi

echo "=== BruceOS ISO Build ==="
echo "Kickstart: ${KS_FILE}"
echo "Output:    ${OUTPUT_DIR}"
echo ""

# Install build dependencies (skipped if already present, e.g. in bruceos-builder container)
if ! command -v livemedia-creator &>/dev/null; then
    echo "Installing build dependencies..."
    dnf install -y lorax livecd-tools anaconda \
        grub2-efi-x64 grub2-efi-x64-modules grub2-efi-x64-cdboot \
        grub2-pc grub2-pc-modules \
        shim-x64 syslinux syslinux-nonlinux xorriso \
        librsvg2-tools ImageMagick
else
    echo "Build dependencies already installed, skipping."
fi

# Generate theme assets (wallpaper, branding logos, Plymouth PNGs)
if [ -x "${PROJECT_DIR}/theme/generate-assets.sh" ]; then
    echo "Generating theme assets..."
    bash "${PROJECT_DIR}/theme/generate-assets.sh"
fi

# Pre-download yazi binary (not in any Fedora/COPR repo)
if [ ! -f /usr/local/bin/yazi ]; then
    echo "Downloading yazi..."
    curl -sL https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip -o /tmp/yazi.zip && \
        unzip -o /tmp/yazi.zip -d /tmp/yazi && \
        cp /tmp/yazi/yazi-x86_64-unknown-linux-gnu/yazi /usr/local/bin/ && \
        chmod +x /usr/local/bin/yazi && \
        rm -rf /tmp/yazi /tmp/yazi.zip && \
        echo "yazi downloaded" || echo "WARN: yazi download failed"
fi

# livemedia-creator requires resultdir to NOT exist — remove if present
if [ -d "${OUTPUT_DIR}" ]; then
    echo "Removing existing output directory..."
    rm -rf "${OUTPUT_DIR}"
fi

# Build the live ISO
livemedia-creator \
    --ks "${KS_PATH}" \
    --no-virt \
    --resultdir "${OUTPUT_DIR}" \
    --project "BruceOS" \
    --releasever "43" \
    --volid "BruceOS-1-0" \
    --make-iso \
    --iso-only \
    --iso-name "BruceOS-1.0-x86_64.iso"

# Run build verification against the installed rootfs
# (The rootfs is in the livemedia working directory if available)
ROOTFS=$(find /var/tmp -maxdepth 2 -name "rootfs" -type d 2>/dev/null | head -1)
if [ -n "${ROOTFS}" ] && [ -d "${ROOTFS}" ]; then
    echo ""
    echo "=== Running build verification ==="
    chroot "${ROOTFS}" bash /build/iso/verify-build.sh || true
fi

echo ""
echo "=== Build complete ==="
echo "ISO: ${OUTPUT_DIR}/BruceOS-1.0-x86_64.iso"
