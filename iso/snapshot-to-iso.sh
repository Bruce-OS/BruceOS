#!/bin/bash
# BruceOS Snapshot-to-ISO Builder
# Creates a live ISO from a pre-built squashfs rootfs
# Usage: ./snapshot-to-iso.sh <squashfs-path> <output-iso>
set -euo pipefail

SQUASHFS="${1:-/home/danger/bruceos-rootfs.squashfs}"
OUTPUT="${2:-/home/danger/Documents/GitHub/BruceOS/output/BruceOS-1.0-snapshot.iso}"
WORKDIR="/tmp/bruceos-snapshot-iso"
KVER="6.19.9-cachyos1.fc43.x86_64"

echo "=== BruceOS Snapshot-to-ISO ==="
echo "Squashfs: ${SQUASHFS}"
echo "Output:   ${OUTPUT}"

# Clean workspace
rm -rf "${WORKDIR}"
mkdir -p "${WORKDIR}"/{LiveOS,isolinux,EFI/BOOT,images/pxeboot}

# 1. Copy squashfs
echo "Copying squashfs..."
mkdir -p "${WORKDIR}/LiveOS"
cp "${SQUASHFS}" "${WORKDIR}/LiveOS/squashfs.img"

# 2. Extract kernel + initramfs from squashfs
echo "Extracting kernel..."
MNTDIR="/tmp/bruceos-sqmnt"
mkdir -p "${MNTDIR}"
mount -t squashfs -o ro "${SQUASHFS}" "${MNTDIR}"

cp "${MNTDIR}/boot/vmlinuz-${KVER}" "${WORKDIR}/images/pxeboot/vmlinuz"
cp "${MNTDIR}/boot/vmlinuz-${KVER}" "${WORKDIR}/isolinux/vmlinuz"

# 3. Rebuild initramfs with live boot support
echo "Rebuilding initramfs with live boot support..."
dracut --no-hostonly \
    --add "dmsquash-live livenet" \
    --kver "${KVER}" \
    --kmoddir "${MNTDIR}/lib/modules/${KVER}" \
    --sysroot "${MNTDIR}" \
    --force \
    "${WORKDIR}/images/pxeboot/initrd.img" 2>&1 || {
    echo "dracut failed, using chroot method..."
    chroot "${MNTDIR}" dracut --no-hostonly \
        --add "dmsquash-live livenet" \
        --force \
        /tmp/initrd-live.img "${KVER}" 2>&1
    cp "${MNTDIR}/tmp/initrd-live.img" "${WORKDIR}/images/pxeboot/initrd.img"
}

cp "${WORKDIR}/images/pxeboot/initrd.img" "${WORKDIR}/isolinux/initrd.img"

# 4. ISOLINUX (BIOS boot)
echo "Setting up ISOLINUX..."
cp /usr/share/syslinux/isolinux.bin "${WORKDIR}/isolinux/"
cp /usr/share/syslinux/ldlinux.c32 "${WORKDIR}/isolinux/"
cp /usr/share/syslinux/libcom32.c32 "${WORKDIR}/isolinux/"
cp /usr/share/syslinux/libutil.c32 "${WORKDIR}/isolinux/"
cp /usr/share/syslinux/vesamenu.c32 "${WORKDIR}/isolinux/"

cat > "${WORKDIR}/isolinux/isolinux.cfg" << 'ISOCFG'
UI vesamenu.c32
TIMEOUT 30
DEFAULT live

LABEL live
    MENU LABEL BruceOS Live
    KERNEL vmlinuz
    APPEND initrd=initrd.img root=live:CDLABEL=BruceOS-LIVE rd.live.image rd.live.overlay.size=8192 quiet rhgb
ISOCFG

# 5. GRUB EFI boot
echo "Setting up EFI boot..."
cp "${MNTDIR}/boot/efi/EFI/fedora/grubx64.efi" "${WORKDIR}/EFI/BOOT/BOOTX64.EFI" 2>/dev/null || \
    cp /boot/efi/EFI/fedora/grubx64.efi "${WORKDIR}/EFI/BOOT/BOOTX64.EFI" 2>/dev/null || \
    cp "${MNTDIR}/boot/efi/EFI/BOOT/BOOTX64.EFI" "${WORKDIR}/EFI/BOOT/BOOTX64.EFI" 2>/dev/null || true

cat > "${WORKDIR}/EFI/BOOT/grub.cfg" << 'GRUBCFG'
set timeout=3
set default=0

menuentry "BruceOS Live" {
    linux /images/pxeboot/vmlinuz root=live:CDLABEL=BruceOS-LIVE rd.live.image rd.live.overlay.size=8192 quiet rhgb
    initrd /images/pxeboot/initrd.img
}
GRUBCFG

# Create EFI image
dd if=/dev/zero of="${WORKDIR}/images/efiboot.img" bs=1M count=16
mkfs.vfat "${WORKDIR}/images/efiboot.img"
EFIMNT="/tmp/bruceos-efimnt"
mkdir -p "${EFIMNT}"
mount "${WORKDIR}/images/efiboot.img" "${EFIMNT}"
mkdir -p "${EFIMNT}/EFI/BOOT"
cp "${WORKDIR}/EFI/BOOT/BOOTX64.EFI" "${EFIMNT}/EFI/BOOT/"
cp "${WORKDIR}/EFI/BOOT/grub.cfg" "${EFIMNT}/EFI/BOOT/"
umount "${EFIMNT}"

# 6. Unmount squashfs
umount "${MNTDIR}"

# 7. Create ISO
echo "Creating ISO..."
mkdir -p "$(dirname "${OUTPUT}")"
xorriso -as mkisofs \
    -o "${OUTPUT}" \
    -isohybrid-mbr /usr/share/syslinux/isohdpfx.bin \
    -V "BruceOS-LIVE" \
    -b isolinux/isolinux.bin \
    -c isolinux/boot.cat \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    -eltorito-alt-boot \
    -e images/efiboot.img \
    -no-emul-boot \
    -isohybrid-gpt-basdat \
    -R -J \
    "${WORKDIR}" 2>&1

echo "=== Done ==="
echo "ISO: ${OUTPUT}"
ls -lh "${OUTPUT}"

# Cleanup
rm -rf "${WORKDIR}"
