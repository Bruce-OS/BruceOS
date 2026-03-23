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

# Install build dependencies
# anaconda is required for --no-virt mode
dnf install -y lorax livecd-tools anaconda

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
    --make-iso \
    --iso-only \
    --iso-name "BruceOS-1.0-x86_64.iso"

echo ""
echo "=== Build complete ==="
echo "ISO: ${OUTPUT_DIR}/BruceOS-1.0-x86_64.iso"
