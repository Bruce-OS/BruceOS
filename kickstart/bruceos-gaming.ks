# BruceOS Gaming Profile — Fedora 43
# "They call me Bruce."
#
# Includes everything from base + gaming packages
# Build: livemedia-creator --ks bruceos-gaming.ks --no-virt --resultdir /output

%include bruceos-base.ks

%packages
# Gaming — Steam and runtime
steam
gamemode
mangohud
gamescope
lutris

# Proton/Wine deps
wine-core
winetricks

# Performance monitoring
vkBasalt
%end

%post --log=/root/bruceos-gaming-post.log
#!/bin/bash
set -euo pipefail

echo "=== BruceOS Gaming profile post-install ==="

#--- Proton-GE (latest from COPR) ---
dnf copr enable -y gloriouseggroll/proton-ge-custom || true
dnf install -y proton-ge-custom || echo "WARN: Proton-GE not available"

#--- ananicy-cpp for process priority ---
dnf copr enable -y kylegospo/ananicy-cpp || true
dnf install -y ananicy-cpp ananicy-cpp-rules || echo "WARN: ananicy-cpp not available"
systemctl enable ananicy-cpp || true

#--- Gaming sysctl tuning ---
cat >> /etc/sysctl.d/99-bruceos.conf << 'SYSCTLEOF'
# Gaming extra tuning
net.core.netdev_max_backlog = 16384
net.core.somaxconn = 8096
net.ipv4.tcp_fastopen = 3
SYSCTLEOF

#--- Add Steam to dock favorites ---
# Append Steam to the existing favorites list via dconf
mkdir -p /etc/dconf/db/local.d
cat > /etc/dconf/db/local.d/02-bruceos-gaming << 'DCONFEOF'
[org/gnome/shell]
favorite-apps=['org.gnome.Nautilus.desktop', 'ghostty.desktop', 'firefox.desktop', 'steam.desktop', 'org.gnome.Software.desktop']
DCONFEOF

echo "=== BruceOS Gaming profile complete ==="
%end
