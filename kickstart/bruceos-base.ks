# BruceOS Base Kickstart — Fedora 43
# "They call me Bruce."
#
# Build: livemedia-creator --ks bruceos-base.ks --no-virt --resultdir /output
# Target: x86_64 live ISO with GNOME + WhiteSur

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
part / --fstype=ext4 --size=12288

#--------------------------------------
# Bootloader
#--------------------------------------
bootloader --timeout=5 --append="quiet splash"

#--------------------------------------
# Root password (disabled for live image)
#--------------------------------------
rootpw --lock

#--------------------------------------
# Live user — auto-login to GNOME
#--------------------------------------
user --name=liveuser --groups=wheel --password=liveuser --plaintext

#--------------------------------------
# Repos
#--------------------------------------
# Fedora 43 base repos (inherited from install media)
url --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-43&arch=x86_64
repo --name=updates --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f43&arch=x86_64
repo --name=rpmfusion-free --mirrorlist=https://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-43&arch=x86_64
repo --name=rpmfusion-nonfree --mirrorlist=https://mirrors.rpmfusion.org/mirrorlist?repo=nonfree-fedora-43&arch=x86_64

#--------------------------------------
# Packages — Core desktop
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
-gnome-terminal
-gnome-console
gnome-software
nautilus
evince
eog
gnome-calculator
gnome-text-editor
gnome-system-monitor

# GNOME extensions (approved list — see RULES.md)
gnome-shell-extension-dash-to-dock
gnome-shell-extension-appindicator

# VM clipboard support
spice-vdagent

# Plymouth boot splash
plymouth
plymouth-scripts
plymouth-theme-spinner

# Fonts
google-noto-sans-fonts
google-noto-serif-fonts
google-noto-sans-mono-fonts
jetbrains-mono-fonts-all
cascadia-code-fonts

# Terminal stack (packages in Fedora repos)
fish
atuin
bat
fzf
zoxide
ripgrep
btop
fastfetch
# ghostty, starship, eza, yazi, zellij, lazygit installed via COPR in %post

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
# Post-install — system configuration
#--------------------------------------
%post --log=/root/bruceos-post.log
#!/bin/bash
set -euo pipefail

echo "=== BruceOS post-install starting ==="

#--- Set graphical target and auto-login for live session ---
systemctl set-default graphical.target

# GDM auto-login for live user
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

# Give liveuser passwordless sudo
echo "liveuser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/liveuser
chmod 440 /etc/sudoers.d/liveuser

#--- CachyOS BORE kernel from COPR ---
cat > /etc/yum.repos.d/cachyos-kernel.repo << 'REPOEOF'
[copr:copr.fedorainfracloud.org:bieszczaders:kernel-cachyos]
name=CachyOS Kernel for Fedora
baseurl=https://download.copr.fedorainfracloud.org/results/bieszczaders/kernel-cachyos/fedora-43-x86_64/
type=rpm-md
skip_if_unavailable=True
gpgcheck=1
gpgkey=https://download.copr.fedorainfracloud.org/results/bieszczaders/kernel-cachyos/pubkey.gpg
repo_gpgcheck=0
enabled=1
enabled_metadata=1
REPOEOF

dnf install -y kernel-cachyos kernel-cachyos-devel-matched || {
    echo "WARN: CachyOS kernel install failed, falling back to default kernel"
    dnf install -y kernel kernel-core kernel-modules
}

#--- Terminal tools from COPR ---
# Use explicit fedora-43-x86_64 chroot because os-release says "bruceos"
dnf copr enable -y pgdev/ghostty fedora-43-x86_64
dnf copr enable -y atim/starship fedora-43-x86_64
dnf copr enable -y atim/lazygit fedora-43-x86_64
dnf copr enable -y varlad/zellij fedora-43-x86_64

# Install COPR packages individually (one failure shouldn't block others)
for pkg in starship lazygit zellij; do
    dnf install -y "$pkg" || echo "WARN: $pkg not available"
