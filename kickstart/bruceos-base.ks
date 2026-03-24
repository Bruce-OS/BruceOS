# BruceOS Base Kickstart — Fedora 43
# "They call me Bruce."
#
# Architecture: ALL packages in repo + %packages (anaconda has network).
# %post is config-only (no network). Flatpak apps install at first boot.

#--------------------------------------
# Installation settings
#--------------------------------------
lang en_US.UTF-8
keyboard us
timezone UTC --utc
selinux --enforcing
firewall --enabled --service=ssh
network --bootproto=dhcp --activate --hostname=bruceos

#--------------------------------------
# Disk layout
#--------------------------------------
zerombr
clearpart --all --initlabel
part / --fstype=ext4 --size=20480 --label=BruceOS

#--------------------------------------
# Bootloader
#--------------------------------------
bootloader --timeout=0 --append="quiet splash rd.live.overlay.size=8192"

#--------------------------------------
# Root password (disabled for live image)
#--------------------------------------
rootpw --lock

#--------------------------------------
# Live user — auto-login to GNOME
#--------------------------------------
user --name=liveuser --groups=wheel --password=liveuser --plaintext

#--------------------------------------
# Repos — ALL repos declared here so anaconda can fetch packages
#--------------------------------------
# Fedora 43
url --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-43&arch=x86_64
repo --name=updates --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f43&arch=x86_64

# RPM Fusion (declared as repos, NOT installed via dnf in %post)
repo --name=rpmfusion-free --mirrorlist=https://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-43&arch=x86_64
repo --name=rpmfusion-nonfree --mirrorlist=https://mirrors.rpmfusion.org/mirrorlist?repo=nonfree-fedora-43&arch=x86_64

# COPR repos (direct baseurl, install=0 skips GPG, cost=100 for priority)
repo --name=copr-cachyos --baseurl=https://download.copr.fedorainfracloud.org/results/bieszczaders/kernel-cachyos/fedora-43-x86_64/ --install --cost=100
repo --name=copr-starship --baseurl=https://download.copr.fedorainfracloud.org/results/atim/starship/fedora-43-x86_64/ --install --cost=100
repo --name=copr-lazygit --baseurl=https://download.copr.fedorainfracloud.org/results/atim/lazygit/fedora-43-x86_64/ --install --cost=100
repo --name=copr-zellij --baseurl=https://download.copr.fedorainfracloud.org/results/varlad/zellij/fedora-43-x86_64/ --install --cost=100
repo --name=copr-kvmfr --baseurl=https://download.copr.fedorainfracloud.org/results/hikariknight/looking-glass-kvmfr/fedora-43-x86_64/ --install --cost=100

#--------------------------------------
# Packages — everything installed here (anaconda has network)
#--------------------------------------
%packages
# Base GNOME desktop
@base-x
@gnome-desktop
@hardware-support
@multimedia
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
-gnome-terminal
-gnome-console
-gnome-tour
-gnome-initial-setup

# GNOME extensions
gnome-shell-extension-dash-to-dock
gnome-shell-extension-appindicator

# VM clipboard support
spice-vdagent

# Plymouth
plymouth
plymouth-scripts
plymouth-theme-spinner

# Fonts
google-noto-sans-fonts
google-noto-serif-fonts
google-noto-sans-mono-fonts
jetbrains-mono-fonts-all
cascadia-code-fonts

# CachyOS BORE kernel (from COPR repo above)
kernel-cachyos
-kernel
-kernel-core
-kernel-modules
-kernel-modules-core
-kernel-modules-extra

# Terminal stack (ghostty installed in %post --nochroot due to ncurses-term conflict)
fish
starship
atuin
zellij
lazygit
bat
fzf
zoxide
ripgrep
btop
fastfetch
# eza and yazi: not in any repo, downloaded as binaries in build.sh

# RPM Fusion (from repos above)
rpmfusion-free-release
rpmfusion-nonfree-release

# NVIDIA drivers (installed for everyone, only loads on NVIDIA hardware)
akmod-nvidia
xorg-x11-drv-nvidia
xorg-x11-drv-nvidia-cuda

