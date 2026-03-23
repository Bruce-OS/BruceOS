# BruceOS — Skills & Knowledge Base

> Reference docs for Claude Code. Read relevant sections before starting tasks.
> These are hard-won facts — trust these over general knowledge.

---

## Skill: Fedora Kickstart

### Key Sections
```
%packages       — what to install
%pre            — runs before partitioning (in installer env)
%post           — runs after install (in chroot)
%post --nochroot — runs after install (in real env, has network)
```

### Adding a COPR repo in kickstart
```bash
# In %post section:
dnf copr enable -y username/reponame
```

### Profile variants
- Use `%include` to share a base kickstart across profiles
- Profile-specific packages go in separate `%packages` blocks

### Useful kickstart snippets
```
# Set default shell to Fish for all users
%post
chsh -s /usr/bin/fish
%end

# Enable a systemd service
%post
systemctl enable ollama.service
%end
```

---

## Skill: CachyOS BORE Kernel

- COPR: `copr.fedorainfracloud.org/coprs/bieszczaders/kernel-cachyos`
- Package: `kernel-cachyos` (BORE scheduler), `kernel-cachyos-lto` (LTO), `kernel-cachyos-rt` (realtime)
- Install in kickstart `%packages`: `kernel-cachyos`
- Must also add the COPR in `%pre` or via a repo file
- Replaces default Fedora kernel — add `excludepkgs=kernel kernel-core kernel-modules` to avoid conflicts

---

## Skill: Calamares Branding

Directory structure for custom branding:
```
installer/branding/bruceos/
├── branding.desc       — metadata, product name, URLs
├── show.qml            — slideshow during install
├── welcome.png         — logo shown on welcome screen
└── sidebar.png         — sidebar image
```

Key `branding.desc` fields:
```yaml
componentName: bruceos
welcomeStyleCalamares: true
productName: BruceOS
shortProductName: Bruce
version: "1.0"
versionedName: BruceOS 1.0
bootloaderEntryName: BruceOS
productUrl: https://bruceos.com
supportUrl: https://github.com/bruceos/bruceos/issues
```

---

## Skill: Ghostty Config

Default config location: `~/.config/ghostty/config`

```
font-family = JetBrains Mono
font-size = 13
theme = catppuccin-mocha
shell-integration = fish
gtk-single-instance = true
quit-after-last-window-closed = false

# Ctrl+` dropdown
keybind = ctrl+grave_accent=toggle_quick_terminal
```

Ship defaults to `/etc/ghostty/config` (system-wide).

---

## Skill: Fish Config

System-wide fish config: `/etc/fish/conf.d/bruce.fish`

```fish
# Set Starship prompt
starship init fish | source

# Atuin history
atuin init fish | source

# Zoxide
zoxide init fish | source

# BruceAI terminal functions
function ai
    mods $argv
end

function explain
    mods "explain this: $argv"
end
```

User config: `~/.config/fish/config.fish` (bruce-setup writes this)

---

## Skill: Ollama Systemd Service

```ini
# /etc/systemd/system/ollama.service
[Unit]
Description=Ollama AI Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/ollama serve
Restart=always
RestartSec=3
Environment=OLLAMA_HOST=127.0.0.1:11434

[Install]
WantedBy=multi-user.target
```

Default models to pre-pull in `%post`:
```bash
# Only if GPU detected with enough VRAM
ollama pull qwen3:8b
ollama pull phi3:mini
```

---

## Skill: RPM Spec Basics

```spec
Name:           bruce-terminal
Version:        1.0.0
Release:        1%{?dist}
Summary:        BruceOS terminal stack configuration
License:        MIT
URL:            https://bruceos.com

%description
Default terminal configuration for BruceOS including
Ghostty, Fish, Starship, Atuin, and Zellij.

%install
mkdir -p %{buildroot}/etc/ghostty
install -m 644 config/ghostty/config %{buildroot}/etc/ghostty/config

%files
/etc/ghostty/config
```

---

## Skill: bruce-setup (Charm Bubble Tea)

Built in Go using Charm's Bubble Tea TUI framework.

```bash
# Dependencies
go get github.com/charmbracelet/bubbletea
go get github.com/charmbracelet/lipgloss
go get github.com/charmbracelet/bubbles
```

Flow: Profile → Shell → Theme → Font → AI → Multiplexer → Apply

Each step writes to:
- `~/.config/ghostty/config`
- `~/.config/starship.toml`
- `~/.config/fish/config.fish`
- `~/.config/zellij/config.kdl`
- `~/.config/atuin/config.toml`

---

## Skill: PhialsBasement Wine Patches

- Patches fix MSHTML/MSXML3 blocking Adobe CC installer
- Photoshop 2021: "butter smooth" after patches
- Photoshop 2025: installs, basic functionality
- NOT upstream in Wine or Proton (PR #310 rejected by Valve)
- Must maintain `bruce-wine-adobe` as a fork

Package as:
```
packages/bruce-wine-adobe/
├── bruce-wine-adobe.spec
├── patches/
│   └── phials-mshtml-msxml3.patch
└── bottles-config/
    └── photoshop-2021.json
```

---

## Skill: GNOME Extensions (Approved List)

Only these extensions ship by default. No others without explicit approval.

| Extension | Purpose |
|---|---|
| Dash to Dock | macOS-style dock |
| Desktop Icons NG | Desktop file icons |
| AppIndicator | System tray |
| Just Perfection | UI cleanup |
| Blur my Shell | Aesthetic blur |
| Tiling Shell | Window tiling |
| User Themes | Custom GTK themes |

---

## Skill: ISO Build Pipeline

```bash
# Build ISO in Podman container (reproducible)
podman run --rm --privileged \
  -v $(pwd):/build \
  fedora:43 \
  bash /build/iso/build.sh bruceos-base.ks

# build.sh does:
# 1. Install lorax + livemedia-creator
# 2. Run livemedia-creator with kickstart
# 3. Output ISO to /build/output/
```

GitHub Actions: trigger on push to `main`, upload ISO as artifact.

---

## Skill: Cloudflare Pages Deploy (Landing Page)

```bash
# Manual deploy
npx wrangler pages deploy ./site --project-name bruceos

# Via GitHub Actions (preferred)
# Uses CLOUDFLARE_API_TOKEN + CLOUDFLARE_ACCOUNT_ID secrets
```

Single HTML file is fine for v1 landing page. No framework needed.
