# BruceOS Pi Kickstart — Fedora 43 ARM64
# "They call me Bruce." — Raspberry Pi Edition
#
# Architecture: aarch64 (Raspberry Pi 4/5)
# Standalone kickstart — Pi builds differently from x86_64.
# No COPR repos (most lack aarch64 builds).
# Lighter package set — kids/education focused.

#--------------------------------------
# Installation settings
#--------------------------------------
lang en_US.UTF-8
keyboard us
timezone UTC --utc
selinux --enforcing
firewall --enabled --service=ssh
network --bootproto=dhcp --activate --hostname=bruceos-pi

#--------------------------------------
# Disk layout (smaller for SD card / eMMC)
#--------------------------------------
zerombr
clearpart --all --initlabel
part /boot/efi --fstype=efi --size=600 --label=EFI
part / --fstype=ext4 --size=8192 --grow --label=BruceOS

#--------------------------------------
# Bootloader
#--------------------------------------
bootloader --timeout=5 --append="quiet"

#--------------------------------------
# Root password (disabled for live image)
#--------------------------------------
rootpw --lock

#--------------------------------------
# Live user — auto-login to GNOME
#--------------------------------------
user --name=liveuser --groups=wheel --password=liveuser --plaintext

#--------------------------------------
# Repos — Fedora 43 aarch64
#--------------------------------------
url --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-43&arch=aarch64
repo --name=updates --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f43&arch=aarch64

# RPM Fusion (aarch64 builds available)
repo --name=rpmfusion-free --mirrorlist=https://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-43&arch=aarch64
repo --name=rpmfusion-nonfree --mirrorlist=https://mirrors.rpmfusion.org/mirrorlist?repo=nonfree-fedora-43&arch=aarch64

#--------------------------------------
# Packages — lighter set for Pi
#--------------------------------------
%packages
# Base GNOME desktop
@base-x
@gnome-desktop
@hardware-support
gnome-shell
gdm
gnome-tweaks
gnome-software
nautilus
evince
eog
gnome-calculator
gnome-text-editor
gnome-system-monitor
gnome-terminal

# GNOME extensions
gnome-shell-extension-dash-to-dock
gnome-shell-extension-appindicator

# Plymouth
plymouth
plymouth-scripts
plymouth-theme-spinner

# Fonts
google-noto-sans-fonts
google-noto-serif-fonts
google-noto-sans-mono-fonts
cascadia-code-fonts

# Stock Fedora ARM kernel (no CachyOS for aarch64)
kernel
kernel-modules
kernel-modules-extra

# Raspberry Pi firmware and boot support
bcm2711-firmware
bcm2712-firmware
uboot-images-armv8
linux-firmware

# EFI bootloader (aarch64)
grub2-efi-aa64
grub2-efi-aa64-modules
shim-aa64

# Terminal stack (lightweight — skip ghostty/starship/zellij/lazygit)
fish
bat
fzf
zoxide
ripgrep
btop
fastfetch

# RPM Fusion codecs
rpmfusion-free-release
rpmfusion-nonfree-release
gstreamer1-plugins-bad-free
gstreamer1-plugins-ugly
gstreamer1-plugin-openh264

# ZRAM (important on Pi with limited RAM)
zram-generator

# Core system tools
git
curl
wget
unzip
flatpak
podman
firewalld
NetworkManager

# Education apps
gnome-clocks
gnome-weather
gnome-maps
gnome-characters

%end

#--------------------------------------
# Post-install — LOCAL CONFIG ONLY (no network in %post)
#--------------------------------------
%post --log=/root/bruceos-post.log
#!/bin/bash
set -euo pipefail

echo "=== BruceOS Pi post-install starting ==="

#--- Graphical target + GDM auto-login ---
systemctl set-default graphical.target

mkdir -p /etc/gdm
cat > /etc/gdm/custom.conf << 'GDMEOF'
[daemon]
AutomaticLoginEnable=True
AutomaticLogin=liveuser
WaylandEnable=true

[security]

[xdmcp]

[chooser]

[debug]
GDMEOF

# Passwordless sudo for liveuser
echo "liveuser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/liveuser
chmod 440 /etc/sudoers.d/liveuser

#--- Set Fish as default shell ---
chsh -s /usr/bin/fish root
chsh -s /usr/bin/fish liveuser
sed -i 's|^SHELL=.*|SHELL=/usr/bin/fish|' /etc/default/useradd 2>/dev/null || true