# Virtualization + GPU passthrough (VFIO)
@virtualization
virt-manager
libvirt-daemon-kvm
qemu-kvm
virt-install
edk2-ovmf
dnsmasq

# Looking Glass KVMFR kernel module (from COPR)
akmod-kvmfr

# WinApps dependencies (Windows app integration via RDP)
freerdp
dialog
gstreamer1-plugins-bad-free
gstreamer1-plugins-ugly
gstreamer1-plugin-openh264
ffmpeg

# ZRAM
zram-generator

# Core system tools
git
curl
wget
unzip
p7zip
flatpak
podman
distrobox
firewalld
NetworkManager

# Node.js (needed for pi coding agent, installed at first boot)
nodejs
npm

# Calamares installer (replaces Anaconda for installed system setup)
calamares
calamares-libs
squashfs-tools

# Live ISO / bootloader support
dracut-live
grub2-pc
grub2-pc-modules
grub2-efi-x64
grub2-efi-x64-modules
grub2-efi-x64-cdboot
shim-x64
syslinux
syslinux-nonlinux

# Firmware
linux-firmware
iwlwifi-*-firmware

%end

#--------------------------------------
# Post-install — LOCAL CONFIG ONLY (no network in %post)
#--------------------------------------
%post --log=/root/bruceos-post.log
#!/bin/bash
# NO set -e — errors must not abort the entire post-install
set -uo pipefail

echo "=== BruceOS post-install starting ==="

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

# Polkit rule so liveuser can launch Calamares without password prompt
mkdir -p /etc/polkit-1/rules.d
cat > /etc/polkit-1/rules.d/49-bruceos-calamares.rules << 'POLKITEOF'
polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.policykit.exec" &&
        action.lookup("program") == "/usr/bin/calamares" &&
        subject.isInGroup("wheel")) {
        return polkit.Result.YES;
    }
});
POLKITEOF

#--- Calamares launcher wrapper (runs as root with Wayland display access) ---
# GNOME Shell has a built-in polkit agent, no separate package needed
cat > /usr/local/bin/bruceos-install << 'INSTALLEOF'
#!/bin/bash
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-0}
# Disable os-prober at runtime (causes partition module hang)
sudo chmod -x /usr/bin/os-prober 2>/dev/null
sudo -E /usr/bin/calamares "$@"
# Re-enable after
sudo chmod +x /usr/bin/os-prober 2>/dev/null
INSTALLEOF
chmod +x /usr/local/bin/bruceos-install

#--- Set Fish as default shell ---
chsh -s /usr/bin/fish root || echo "WARN: chsh root failed"
chsh -s /usr/bin/fish liveuser || echo "WARN: chsh liveuser failed"

#--- Fix liveuser home directory ownership ---
mkdir -p /home/liveuser/.local/share
mkdir -p /home/liveuser/.config/fish
chown -R liveuser:liveuser /home/liveuser || echo "WARN: chown liveuser failed"
sed -i 's|^SHELL=.*|SHELL=/usr/bin/fish|' /etc/default/useradd 2>/dev/null || true

#--- Ghostty config ---
mkdir -p /etc/ghostty
cat > /etc/ghostty/config << 'GHOSTTYEOF'
font-family = JetBrains Mono
font-size = 13
theme = catppuccin-mocha
shell-integration = fish
gtk-single-instance = true
quit-after-last-window-closed = false
keybind = ctrl+grave_accent=toggle_quick_terminal
GHOSTTYEOF

#--- Fish config ---
mkdir -p /etc/fish/conf.d
cat > /etc/fish/conf.d/bruce.fish << 'FISHEOF'
# BruceOS default Fish configuration
starship init fish | source
atuin init fish | source
zoxide init fish | source

# Aliases
alias ls="eza --icons"
alias ll="eza -la --icons"
alias cat="bat --paging=never"
alias tree="eza --tree --icons"

# Pi coding agent (npm global binary)
if command -q pi
    function pi --wraps='pi' --description 'Pi AI coding agent'
        command pi $argv
    end
end

# Show BruceOS info on first shell in terminal
if status is-interactive; and not set -q BRUCE_GREETED
    set -g BRUCE_GREETED 1
    fastfetch --config /etc/fastfetch/config.jsonc 2>/dev/null
