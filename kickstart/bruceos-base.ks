# BruceOS Base Kickstart — Fedora 43
# "Linux. But it's called Bruce."
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
network --bootproto=dhcp --activate

#--------------------------------------
# Disk layout
#--------------------------------------
zerombr
clearpart --all --initlabel
part / --fstype=ext4 --size=8192

#--------------------------------------
# Bootloader
#--------------------------------------
bootloader --timeout=5 --append="quiet splash"

#--------------------------------------
# Root password (disabled for live image)
#--------------------------------------
rootpw --lock

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
gnome-terminal
gnome-tweaks
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

# Live ISO support
dracut-live

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

#--- Terminal tools from COPR (not in base Fedora repos) ---
dnf copr enable -y atim/starship
dnf copr enable -y atim/lazygit
dnf copr enable -y pgdev/ghostty
dnf install -y ghostty starship eza lazygit yazi zellij || {
    echo "WARN: Some terminal tools failed to install from COPR"
    # Install what we can individually
    for pkg in ghostty starship eza lazygit yazi zellij; do
        dnf install -y "$pkg" || echo "WARN: $pkg not available"
    done
}

#--- RPM Fusion repos (for multimedia codecs, NVIDIA drivers) ---
dnf install -y \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-43.noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-43.noarch.rpm || true

#--- Multimedia codecs ---
dnf install -y gstreamer1-plugins-bad-free gstreamer1-plugins-ugly \
  gstreamer1-plugin-openh264 ffmpeg || true

#--- Flathub for optional user apps ---
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true

#--- Set Fish as default shell for new users ---
chsh -s /usr/bin/fish

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
FISHEOF

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
# Post-install — WhiteSur theme (needs network, best-effort)
# NOTE: This step is skipped during offline install.
#--------------------------------------
%post --nochroot --log=/mnt/sysimage/root/bruceos-theme.log
#!/bin/bash
set -uo pipefail

echo "=== Installing WhiteSur theme ==="

# Check for network — skip gracefully if offline
if ! curl -s --connect-timeout 5 https://github.com > /dev/null 2>&1; then
    echo "WARN: No network available — skipping WhiteSur theme download"
    echo "Theme can be installed later via bruce-setup"
    exit 0
fi

# Clone WhiteSur GTK theme into the installed system
SYSROOT=/mnt/sysimage
THEME_DIR="${SYSROOT}/usr/share/themes"
ICON_DIR="${SYSROOT}/usr/share/icons"

# Download WhiteSur theme
cd /tmp
git clone --depth=1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git || true
if [ -d WhiteSur-gtk-theme ]; then
    cd WhiteSur-gtk-theme
    mkdir -p "${THEME_DIR}"
    ./install.sh -d "${THEME_DIR}" -c Dark -t default || true
    cd /tmp
fi

# Download WhiteSur icon theme
git clone --depth=1 https://github.com/vinceliuice/WhiteSur-icon-theme.git || true
if [ -d WhiteSur-icon-theme ]; then
    cd WhiteSur-icon-theme
    mkdir -p "${ICON_DIR}"
    ./install.sh -d "${ICON_DIR}" || true
fi

#--- Set GNOME defaults via dconf ---
mkdir -p "${SYSROOT}/etc/dconf/db/local.d"
cat > "${SYSROOT}/etc/dconf/db/local.d/01-bruceos" << 'DCONFEOF'
[org/gnome/desktop/interface]
gtk-theme='WhiteSur-Dark'
icon-theme='WhiteSur-dark'
cursor-theme='Adwaita'
font-name='Noto Sans 11'
document-font-name='Noto Sans 11'
monospace-font-name='JetBrains Mono 13'
color-scheme='prefer-dark'

[org/gnome/desktop/wm/preferences]
titlebar-font='Noto Sans Bold 11'
button-layout='close,minimize,maximize:'

[org/gnome/shell]
favorite-apps=['org.gnome.Nautilus.desktop', 'ghostty.desktop', 'firefox.desktop', 'org.gnome.Software.desktop']
enabled-extensions=['dash-to-dock@micxgx.gmail.com', 'appindicatorsupport@rgcjonas.gmail.com']

[org/gnome/shell/extensions/dash-to-dock]
dash-max-icon-size=48
dock-position='BOTTOM'
dock-fixed=true
extend-height=false
transparency-mode='DYNAMIC'
DCONFEOF

# Compile dconf database
chroot "${SYSROOT}" dconf update || true

echo "=== WhiteSur theme install complete ==="
%end
