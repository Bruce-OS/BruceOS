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
part / --fstype=ext4 --size=16384 --label=BruceOS

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

# RPM Fusion codecs (from repos above)
rpmfusion-free-release
rpmfusion-nonfree-release
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
set -euo pipefail

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

#--- Set Fish as default shell ---
chsh -s /usr/bin/fish root
chsh -s /usr/bin/fish liveuser
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
# BruceOS first-boot: add Flathub and install default Flatpak apps
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
flatpak install -y --noninteractive flathub io.github.ungoogled_software.ungoogled_chromium || true
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

# eza + yazi binaries
mkdir -p "${SYSROOT}/usr/local/bin"
for bin in eza yazi; do
    if [ -f "${STAGING}/${bin}" ]; then
        cp "${STAGING}/${bin}" "${SYSROOT}/usr/local/bin/${bin}"
        chmod +x "${SYSROOT}/usr/local/bin/${bin}"
        echo "${bin} installed"
    fi
done

#--- GNOME Desktop Icons NG (DING) extension ---
# Not available as RPM in Fedora 43; download from extensions.gnome.org
# GNOME 49 does NOT include desktop icons natively — an extension is required
DING_UUID="ding@rastersoft.com"
DING_EXT_ID=2087
DING_DEST="${SYSROOT}/usr/share/gnome-shell/extensions/${DING_UUID}"
DING_ZIP="/tmp/ding-extension.zip"

# Query the extensions.gnome.org API for the correct version tag
DING_INFO=$(curl -sf "https://extensions.gnome.org/extension-info/?pk=${DING_EXT_ID}&shell_version=49" 2>/dev/null) || true
if [ -n "${DING_INFO}" ]; then
    # Extract the download URL from the JSON response
    DING_URL=$(echo "${DING_INFO}" | python3 -c "import sys,json; print(json.load(sys.stdin).get('download_url',''))" 2>/dev/null) || true
fi

# Fallback: use the direct download endpoint if API query failed
if [ -z "${DING_URL:-}" ]; then
    DING_URL="/download-extension/${DING_UUID}.shell-extension.zip?shell_version=49"
fi

echo "Downloading DING extension from https://extensions.gnome.org${DING_URL} ..."
if curl -sfL "https://extensions.gnome.org${DING_URL}" -o "${DING_ZIP}"; then
    mkdir -p "${DING_DEST}"
    unzip -qo "${DING_ZIP}" -d "${DING_DEST}" && \
        echo "DING extension installed to ${DING_DEST}" || \
        echo "WARN: Failed to extract DING extension"
    rm -f "${DING_ZIP}"
else
    echo "WARN: Failed to download DING extension — desktop icons will not be available"
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
    cp "$LOGO" "${SYSROOT}/usr/share/pixmaps/fedora-logo-sprite.svg" 2>/dev/null || true
fi

#--- Custom Ghostty icon ---
if [ -f /build/theme/branding/ghostty.png ]; then
    cp /build/theme/branding/ghostty.png "${SYSROOT}/usr/share/pixmaps/ghostty.png"
    if [ -f "${SYSROOT}/usr/share/applications/com.mitchellh.ghostty.desktop" ]; then
        sed -i 's|^Icon=.*|Icon=/usr/share/pixmaps/ghostty.png|' "${SYSROOT}/usr/share/applications/com.mitchellh.ghostty.desktop"
    fi
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
favorite-apps=['org.gnome.Nautilus.desktop', 'ghostty.desktop', 'io.github.ungoogled_software.ungoogled_chromium.desktop', 'firefox.desktop', 'org.gnome.Software.desktop']
enabled-extensions=['dash-to-dock@micxgx.gmail.com', 'appindicatorsupport@rgcjonas.gmail.com', 'ding@rastersoft.com']


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

echo "=== BruceOS GNOME desktop configured ==="
%end