done

# Ghostty conflicts with ncurses-term on terminfo — force replace
dnf download -y ghostty && rpm -i --replacefiles ghostty-*.rpm && rm -f ghostty-*.rpm || echo "WARN: ghostty not available"

#--- Binary installs (not in Fedora or COPR) ---
# eza — prebuilt binary from GitHub
curl -sL https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz | tar xz -C /usr/local/bin/ || echo "WARN: eza download failed"

# yazi — prebuilt binary from GitHub
curl -sL https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip -o /tmp/yazi.zip && \
    unzip -o /tmp/yazi.zip -d /tmp/yazi && \
    cp /tmp/yazi/yazi-x86_64-unknown-linux-gnu/yazi /usr/local/bin/ && \
    chmod +x /usr/local/bin/yazi && \
    rm -rf /tmp/yazi /tmp/yazi.zip || echo "WARN: yazi download failed"

#--- RPM Fusion repos (for multimedia codecs, NVIDIA drivers) ---
dnf install -y \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-43.noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-43.noarch.rpm || true

#--- Multimedia codecs ---
dnf install -y gstreamer1-plugins-bad-free gstreamer1-plugins-ugly \
  gstreamer1-plugin-openh264 ffmpeg || true

#--- Flathub for optional user apps ---
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true

#--- Set Fish as default shell ---
chsh -s /usr/bin/fish root
chsh -s /usr/bin/fish liveuser
# Set Fish as default for any future users
sed -i 's|^SHELL=.*|SHELL=/usr/bin/fish|' /etc/default/useradd 2>/dev/null || true

#--- Install system-wide Ghostty config ---
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

#--- Install system-wide Fish config ---
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

# Show BruceOS info on first shell in terminal
if status is-interactive; and not set -q BRUCE_GREETED
    set -g BRUCE_GREETED 1
    fastfetch --config /etc/fastfetch/config.jsonc 2>/dev/null
end
FISHEOF

#--- Fastfetch BruceOS branding ---
mkdir -p /etc/fastfetch
cat > /etc/fastfetch/logo.txt << 'FFLOGOEOF'
${c1}         ██████████
        ████████████
       ██████  ██████
       █████    █████
       █████  ██████
       ██████████████
       █████  ██████
       █████    █████
       █████  ██████
       ██████████████
        ████████████
         ██████████
FFLOGOEOF

cat > /etc/fastfetch/config.jsonc << 'FFCONFEOF'
{
  "logo": {
    "source": "/etc/fastfetch/logo.txt",
    "type": "raw",
    "color": { "1": "green" }
  },
  "modules": [
    "title", "separator",
    "os", "kernel", "uptime", "packages",
    "shell", "terminal", "cpu", "gpu",
    "memory", "disk", "break", "colors"
  ]
}
FFCONFEOF

#--- Install system-wide Starship config ---
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