end
FISHEOF

#--- Starship config ---
mkdir -p /etc/xdg
cat > /etc/xdg/starship.toml << 'STARSHIPEOF'
# BruceOS Starship Prompt
format = """
$directory\
$git_branch\
$git_status\
$character"""

[directory]
truncation_length = 3
truncation_symbol = ".../"

[git_branch]
symbol = " "

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
STARSHIPEOF

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

#--- Performance tuning ---
cat > /etc/sysctl.d/99-bruceos.conf << 'SYSCTLEOF'
# BruceOS performance tuning
vm.max_map_count = 1048576
vm.swappiness = 10
SYSCTLEOF

#--- ZRAM swap ---
cat > /etc/systemd/zram-generator.conf << 'ZRAMEOF'
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
ZRAMEOF

#--- VFIO / GPU passthrough ---
# Dracut: force-load VFIO modules into initramfs
cat > /etc/dracut.conf.d/10-vfio.conf << 'DRACUTEOF'
force_drivers+=" vfio vfio_iommu_type1 vfio_pci "
DRACUTEOF

# Modprobe: ensure vfio-pci loads before GPU drivers
cat > /etc/modprobe.d/vfio.conf << 'MODEOF'
softdep nvidia pre: vfio-pci
softdep nouveau pre: vfio-pci
softdep amdgpu pre: vfio-pci
MODEOF

# Modules to load at boot
cat > /etc/modules-load.d/vfio.conf << 'VFIOEOF'
vfio-pci
vfio_iommu_type1
VFIOEOF

# Looking Glass shared memory (32MB default, covers 1080p)
cat > /etc/tmpfiles.d/10-looking-glass.conf << 'LGEOF'
f /dev/shm/looking-glass 0660 root kvm -
LGEOF

# Auto-detect CPU vendor and set IOMMU — applied at first boot or by bruce-setup
cat > /usr/local/bin/bruce-vfio-setup << 'VFIOSETUPEOF'
#!/bin/bash
# BruceOS VFIO setup — auto-detect CPU and configure IOMMU
set -euo pipefail

CPU_VENDOR=$(grep -m1 'vendor_id' /proc/cpuinfo | awk '{print $3}')

if [ "$CPU_VENDOR" = "GenuineIntel" ]; then
    IOMMU_PARAM="intel_iommu=on"
elif [ "$CPU_VENDOR" = "AuthenticAMD" ]; then
    IOMMU_PARAM="amd_iommu=on"
else
    echo "Unknown CPU vendor: $CPU_VENDOR"
    exit 1
fi

VFIO_PARAMS="$IOMMU_PARAM iommu=pt rd.driver.pre=vfio-pci vfio_pci.disable_vga=1"

echo "Detected: $CPU_VENDOR"
echo "Applying kernel args: $VFIO_PARAMS"
grubby --update-kernel=ALL --args="$VFIO_PARAMS"

echo "Rebuilding initramfs..."
dracut -f --kver "$(uname -r)"

echo "VFIO configured. Reboot to apply."
echo ""
echo "Next steps:"
echo "  1. Run 'bruce-vfio-list' to see IOMMU groups"
echo "  2. Run 'bruce-vfio-bind <PCI_ID>' to bind a GPU to vfio-pci"
VFIOSETUPEOF
chmod +x /usr/local/bin/bruce-vfio-setup

# IOMMU groups listing tool
cat > /usr/local/bin/bruce-vfio-list << 'VFIOLISTEOF'
#!/bin/bash
# List IOMMU groups and their devices
shopt -s nullglob
for g in $(find /sys/kernel/iommu_groups/* -maxdepth 0 -type d 2>/dev/null | sort -V); do
    echo "IOMMU Group ${g##*/}:"
    for d in $g/devices/*; do
        echo -e "\t$(lspci -nns ${d##*/})"
    done
done
if [ ! -d /sys/kernel/iommu_groups/0 ]; then
    echo "No IOMMU groups found. Run 'sudo bruce-vfio-setup' first and reboot."
fi
VFIOLISTEOF
chmod +x /usr/local/bin/bruce-vfio-list