#--- Fish config (no starship/atuin/eza on Pi) ---
mkdir -p /etc/fish/conf.d
cat > /etc/fish/conf.d/bruce.fish << 'FISHEOF'
# BruceOS Pi — Fish configuration
zoxide init fish | source

# Aliases (use standard tools, no eza/bat wrappers on Pi)
alias ll="ls -la --color=auto"

# Show BruceOS info on first shell in terminal
if status is-interactive; and not set -q BRUCE_GREETED
    set -g BRUCE_GREETED 1
    fastfetch --config /etc/fastfetch/config.jsonc 2>/dev/null
end
FISHEOF

#--- Fastfetch branding ---
mkdir -p /etc/fastfetch
cat > /etc/fastfetch/config.jsonc << 'FFCONFEOF'
{
  "logo": {
    "source": "         ██████████\n        ████████████\n       ██████  ██████\n       █████    █████\n       █████  ██████\n       ██████████████\n       █████  ██████\n       █████    █████\n       █████  ██████\n       ██████████████\n        ████████████\n         ██████████",
    "type": "data",
    "color": { "1": "green" },
    "padding": { "top": 1 }
  },
  "modules": [
    "title", "separator",
    "os", "kernel", "uptime", "packages",
    "shell", "terminal", "cpu", "gpu",
    "memory", "disk", "break", "colors"
  ]
}
FFCONFEOF

#--- Performance tuning (Pi-appropriate values) ---
cat > /etc/sysctl.d/99-bruceos.conf << 'SYSCTLEOF'
# BruceOS Pi performance tuning
vm.swappiness = 10
SYSCTLEOF

#--- ZRAM swap (critical for Pi — limited RAM) ---
cat > /etc/systemd/zram-generator.conf << 'ZRAMEOF'
[zram0]
zram-size = ram
compression-algorithm = zstd
ZRAMEOF

#--- Plymouth ---
plymouth-set-default-theme spinner || true

#--- Hostname ---
hostnamectl set-hostname bruceos-pi 2>/dev/null || echo "bruceos-pi" > /etc/hostname

#--- First-boot service for Flatpak + Flathub ---
cat > /etc/systemd/system/bruceos-first-boot.service << 'UNITEOF'
[Unit]
Description=BruceOS First Boot Setup
After=network-online.target
Wants=network-online.target
ConditionPathExists=!/var/lib/bruceos-first-boot-done

[Service]
Type=oneshot
ExecStart=/usr/libexec/bruceos-first-boot.sh
ExecStartPost=/usr/bin/touch /var/lib/bruceos-first-boot-done
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
UNITEOF

cat > /usr/libexec/bruceos-first-boot.sh << 'SCRIPTEOF'
#!/bin/bash
# BruceOS Pi first-boot: add Flathub
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
SCRIPTEOF
chmod +x /usr/libexec/bruceos-first-boot.sh
systemctl enable bruceos-first-boot.service

#--- Default browser (Firefox on Pi) ---
mkdir -p /etc/xdg
cat > /etc/xdg/mimeapps.list << 'MIMEEOF'
[Default Applications]
text/html=firefox.desktop
x-scheme-handler/http=firefox.desktop
x-scheme-handler/https=firefox.desktop
MIMEEOF

#--- Set system branding ---
cat > /etc/os-release << 'OSEOF'
NAME="BruceOS"
VERSION="1.0"
ID=bruceos
ID_LIKE=fedora
VERSION_ID=1.0
PLATFORM_ID="platform:f43"
PRETTY_NAME="BruceOS 1.0 (Pi)"
ANSI_COLOR="0;38;2;16;185;129"
LOGO=bruceos
CPE_NAME="cpe:/o:bruceos:bruceos:1.0"
HOME_URL="https://bruceos.com"
SUPPORT_URL="https://github.com/Bruce-OS/BruceOS/issues"
BUG_REPORT_URL="https://github.com/Bruce-OS/BruceOS/issues"
VARIANT="Pi"
VARIANT_ID=pi
DOCUMENTATION_URL="https://bruceos.com/guide/getting-started"
OSEOF

echo "=== BruceOS Pi post-install complete ==="
%end

#--------------------------------------
# Post-install — GNOME theming (nochroot, access to /build/)
#--------------------------------------
%post --nochroot --log=/mnt/sysimage/root/bruceos-theme.log
#!/bin/bash
set -uo pipefail