#--- Plymouth BruceOS theme ---
if [ -d /build/theme/plymouth/bruceos ]; then
    mkdir -p /usr/share/plymouth/themes/bruceos
    cp /build/theme/plymouth/bruceos/* /usr/share/plymouth/themes/bruceos/
    plymouth-set-default-theme bruceos || true
else
    plymouth-set-default-theme spinner || true
fi

#--- BruceOS wallpaper ---
if [ -f /build/theme/wallpaper.png ]; then
    mkdir -p /usr/share/backgrounds/bruceos
    cp /build/theme/wallpaper.png /usr/share/backgrounds/bruceos/wallpaper.png
fi

#--- White-label: replace Fedora logos with BruceOS ---
if [ -d /build/theme/branding ]; then
    for logo in /build/theme/branding/*.png /build/theme/branding/*.svg; do
        [ -f "$logo" ] || continue
        fname=$(basename "$logo")
        # Replace in pixmaps
        [ -f "/usr/share/pixmaps/$fname" ] && cp -f "$logo" "/usr/share/pixmaps/$fname"
        # Replace in fedora-logos
        [ -f "/usr/share/fedora-logos/$fname" ] && cp -f "$logo" "/usr/share/fedora-logos/$fname"
    done
fi

#--- GPU auto-detection ---
# Detect GPU and install appropriate drivers
if lspci | grep -qi nvidia; then
    dnf install -y akmod-nvidia xorg-x11-drv-nvidia || true
    echo "NVIDIA GPU detected — proprietary drivers installed"
elif lspci | grep -qi "amd.*radeon\|amd.*graphics"; then
    # AMD uses kernel amdgpu driver (already included)
    echo "AMD GPU detected — using kernel amdgpu driver"
elif lspci | grep -qi "intel.*graphics\|intel.*uhd\|intel.*iris"; then
    # Intel uses kernel i915 driver (already included)
    echo "Intel GPU detected — using kernel i915 driver"
fi

#--- Performance tuning ---
# vm.max_map_count for gaming and large applications
cat > /etc/sysctl.d/99-bruceos.conf << 'SYSCTLEOF'
# BruceOS performance tuning
vm.max_map_count = 1048576
vm.swappiness = 10
SYSCTLEOF

#--- ZRAM swap ---
dnf install -y zram-generator || true
cat > /etc/systemd/zram-generator.conf << 'ZRAMEOF'
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
ZRAMEOF

#--- Set system branding ---
cat > /etc/os-release << 'OSEOF'
NAME="BruceOS"
VERSION="1.0"
ID=bruceos
ID_LIKE=fedora
VERSION_ID=1.0
PLATFORM_ID="platform:f43"
PRETTY_NAME="BruceOS 1.0"
ANSI_COLOR="0;34"
LOGO=bruceos
CPE_NAME="cpe:/o:bruceos:bruceos:1.0"
HOME_URL="https://bruceos.com"
SUPPORT_URL="https://github.com/Bruce-OS/BruceOS/issues"
BUG_REPORT_URL="https://github.com/Bruce-OS/BruceOS/issues"
VARIANT="Workstation"
VARIANT_ID=workstation
DOCUMENTATION_URL="https://github.com/Bruce-OS/BruceOS"
OSEOF

echo "=== BruceOS post-install complete ==="
%end

#--------------------------------------
# Post-install — GNOME desktop theming (no network required)
#--------------------------------------
%post --nochroot --log=/mnt/sysimage/root/bruceos-theme.log
#!/bin/bash
set -uo pipefail

echo "=== Configuring BruceOS GNOME desktop ==="

SYSROOT=/mnt/sysimage

#--- Set GNOME defaults via dconf ---
mkdir -p "${SYSROOT}/etc/dconf/db/local.d"
cat > "${SYSROOT}/etc/dconf/db/local.d/01-bruceos" << 'DCONFEOF'
[org/gnome/desktop/interface]
gtk-theme='Adwaita-dark'
icon-theme='Adwaita'
cursor-theme='Adwaita'
font-name='Noto Sans 11'
document-font-name='Noto Sans 11'
monospace-font-name='JetBrains Mono 13'
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
favorite-apps=['org.gnome.Nautilus.desktop', 'ghostty.desktop', 'firefox.desktop', 'org.gnome.Software.desktop']
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

# Lock dark mode so it can't be accidentally toggled
mkdir -p "${SYSROOT}/etc/dconf/db/local.d/locks"
cat > "${SYSROOT}/etc/dconf/db/local.d/locks/01-bruceos" << 'LOCKEOF'
/org/gnome/desktop/interface/color-scheme
/org/gnome/desktop/interface/gtk-theme
LOCKEOF

# Compile dconf database
chroot "${SYSROOT}" dconf update || true

# Flatpak dark mode
chroot "${SYSROOT}" flatpak override --env=GTK_THEME=Adwaita:dark 2>/dev/null || true

echo "=== BruceOS GNOME desktop configured ==="
%end