# GPU bind tool
cat > /usr/local/bin/bruce-vfio-bind << 'VFIOBINDEOF'
#!/bin/bash
# Bind a GPU to vfio-pci for passthrough
# Usage: bruce-vfio-bind 10de:1234,10de:5678
if [ -z "${1:-}" ]; then
    echo "Usage: bruce-vfio-bind <vendor:device>[,vendor:device,...]"
    echo "Example: bruce-vfio-bind 10de:2204,10de:1aef"
    echo ""
    echo "Find your GPU PCI IDs with: bruce-vfio-list"
    exit 1
fi

echo "options vfio-pci ids=$1" >> /etc/modprobe.d/vfio.conf
grubby --update-kernel=ALL --args="vfio-pci.ids=$1"
dracut -f --kver "$(uname -r)"
echo "GPU $1 will be bound to vfio-pci on next reboot."
VFIOBINDEOF
chmod +x /usr/local/bin/bruce-vfio-bind

# Libvirt hooks for single-GPU passthrough
mkdir -p /etc/libvirt/hooks/qemu.d
cat > /etc/libvirt/hooks/qemu << 'HOOKEOF'
#!/bin/bash
GUEST_NAME="$1"
HOOK_NAME="$2"
STATE_NAME="$3"
BASEDIR="$(dirname $0)"
HOOKPATH="$BASEDIR/qemu.d/$GUEST_NAME/$HOOK_NAME/$STATE_NAME"
set -e
if [ -f "$HOOKPATH" ]; then
    eval "\"$HOOKPATH\"" "$@"
elif [ -d "$HOOKPATH" ]; then
    while read file; do
        eval "\"$file\"" "$@"
    done <<< "$(find -L "$HOOKPATH" -maxdepth 1 -type f -executable -print;)"
fi
HOOKEOF
chmod +x /etc/libvirt/hooks/qemu

# Enable libvirtd + default network
systemctl enable libvirtd || true

#--- Plymouth ---
plymouth-set-default-theme spinner || true

#--- Set CachyOS as default boot kernel ---
if rpm -q kernel-cachyos &>/dev/null; then
    CACHYOS_VER=$(rpm -q --qf '%{VERSION}-%{RELEASE}.%{ARCH}\n' kernel-cachyos | head -1)
    grubby --set-default="/boot/vmlinuz-${CACHYOS_VER}" 2>/dev/null || true
    echo "Default kernel set to CachyOS ${CACHYOS_VER}"
fi

#--- Hostname ---
hostnamectl set-hostname bruceos 2>/dev/null || echo "bruceos" > /etc/hostname

#--- Skip GNOME tour on first login ---
mkdir -p /home/liveuser/.config
touch /home/liveuser/.config/gnome-initial-setup-done
chown -R liveuser:liveuser /home/liveuser/.config 2>/dev/null || true

#--- Auto-launch Calamares installer on login ---
mkdir -p /home/liveuser/.config/autostart
cat > /home/liveuser/.config/autostart/bruceos-install.desktop << 'AUTOEOF'
[Desktop Entry]
Type=Application
Name=Install BruceOS
Exec=bruceos-install
Terminal=false
X-GNOME-Autostart-enabled=true
AUTOEOF
chown -R liveuser:liveuser /home/liveuser/.config 2>/dev/null || true

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
# BruceOS first-boot setup — runs once after first boot with network
LOG=/var/log/bruceos-first-boot.log
exec &> >(tee -a "$LOG")
echo "=== BruceOS first-boot starting at $(date) ==="

# Wait for network to actually be up
for i in $(seq 1 30); do
    if curl -sf --connect-timeout 3 https://dl.flathub.org > /dev/null 2>&1; then
        echo "Network ready"
        break
    fi
    echo "Waiting for network... ($i/30)"
    sleep 2
done

# --- Flathub + Ungoogled Chromium (default browser, called "Chrome") ---
echo "Adding Flathub..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true

echo "Installing Ungoogled Chromium..."
flatpak install -y --noninteractive flathub io.github.ungoogled_software.ungoogled_chromium || true

