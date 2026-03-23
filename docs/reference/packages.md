# Package List

Everything installed in the BruceOS base image. Packages marked with **(COPR)** come from Fedora COPR repositories and are installed during the post-install phase.

## Desktop

| Package | Description |
|---------|-------------|
| `gnome-shell` | GNOME desktop environment |
| `gdm` | GNOME Display Manager |
| `gnome-terminal` | Default GNOME terminal (Ghostty is the primary terminal) |
| `gnome-tweaks` | Advanced GNOME settings |
| `gnome-software` | Application store |
| `nautilus` | File manager |
| `evince` | Document viewer |
| `eog` | Image viewer |
| `gnome-calculator` | Calculator |
| `gnome-text-editor` | Text editor |
| `gnome-system-monitor` | System monitor |
| `gnome-shell-extension-dash-to-dock` | Dock at the bottom of the screen |
| `gnome-shell-extension-appindicator` | System tray support |

## Terminal

| Package | Source | Description |
|---------|--------|-------------|
| `ghostty` | COPR (`pgdev/ghostty`) | GPU-accelerated terminal emulator |
| `fish` | Fedora | Shell with built-in autocompletion |
| `starship` | COPR (`atim/starship`) | Cross-shell prompt |
| `atuin` | Fedora | Shell history database and sync |
| `zellij` | COPR | Terminal multiplexer |
| `bat` | Fedora | `cat` with syntax highlighting |
| `eza` | COPR | Modern `ls` replacement |
| `fzf` | Fedora | Fuzzy finder |
| `zoxide` | Fedora | Smarter `cd` |
| `ripgrep` | Fedora | Fast `grep` replacement |
| `yazi` | COPR | Terminal file manager |
| `lazygit` | COPR (`atim/lazygit`) | Terminal Git UI |
| `btop` | Fedora | System monitor |
| `fastfetch` | Fedora | System information tool |

## Fonts

| Package | What it provides |
|---------|-----------------|
| `google-noto-sans-fonts` | Noto Sans (UI font) |
| `google-noto-serif-fonts` | Noto Serif |
| `google-noto-sans-mono-fonts` | Noto Sans Mono |
| `jetbrains-mono-fonts-all` | JetBrains Mono (terminal font) |
| `cascadia-code-fonts` | Cascadia Code |

## System tools

| Package | Description |
|---------|-------------|
| `git` | Version control |
| `curl` | HTTP client |
| `wget` | File downloader |
| `unzip` | ZIP extraction |
| `p7zip` | 7-Zip extraction |
| `flatpak` | Flatpak runtime |
| `podman` | Container runtime (rootless) |
| `distrobox` | Run other Linux distributions in containers |
| `firewalld` | Firewall |
| `NetworkManager` | Network management |

## Multimedia

Installed from RPM Fusion during post-install:

| Package | Description |
|---------|-------------|
| `gstreamer1-plugins-bad-free` | GStreamer codecs |
| `gstreamer1-plugins-ugly` | GStreamer codecs (patent-encumbered) |
| `gstreamer1-plugin-openh264` | H.264 codec |
| `ffmpeg` | Audio/video encoder and decoder |

## Boot and firmware

| Package | Description |
|---------|-------------|
| `dracut-live` | Live boot support |
| `grub2-pc` | BIOS bootloader |
| `grub2-efi-x64` | UEFI bootloader |
| `shim-x64` | UEFI Secure Boot shim |
| `syslinux` | Legacy boot support |
| `linux-firmware` | Hardware firmware blobs |
| `plymouth` | Boot splash |

## Kernel

| Package | Source | Description |
|---------|--------|-------------|
| `kernel-cachyos` | COPR (`bieszczaders/kernel-cachyos`) | CachyOS kernel with BORE scheduler |
| `kernel-cachyos-devel-matched` | COPR | Kernel headers (for DKMS modules like NVIDIA) |

Falls back to the stock Fedora kernel if the COPR repository is unavailable during build.

## Gaming (planned)

These packages are planned for the Gaming profile kickstart:

| Package | Description |
|---------|-------------|
| `steam` | Steam client (RPM Fusion) |
| `proton-ge-custom` | Proton-GE compatibility layer |
| `mangohud` | Performance overlay |
| `gamemode` | CPU/GPU performance optimizer |
| `gamescope` | SteamOS compositor |
| `vkbasalt` | Post-processing layer for Vulkan |
| `ananicy-cpp` | Process scheduler |

## VFX (planned)

These packages are planned for the VFX profile kickstart:

| Package | Description |
|---------|-------------|
| `blender` | 3D modeling and animation |
| `gimp` | Image editor |
| `krita` | Digital painting |
| `inkscape` | Vector graphics |
| `kdenlive` | Video editor |
| `obs-studio` | Screen recording and streaming |
| `ardour` | Digital audio workstation |
| DaVinci Resolve | Professional video editor (separate installer) |
