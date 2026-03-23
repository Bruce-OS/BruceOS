#!/bin/bash
# BruceOS Build Verification
# Runs inside the built system to audit what installed correctly.
# Usage: Called automatically after ISO build, or manually via:
#   sudo chroot /path/to/rootfs bash /build/iso/verify-build.sh

set -uo pipefail

PASS=0
FAIL=0
WARN=0

pass() { echo -e "  \033[32mPASS\033[0m: $1"; ((PASS++)); }
fail() { echo -e "  \033[31mFAIL\033[0m: $1"; ((FAIL++)); }
warn() { echo -e "  \033[33mWARN\033[0m: $1"; ((WARN++)); }

echo "========================================"
echo " BruceOS Build Verification"
echo "========================================"
echo ""

# --- OS Branding ---
echo "--- OS Branding ---"
grep -q "BruceOS" /etc/os-release 2>/dev/null && pass "os-release says BruceOS" || fail "os-release missing BruceOS branding"
grep -q "PRETTY_NAME=\"BruceOS" /etc/os-release 2>/dev/null && pass "PRETTY_NAME is BruceOS" || fail "PRETTY_NAME not set"
hostname | grep -qi "bruceos" && pass "hostname is bruceos" || warn "hostname is $(hostname), expected bruceos"

# --- Kernel ---
echo ""
echo "--- Kernel ---"
rpm -q kernel-cachyos &>/dev/null && pass "CachyOS BORE kernel installed" || warn "CachyOS kernel missing (using stock Fedora)"
rpm -q kernel-core &>/dev/null || rpm -q kernel-cachyos &>/dev/null && pass "A kernel is installed" || fail "No kernel installed"

# --- Desktop ---
echo ""
echo "--- Desktop ---"
rpm -q gnome-shell &>/dev/null && pass "GNOME Shell installed" || fail "GNOME Shell missing"
rpm -q gdm &>/dev/null && pass "GDM installed" || fail "GDM missing"
rpm -q gnome-shell-extension-dash-to-dock &>/dev/null && pass "Dash to Dock installed" || fail "Dash to Dock missing"
rpm -q gnome-shell-extension-appindicator &>/dev/null && pass "AppIndicator extension installed" || warn "AppIndicator missing"
rpm -q spice-vdagent &>/dev/null && pass "SPICE agent installed" || warn "SPICE agent missing"
! rpm -q gnome-terminal &>/dev/null && pass "gnome-terminal NOT installed (correct)" || fail "gnome-terminal still installed"
! rpm -q gnome-console &>/dev/null && pass "gnome-console NOT installed (correct)" || warn "gnome-console still installed"

# --- Terminal Stack ---
echo ""
echo "--- Terminal Stack ---"
for pkg in ghostty fish starship atuin zellij; do
    if which "$pkg" &>/dev/null 2>&1 || rpm -q "$pkg" &>/dev/null; then
        pass "$pkg installed"
    else
        fail "$pkg MISSING"
    fi
done

# --- TUI Tools ---
echo ""
echo "--- TUI Tools ---"
for tool in bat fzf zoxide ripgrep btop fastfetch; do
    rpm -q "$tool" &>/dev/null && pass "$tool installed" || fail "$tool missing"
done
for tool in eza yazi lazygit; do
    if which "$tool" &>/dev/null 2>&1; then
        pass "$tool installed (binary)"
    else
        fail "$tool MISSING"
    fi
done

# --- Configs ---
echo ""
echo "--- Configs ---"
test -f /etc/ghostty/config && pass "Ghostty config exists" || fail "Ghostty config MISSING"
test -f /etc/fish/conf.d/bruce.fish && pass "Fish config exists" || fail "Fish config MISSING"
test -f /etc/xdg/starship.toml && pass "Starship config exists" || fail "Starship config MISSING"
test -f /etc/fastfetch/config.jsonc && pass "Fastfetch config exists" || fail "Fastfetch config MISSING"

# --- Shell ---
echo ""
echo "--- Shell ---"
grep "liveuser" /etc/passwd | grep -q "/usr/bin/fish" && pass "liveuser shell is Fish" || fail "liveuser shell is NOT Fish"
grep "root" /etc/passwd | head -1 | grep -q "/usr/bin/fish" && pass "root shell is Fish" || warn "root shell is not Fish"

# --- GDM Auto-login ---
echo ""
echo "--- GDM ---"
test -f /etc/gdm/custom.conf && pass "GDM config exists" || fail "GDM config MISSING"
grep -q "AutomaticLogin=liveuser" /etc/gdm/custom.conf 2>/dev/null && pass "GDM auto-login configured" || fail "GDM auto-login NOT configured"
systemctl get-default 2>/dev/null | grep -q "graphical" && pass "Default target is graphical" || fail "Default target is NOT graphical"

# --- Theming ---
echo ""
echo "--- Theming ---"
test -f /etc/dconf/db/local.d/01-bruceos && pass "dconf BruceOS defaults exist" || fail "dconf defaults MISSING"
test -f /usr/share/backgrounds/bruceos/wallpaper.png && pass "BruceOS wallpaper installed" || warn "BruceOS wallpaper missing (needs asset generation)"
test -f /usr/share/pixmaps/ghostty.png && pass "Custom Ghostty icon installed" || warn "Custom Ghostty icon missing"

# --- Fonts ---
echo ""
echo "--- Fonts ---"
fc-list 2>/dev/null | grep -qi "jetbrains" && pass "JetBrains Mono font installed" || fail "JetBrains Mono MISSING"
fc-list 2>/dev/null | grep -qi "noto sans" && pass "Noto Sans font installed" || fail "Noto Sans MISSING"

# --- Performance ---
echo ""
echo "--- Performance ---"
test -f /etc/sysctl.d/99-bruceos.conf && pass "sysctl tuning exists" || fail "sysctl tuning MISSING"
grep -q "1048576" /etc/sysctl.d/99-bruceos.conf 2>/dev/null && pass "vm.max_map_count set" || fail "vm.max_map_count not set"
test -f /etc/systemd/zram-generator.conf && pass "ZRAM configured" || fail "ZRAM config MISSING"

# --- Repos ---
echo ""
echo "--- Repos ---"
test -f /etc/yum.repos.d/cachyos-kernel.repo && pass "CachyOS COPR repo configured" || warn "CachyOS repo missing"
dnf repolist 2>/dev/null | grep -q "rpmfusion-free" && pass "RPM Fusion Free enabled" || warn "RPM Fusion Free missing"
flatpak remotes 2>/dev/null | grep -q "flathub" && pass "Flathub configured" || warn "Flathub missing"

# --- Plymouth ---
echo ""
echo "--- Plymouth ---"
rpm -q plymouth &>/dev/null && pass "Plymouth installed" || warn "Plymouth missing"

# --- Summary ---
echo ""
echo "========================================"
echo " Results: $PASS passed, $FAIL failed, $WARN warnings"
echo "========================================"

if [ "$FAIL" -gt 0 ]; then
    echo " STATUS: BUILD HAS FAILURES"
    exit 1
else
    echo " STATUS: BUILD OK"
    exit 0
fi