# Create "Chrome" desktop entry with correct WMClass to prevent dock doubling
if flatpak info io.github.ungoogled_software.ungoogled_chromium &>/dev/null; then
    # Copy the flatpak desktop file (has correct Exec with --file-forwarding)
    cp /var/lib/flatpak/exports/share/applications/io.github.ungoogled_software.ungoogled_chromium.desktop \
       /usr/share/applications/chrome.desktop
    # Rename to "Chrome" and ensure StartupWMClass matches
    sed -i '0,/^Name=/{s/^Name=.*/Name=Chrome/}' /usr/share/applications/chrome.desktop
    grep -q "^StartupWMClass=" /usr/share/applications/chrome.desktop || \
        echo "StartupWMClass=chromium-browser" >> /usr/share/applications/chrome.desktop
    echo "Chrome desktop entry created (with WMClass)"
fi

# --- DING (Desktop Icons NG) ---
echo "Installing DING extension..."
DING_UUID="ding@rastersoft.com"
DING_DEST="/usr/share/gnome-shell/extensions/${DING_UUID}"
curl -sfL "https://extensions.gnome.org/download-extension/${DING_UUID}.shell-extension.zip?shell_version=49" -o /tmp/ding.zip && \
    mkdir -p "${DING_DEST}" && \
    unzip -qo /tmp/ding.zip -d "${DING_DEST}" && \
    rm -f /tmp/ding.zip && \
    echo "DING installed" || echo "WARN: DING install failed"

# --- Pi coding agent ---
echo "Installing Pi coding agent..."
npm install -g @mariozechner/pi-coding-agent || echo "WARN: pi install failed"
npm install -g pi-zellij || echo "WARN: pi-zellij install failed"
npm install -g @codexstar/pi-listen || echo "WARN: pi-listen install failed"

echo "=== BruceOS first-boot complete at $(date) ==="
SCRIPTEOF
chmod +x /usr/libexec/bruceos-first-boot.sh
systemctl enable bruceos-first-boot.service

#--- Default browser (Ungoogled Chromium when available, Firefox fallback) ---
mkdir -p /etc/xdg
cat > /etc/xdg/mimeapps.list << 'MIMEEOF'
[Default Applications]
text/html=io.github.ungoogled_software.ungoogled_chromium.desktop
x-scheme-handler/http=io.github.ungoogled_software.ungoogled_chromium.desktop
x-scheme-handler/https=io.github.ungoogled_software.ungoogled_chromium.desktop
MIMEEOF

#--- Set system branding (MUST be last — after all dnf operations) ---
cat > /etc/os-release << 'OSEOF'
NAME="BruceOS"
VERSION="1.0"
ID=bruceos
ID_LIKE=fedora
VERSION_ID=1.0
PLATFORM_ID="platform:f43"
PRETTY_NAME="BruceOS 1.0"
ANSI_COLOR="0;38;2;16;185;129"
LOGO=bruceos
CPE_NAME="cpe:/o:bruceos:bruceos:1.0"
HOME_URL="https://bruceos.com"
SUPPORT_URL="https://github.com/Bruce-OS/BruceOS/issues"
BUG_REPORT_URL="https://github.com/Bruce-OS/BruceOS/issues"
VARIANT="Workstation"
VARIANT_ID=workstation
DOCUMENTATION_URL="https://bruceos.com/guide/getting-started"
OSEOF

echo "=== BruceOS post-install complete ==="
%end

#--------------------------------------
# Post-install — GNOME theming + assets (nochroot, access to /build/)
#--------------------------------------
%post --nochroot --log=/mnt/sysimage/root/bruceos-theme.log
#!/bin/bash
set -uo pipefail

echo "=== Configuring BruceOS GNOME desktop ==="

SYSROOT=/mnt/sysimage

#--- Staged packages from build.sh (in /tmp/bruceos-staging/) ---
STAGING=/tmp/bruceos-staging

# Ghostty (conflicts with ncurses-term, must use --replacefiles)
if ls ${STAGING}/ghostty-*.rpm 1>/dev/null 2>&1; then
    rpm --root="${SYSROOT}" -i --replacefiles ${STAGING}/ghostty-*.rpm && \
        echo "Ghostty installed" || echo "WARN: Ghostty rpm install failed"
fi

