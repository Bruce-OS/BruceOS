# Installation

BruceOS installs from a live USB. You download the ISO, write it to a USB drive, boot from it, and run the installer.

## Download the ISO

ISO downloads are coming soon. BruceOS is in active development and not yet ready for daily use.

When available, ISOs will be published at [bruceos.com](https://bruceos.com) with SHA256 checksums for verification.

If you want to test now, you can [build the ISO from source](/guide/building).

## Write to USB

You need a USB drive with at least 4 GB of space. Everything on the drive will be erased.

### Option A: Fedora Media Writer (recommended)

Download [Fedora Media Writer](https://flathub.org/apps/org.fedoraproject.MediaWriter), select "Custom image", and point it at the BruceOS ISO.

### Option B: dd

```bash
# Find your USB device — be careful, dd will overwrite whatever you point it at
lsblk

# Write the ISO (replace /dev/sdX with your actual USB device)
sudo dd if=BruceOS-1.0-x86_64.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

Double-check the device name. `dd` does not ask for confirmation and will happily destroy the wrong disk.

## Boot from USB

1. Insert the USB drive and reboot your machine.
2. Enter your firmware boot menu (usually F12, F2, or Del during POST).
3. Select the USB drive. UEFI boot is recommended.
4. BruceOS boots into a live desktop session.

## Run the installer

The live session gives you a working BruceOS desktop to try before installing.

When you're ready to install to disk:

- **Current state:** BruceOS uses the Anaconda installer inherited from Fedora. It works, but it's the standard Fedora installation flow with no BruceOS customization yet.
- **Planned:** A custom Calamares installer with BruceOS branding and profile selection (Default, Gaming, VFX, Kids) is in development.

The installer handles disk partitioning, user creation, and bootloader setup. BruceOS defaults to ext4 with a standard partition layout.

## After installation

Remove the USB drive and reboot. BruceOS will boot into GDM and auto-login to your desktop.

See [First Boot](/guide/first-boot) for what happens next.

## Troubleshooting

**Machine won't boot from USB.** Check that Secure Boot is disabled in your UEFI firmware settings. BruceOS does not yet support Secure Boot.

**Black screen after boot.** If you have an NVIDIA GPU, try adding `nomodeset` to the kernel command line (press `e` at the GRUB menu, add `nomodeset` to the `linux` line, press Ctrl+X to boot). The post-install script should have installed NVIDIA drivers, but this can help during live boot.

**No Wi-Fi.** Some wireless chipsets require firmware not included in the base ISO. Connect via ethernet if possible, then install firmware packages after boot.