echo "=== Configuring BruceOS Pi GNOME desktop ==="

SYSROOT=/mnt/sysimage

#--- BruceOS wallpaper ---
if [ -f /build/theme/wallpaper.png ]; then
    mkdir -p "${SYSROOT}/usr/share/backgrounds/bruceos"
    cp /build/theme/wallpaper.png "${SYSROOT}/usr/share/backgrounds/bruceos/wallpaper.png"
elif [ -f /build/theme/wallpaper.svg ]; then
    if command -v rsvg-convert &>/dev/null; then
        mkdir -p "${SYSROOT}/usr/share/backgrounds/bruceos"
        rsvg-convert -w 1920 -h 1080 /build/theme/wallpaper.svg -o "${SYSROOT}/usr/share/backgrounds/bruceos/wallpaper.png"
    fi
fi

#--- White-label: replace Fedora logos with BruceOS ---
if [ -f /build/theme/bruceos-logo.svg ] && command -v rsvg-convert &>/dev/null; then
    LOGO=/build/theme/bruceos-logo.svg
    rsvg-convert -w 48 -h 48 "$LOGO" -o "${SYSROOT}/usr/share/pixmaps/fedora-gdm-logo.png" 2>/dev/null || true
    rsvg-convert -w 16 -h 16 "$LOGO" -o "${SYSROOT}/usr/share/pixmaps/fedora-logo-small.png" 2>/dev/null || true
    rsvg-convert -w 256 -h 256 "$LOGO" -o "${SYSROOT}/usr/share/pixmaps/fedora-logo.png" 2>/dev/null || true
    rsvg-convert -w 256 -h 256 "$LOGO" -o "${SYSROOT}/usr/share/pixmaps/fedora-logo-sprite.png" 2>/dev/null || true
    rsvg-convert -w 128 -h 128 "$LOGO" -o "${SYSROOT}/usr/share/pixmaps/system-logo-white.png" 2>/dev/null || true
    cp "$LOGO" "${SYSROOT}/usr/share/pixmaps/fedora-logo-sprite.svg" 2>/dev/null || true
fi

#--- GNOME dconf defaults ---
mkdir -p "${SYSROOT}/etc/dconf/db/local.d"
cat > "${SYSROOT}/etc/dconf/db/local.d/01-bruceos" << 'DCONFEOF'
[org/gnome/desktop/interface]
gtk-theme='Adwaita-dark'
icon-theme='Adwaita'
cursor-theme='Adwaita'
font-name='Noto Sans 11'
document-font-name='Noto Sans 11'
monospace-font-name='Cascadia Code 13'
color-scheme='prefer-dark'

[org/gnome/desktop/wm/preferences]
titlebar-font='Noto Sans Bold 11'
button-layout='close,minimize,maximize:'

[org/gnome/desktop/background]
picture-uri='file:///usr/share/backgrounds/bruceos/wallpaper.png'
picture-uri-dark='file:///usr/share/backgrounds/bruceos/wallpaper.png'
picture-options='zoom'

[org/gnome/desktop/screensaver]
picture-uri='file:///usr/share/backgrounds/bruceos/wallpaper.png'

[org/gnome/shell]
favorite-apps=['org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'firefox.desktop', 'org.gnome.Software.desktop']
enabled-extensions=['dash-to-dock@micxgx.gmail.com', 'appindicatorsupport@rgcjonas.gmail.com']

[org/gnome/shell/extensions/dash-to-dock]
dash-max-icon-size=48
dock-position='BOTTOM'
dock-fixed=true
extend-height=false
transparency-mode='DYNAMIC'
background-opacity=0.6
custom-theme-shrink=true

[org/gnome/shell/extensions/user-theme]
name='Adwaita-dark'
DCONFEOF

# Lock dark mode
mkdir -p "${SYSROOT}/etc/dconf/db/local.d/locks"
cat > "${SYSROOT}/etc/dconf/db/local.d/locks/01-bruceos" << 'LOCKEOF'
/org/gnome/desktop/interface/color-scheme
/org/gnome/desktop/interface/gtk-theme
LOCKEOF

# Compile dconf
chroot "${SYSROOT}" dconf update || true

# Flatpak dark mode
chroot "${SYSROOT}" flatpak override --env=GTK_THEME=Adwaita:dark 2>/dev/null || true

echo "=== BruceOS Pi GNOME desktop configured ==="
%end