# eza + yazi + looking-glass-client binaries
mkdir -p "${SYSROOT}/usr/local/bin"
if [ -f "${STAGING}/looking-glass-client" ]; then
    cp "${STAGING}/looking-glass-client" "${SYSROOT}/usr/local/bin/looking-glass-client"
    chmod +x "${SYSROOT}/usr/local/bin/looking-glass-client"
    echo "Looking Glass client installed"
fi
for bin in eza yazi; do
    if [ -f "${STAGING}/${bin}" ]; then
        cp "${STAGING}/${bin}" "${SYSROOT}/usr/local/bin/${bin}"
        chmod +x "${SYSROOT}/usr/local/bin/${bin}"
        echo "${bin} installed"
    fi
done

# DING extension is installed at first boot (needs network)

#--- BruceOS icon theme (Adwaita-green with emerald accents) ---
if [ -d /build/theme/icons-bruceos ]; then
    cp -r /build/theme/icons-bruceos "${SYSROOT}/usr/share/icons/BruceOS"
    chroot "${SYSROOT}" gtk-update-icon-cache /usr/share/icons/BruceOS 2>/dev/null || true
    echo "BruceOS icon theme installed"
fi

#--- BruceOS wallpaper ---
if [ -f /build/theme/wallpaper.png ]; then
    mkdir -p "${SYSROOT}/usr/share/backgrounds/bruceos"
    cp /build/theme/wallpaper.png "${SYSROOT}/usr/share/backgrounds/bruceos/wallpaper.png"
elif [ -f /build/theme/wallpaper.svg ]; then
    # Generate from SVG if rsvg-convert available
    if command -v rsvg-convert &>/dev/null; then
        mkdir -p "${SYSROOT}/usr/share/backgrounds/bruceos"
        rsvg-convert -w 3840 -h 2160 /build/theme/wallpaper.svg -o "${SYSROOT}/usr/share/backgrounds/bruceos/wallpaper.png"
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
    rsvg-convert -w 128 -h 128 "$LOGO" -o "${SYSROOT}/usr/share/pixmaps/bruceos-logo.png" 2>/dev/null || true
    cp "$LOGO" "${SYSROOT}/usr/share/pixmaps/fedora-logo-sprite.svg" 2>/dev/null || true
fi

#--- Ghostty icon — use standard terminal icon ---
if [ -f "${SYSROOT}/usr/share/applications/com.mitchellh.ghostty.desktop" ]; then
    sed -i 's|^Icon=.*|Icon=utilities-terminal-symbolic|' "${SYSROOT}/usr/share/applications/com.mitchellh.ghostty.desktop"
fi

#--- GNOME dconf defaults ---
mkdir -p "${SYSROOT}/etc/dconf/db/local.d"
cat > "${SYSROOT}/etc/dconf/db/local.d/01-bruceos" << 'DCONFEOF'
[org/gnome/desktop/interface]
gtk-theme='Adwaita-dark'
icon-theme='BruceOS'
cursor-theme='Adwaita'
font-name='Noto Sans 11'
document-font-name='Noto Sans 11'
monospace-font-name='JetBrains Mono 13'
color-scheme='prefer-dark'

[org/gnome/desktop/wm/preferences]
titlebar-font='Noto Sans Bold 11'
button-layout=':minimize,maximize,close'

[org/gnome/desktop/background]
picture-uri='file:///usr/share/backgrounds/bruceos/wallpaper.png'
picture-uri-dark='file:///usr/share/backgrounds/bruceos/wallpaper.png'
picture-options='zoom'

[org/gnome/desktop/screensaver]
picture-uri='file:///usr/share/backgrounds/bruceos/wallpaper.png'

[org/gnome/shell]
favorite-apps=['install-bruceos.desktop']
enabled-extensions=['dash-to-dock@micxgx.gmail.com', 'appindicatorsupport@rgcjonas.gmail.com', 'ding@rastersoft.com']


[org/gnome/shell/extensions/dash-to-dock]
dash-max-icon-size=48
dock-position='BOTTOM'
dock-fixed=true
extend-height=false
transparency-mode='DYNAMIC'
background-opacity=0.6
custom-theme-shrink=true
show-trash=false
show-mounts=false
show-show-apps-button=false
show-running=false

[org/gnome/shell/extensions/user-theme]
name='Adwaita-dark'

