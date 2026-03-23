# Building from Source

BruceOS ISOs are built from Fedora kickstart files using `livemedia-creator` inside a Podman container. The build is reproducible and doesn't require a Fedora host.

## Prerequisites

You need two things:

- **Podman** -- any recent version. Docker works too, substitute `docker` for `podman` in the commands below.
- **sudo access** -- the build requires `--privileged` to mount filesystems and build the ISO image.

## Clone the repository

```bash
git clone https://github.com/Bruce-OS/BruceOS.git
cd BruceOS
```

## Validate the kickstart (optional)

If you have `pykickstart` installed, you can validate the kickstart syntax before building:

```bash
ksvalidator kickstart/bruceos-base.ks
```

This catches syntax errors but won't verify that packages exist or that URLs resolve.

## Build the ISO

```bash
sudo podman run --rm --privileged \
  --pid=host \
  --security-opt label=disable \
  -v /dev:/dev \
  -v $(pwd):/build \
  fedora:43 \
  bash -c "bash /build/iso/build.sh bruceos-base.ks"
```

What this does:

1. Pulls the `fedora:43` container image (if not cached).
2. Mounts the repository at `/build` inside the container.
3. Runs `iso/build.sh`, which installs `lorax` and `livemedia-creator`, then builds the ISO from the kickstart.

The build takes 15--30 minutes depending on your machine and network speed. Most of the time is spent downloading packages from Fedora mirrors.

## Output

The finished ISO lands at:

```
output/BruceOS-1.0-x86_64.iso
```

Expect roughly 2 GB. The `output/` directory is created by the build script and is gitignored.

## Testing the ISO

### GNOME Boxes

1. Open GNOME Boxes.
2. Click "+" and select the ISO file.
3. Set the OS to "Fedora 43" (or "Unknown Linux").
4. Allocate at least 4 GB RAM and 20 GB disk.
5. Enable UEFI in the VM settings.

### QEMU (command line)

```bash
qemu-system-x86_64 \
  -enable-kvm \
  -m 4096 \
  -bios /usr/share/edk2/ovmf/OVMF_CODE.fd \
  -cdrom output/BruceOS-1.0-x86_64.iso \
  -boot d
```

Adjust the OVMF path for your distribution. On Fedora it's typically `/usr/share/edk2/ovmf/OVMF_CODE.fd`.

### virt-manager

Create a new VM, select the ISO as the installation media, choose "Fedora 43" as the OS, allocate 4 GB RAM, and set firmware to UEFI.

## Building other profiles

The Gaming, VFX, and Kids kickstart files are planned but not yet available. Currently only `bruceos-base.ks` exists.

When they ship, you build them the same way:

```bash
# Gaming profile (coming soon)
sudo podman run --rm --privileged \
  --pid=host --security-opt label=disable \
  -v /dev:/dev -v $(pwd):/build \
  fedora:43 bash -c "bash /build/iso/build.sh bruceos-gaming.ks"
```

## Build troubleshooting

**"Kickstart file not found."** Make sure you're running the podman command from the repository root, not from inside a subdirectory.

**Build fails downloading packages.** Mirror issues are common. Wait a few minutes and try again. The build script uses `set -euo pipefail`, so any package download failure stops the build.

**"Permission denied" errors.** The `--privileged` and `--security-opt label=disable` flags are required. The build mounts filesystems and creates disk images, which need elevated permissions inside the container.

**Build succeeds but ISO doesn't boot.** Check that your VM is set to UEFI boot. The ISO includes both UEFI and Legacy BIOS bootloaders, but UEFI is the tested path.
