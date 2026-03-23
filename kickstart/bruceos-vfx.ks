# BruceOS VFX Profile — Fedora 43
# "They call me Bruce."
#
# Includes everything from base + creative/VFX packages
# Build: livemedia-creator --ks bruceos-vfx.ks --no-virt --resultdir /output

%include bruceos-base.ks

%packages
# Creative tools (Fedora repos)
blender
gimp
krita
inkscape
kdenlive
obs-studio
ardour

# Color management
colord

# Image/video utilities
ImageMagick
ffmpeg
%end

%post --log=/root/bruceos-vfx-post.log
#!/bin/bash
set -euo pipefail

echo "=== BruceOS VFX profile post-install ==="

#--- DaVinci Resolve requires manual install (proprietary) ---
# Create a launcher placeholder
mkdir -p /usr/share/applications
cat > /usr/share/applications/davinci-resolve-installer.desktop << 'DESKTOPEOF'
[Desktop Entry]
Name=Install DaVinci Resolve
Comment=Download and install DaVinci Resolve from Blackmagic Design
Exec=xdg-open https://www.blackmagicdesign.com/products/davinciresolve
Icon=video-display
Terminal=false
Type=Application
Categories=AudioVideo;Video;
DESKTOPEOF

#--- Distrobox + Rocky for VFX Reference Platform ---
# Pre-create a Rocky 9 container for VFX Reference Platform compatibility
if command -v distrobox &>/dev/null; then
    distrobox create --name vfx-rocky --image rockylinux:9 --yes || echo "WARN: Distrobox Rocky container creation deferred to first use"
fi

#--- Add creative apps to dock favorites ---
mkdir -p /etc/dconf/db/local.d
cat > /etc/dconf/db/local.d/02-bruceos-vfx << 'DCONFEOF'
[org/gnome/shell]
favorite-apps=['org.gnome.Nautilus.desktop', 'ghostty.desktop', 'firefox.desktop', 'blender.desktop', 'gimp.desktop', 'org.kde.krita.desktop', 'org.gnome.Software.desktop']
DCONFEOF

echo "=== BruceOS VFX profile complete ==="
%end