[org/gnome/software]
allow-updates=false
download-updates=false
download-updates-notify=false
first-run=false
show-nags=false
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

#--- Calamares installer branding + config ---
echo "=== Configuring Calamares installer ==="

# Install Calamares settings.conf
mkdir -p "${SYSROOT}/etc/calamares"
cp /build/installer/settings.conf "${SYSROOT}/etc/calamares/settings.conf"

# Install Calamares module configs
mkdir -p "${SYSROOT}/etc/calamares/modules"
for conf in /build/installer/modules/*.conf; do
    [ -f "$conf" ] && cp "$conf" "${SYSROOT}/etc/calamares/modules/"
done

# Remove default shellprocess.conf (has example "slowloris" command that crashes install)
rm -f "${SYSROOT}/usr/share/calamares/modules/shellprocess.conf"

# Remove default Calamares desktop entry (we use our own branded one)
rm -f "${SYSROOT}/usr/share/applications/calamares.desktop"

# Install BruceOS branding
BRANDING_DEST="${SYSROOT}/usr/share/calamares/branding/bruceos"
mkdir -p "${BRANDING_DEST}"
cp /build/installer/branding/bruceos/branding.desc "${BRANDING_DEST}/"
cp /build/installer/branding/bruceos/show.qml "${BRANDING_DEST}/"
cp /build/installer/branding/bruceos/stylesheet.qss "${BRANDING_DEST}/"

# Copy logo into branding directory
if [ -f /build/theme/bruceos-logo.svg ]; then
    cp /build/theme/bruceos-logo.svg "${BRANDING_DEST}/bruceos-logo.svg"
fi

# Generate a welcome image from the logo if rsvg-convert is available
if [ -f /build/theme/bruceos-logo.svg ] && command -v rsvg-convert &>/dev/null; then
    rsvg-convert -w 480 -h 480 /build/theme/bruceos-logo.svg \
        -o "${BRANDING_DEST}/bruceos-welcome.png" 2>/dev/null || true
fi

# "Install BruceOS" desktop shortcut — on the live desktop and in applications
cp /build/installer/install-bruceos.desktop "${SYSROOT}/usr/share/applications/install-bruceos.desktop"

# Copy to liveuser desktop so it appears as an icon on the desktop
mkdir -p "${SYSROOT}/home/liveuser/Desktop"
cp /build/installer/install-bruceos.desktop "${SYSROOT}/home/liveuser/Desktop/install-bruceos.desktop"
chmod +x "${SYSROOT}/home/liveuser/Desktop/install-bruceos.desktop"
chroot "${SYSROOT}" chown -R liveuser:liveuser /home/liveuser/Desktop 2>/dev/null || true

# Trust the desktop file so GNOME does not show "untrusted" warning
mkdir -p "${SYSROOT}/home/liveuser/.local/share"
chroot "${SYSROOT}" bash -c 'dbus-launch gio set /home/liveuser/Desktop/install-bruceos.desktop metadata::trusted true 2>/dev/null' || true

# Add Calamares icon (reuse the BruceOS logo)
if [ -f /build/theme/bruceos-logo.svg ]; then
    cp /build/theme/bruceos-logo.svg "${SYSROOT}/usr/share/pixmaps/bruceos-logo.svg"
    if command -v rsvg-convert &>/dev/null; then
        rsvg-convert -w 256 -h 256 /build/theme/bruceos-logo.svg \
            -o "${SYSROOT}/usr/share/pixmaps/bruceos-logo.png" 2>/dev/null || true
    fi
fi

# Polkit rule: allow liveuser to run Calamares without password prompt
mkdir -p "${SYSROOT}/etc/polkit-1/rules.d"
cat > "${SYSROOT}/etc/polkit-1/rules.d/49-bruceos-live-installer.rules" << 'POLKITEOF'
// Allow liveuser to run Calamares without authentication
polkit.addRule(function(action, subject) {
    if (subject.user == "liveuser" && action.id == "org.freedesktop.policykit.exec") {
        return polkit.Result.YES;
    }
});
POLKITEOF

echo "=== Calamares installer configured ==="

echo "=== BruceOS GNOME desktop configured ==="
%end
