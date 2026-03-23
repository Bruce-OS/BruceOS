# Kickstart Reference

BruceOS is built from Fedora kickstart files. The kickstart defines every package, configuration, and post-install step that goes into the ISO. If it's not in the kickstart, it's not in BruceOS.

The primary kickstart is `kickstart/bruceos-base.ks`. It builds the Default profile ISO using `livemedia-creator` from the `lorax` toolchain.

## What the kickstart does

The kickstart is split into three sections:

1. **System configuration** -- language, keyboard, timezone, disk layout, bootloader, repos
2. **%packages** -- everything installed from Fedora repos during the build
3. **%post** -- scripts that run after package installation to configure the system

## System configuration

```
lang en_US.UTF-8
keyboard us
timezone UTC --utc
selinux --enforcing
firewall --enabled --service=ssh
```

Disk layout uses ext4 with a 12 GB root partition (this is for the live image build; the installer handles partitioning during actual installation):

```
zerombr
clearpart --all --initlabel
part / --fstype=ext4 --size=12288
```

A `liveuser` account is created with wheel group access for the live session.

## Repositories

The kickstart pulls packages from four sources:

| Repository | What it provides |
|-----------|-----------------|
| Fedora 43 base | Core OS, GNOME, system tools |
| Fedora 43 updates | Security and bug fixes |
| RPM Fusion Free | Multimedia codecs, additional drivers |
| RPM Fusion Nonfree | NVIDIA drivers, proprietary codecs |

Additional COPR repositories are added during `%post` for packages not in the main Fedora repos.

## Package sections

### GNOME desktop

The `@gnome-desktop` group plus individual packages:

- `gnome-shell`, `gdm`, `gnome-terminal`, `gnome-tweaks`, `gnome-software`
- `nautilus`, `evince`, `eog`, `gnome-calculator`, `gnome-text-editor`, `gnome-system-monitor`
- Extensions: `dash-to-dock`, `appindicator`
- Plymouth boot splash with spinner theme

### Terminal tools (from Fedora repos)

Packages available in the base Fedora repositories are installed in the `%packages` section:

`fish`, `atuin`, `bat`, `fzf`, `zoxide`, `ripgrep`, `btop`, `fastfetch`

### Fonts

`google-noto-sans-fonts`, `google-noto-serif-fonts`, `google-noto-sans-mono-fonts`, `jetbrains-mono-fonts-all`, `cascadia-code-fonts`

### System tools

`git`, `curl`, `wget`, `unzip`, `p7zip`, `flatpak`, `podman`, `distrobox`, `firewalld`, `NetworkManager`

### Boot and firmware

`dracut-live`, GRUB2 packages (UEFI and BIOS), `shim-x64`, `syslinux`, `linux-firmware`, Intel wireless firmware

## Post-install steps

The `%post` section runs two scripts after packages are installed.

### Script 1: System configuration

Runs inside the chroot (the installed system). In order:

1. **GDM auto-login** -- configures automatic login for `liveuser` with Wayland enabled
2. **CachyOS BORE kernel** -- adds the COPR repository and installs `kernel-cachyos`. Falls back to the stock Fedora kernel if the COPR is unavailable.
3. **Terminal tools from COPR** -- enables COPR repos for `starship`, `lazygit`, and `ghostty`, then installs `ghostty`, `starship`, `eza`, `lazygit`, `yazi`, and `zellij`
4. **RPM Fusion** -- installs the RPM Fusion free and nonfree release packages
5. **Multimedia codecs** -- installs GStreamer plugins, OpenH264, and FFmpeg
6. **Flathub** -- adds the Flathub Flatpak remote
7. **Fish as default shell** -- sets Fish as the system default via `chsh`
8. **Ghostty config** -- writes system-wide config to `/etc/ghostty/config`
9. **Fish config** -- writes init script to `/etc/fish/conf.d/bruce.fish` (Starship, Atuin, zoxide init + aliases)
10. **Starship config** -- writes prompt config to `/etc/xdg/starship.toml`
11. **GPU auto-detection** -- detects NVIDIA/AMD/Intel GPU via `lspci` and installs appropriate drivers
12. **Performance tuning** -- sets `vm.max_map_count=1048576` and `vm.swappiness=10` via sysctl
13. **ZRAM** -- installs `zram-generator` and configures ZRAM at half RAM with zstd compression
14. **OS branding** -- writes `/etc/os-release` with BruceOS identity

### Script 2: WhiteSur theme (network-dependent)

Runs with `--nochroot` (accesses both the build environment and the installed system). This script:

1. Checks for network connectivity. If offline, skips gracefully.
2. Clones the WhiteSur GTK theme and installs the Dark variant.
3. Clones the WhiteSur icon theme and installs it.
4. Writes GNOME dconf defaults: theme, fonts, window button layout, dock position, favorite apps, enabled extensions.
5. Compiles the dconf database.

If the build has no network access, the system boots with Adwaita defaults. The theme can be installed later.

## How to add packages

### Fedora packages

If the package is in the Fedora repos, add it to the `%packages` section:

```
%packages
# ... existing packages ...
your-new-package
%end
```

### COPR packages

If the package is in a COPR repository, add it to the `%post` section:

```bash
# In %post
dnf copr enable -y owner/repo-name
dnf install -y your-copr-package || echo "WARN: your-copr-package not available"
```

Always include a fallback or `|| true` so the build doesn't fail if the COPR is temporarily down.

### Flatpak applications

Flatpak apps should not be pre-installed in the ISO (they're large and change frequently). Instead, the Flathub remote is configured so users can install Flatpak apps after boot.

## Kickstart files

| File | Profile | Status |
|------|---------|--------|
| `bruceos-base.ks` | Default | Available |
| `bruceos-gaming.ks` | Gaming | Planned |
| `bruceos-vfx.ks` | VFX | Planned |
| `bruceos-pi.ks` | Kids (ARM64) | Planned |
