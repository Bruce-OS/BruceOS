<div align="center">

<img src="theme/bruceos-logo.svg" alt="BruceOS" width="128" />

# BruceOS

**They call me Bruce.**

An operating system with built-in AI, a proper terminal, and gaming that works — built on Fedora 43, the CachyOS BORE kernel, and a quiet confidence that things should just work out of the box.

[![Build](https://img.shields.io/github/actions/workflow/status/Bruce-OS/BruceOS/build-iso.yml?style=flat-square&label=ISO%20Build&color=10b981)](https://github.com/Bruce-OS/BruceOS/actions)
[![License: GPL-2.0](https://img.shields.io/badge/license-GPL--2.0-white?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-x86__64%20%7C%20ARM64-white?style=flat-square)]()

</div>

---

## What is BruceOS?

BruceOS is an operating system for people who want a computer that works — with local AI that runs on your hardware, a terminal stack that doesn't need a config weekend, and gaming that actually runs. It ships as a live ISO you can boot from USB or install to disk.

Built by [Danger Studio](https://danger.studio) in Wellington, NZ. Documentation at [bruceos.com](https://bruceos.com).

## Features

**AI Built In** — Ollama running locally with a GTK4 chat interface. No subscription, no cloud, no data leaving your machine.

**Terminal Stack** — Ghostty + Fish + Starship + Zellij + Atuin. GPU-accelerated, zero-config, with shell history sync and a dropdown terminal on Ctrl+`.

**Gaming** — Steam, Proton-GE, MangoHud, GameMode, and Gamescope pre-configured. CachyOS BORE kernel tuned for low-latency gaming.

**Creative Tools** — Blender, GIMP, Krita, DaVinci Resolve, OBS, Kdenlive, Inkscape, Ardour. VFX Reference Platform support via Distrobox.

**GNOME Desktop** — WhiteSur dark theme, Dash to Dock, Noto Sans + JetBrains Mono. macOS-adjacent layout that looks good without tweaking.

**GPU Auto-Detection** — NVIDIA proprietary, AMD amdgpu, or Intel i915 drivers installed automatically at build time.

**Offline Install** — The full desktop works without an internet connection. Network-dependent features degrade gracefully.

**Performance Tuned** — ZRAM swap, `vm.max_map_count=1048576`, low swappiness, CachyOS BORE scheduler for desktop responsiveness.

## Profiles

| Profile | For | What's Different |
|---------|-----|-----------------|
| Default | Most people | GNOME desktop, AI, terminal stack, sane defaults |
| Gaming | Gamers, streamers | Steam, Proton-GE, MangoHud, GameMode, OBS |
| VFX | 3D artists, compositors | Blender, DaVinci, Distrobox + Rocky for VFX Reference Platform |
| Kids | Schools, Raspberry Pi | Simplified desktop, guardrails, runs on ARM64 |

## Download

> **Status:** Pre-release. ISO builds are functional but not yet recommended for daily use.

**[Download latest ISO from GitHub Actions](https://github.com/Bruce-OS/BruceOS/actions)**

Click the latest successful **BruceOS Build** run → **Artifacts** → **BruceOS-ISO**.

## Building from Source

Requires `podman` and `sudo`.

```bash
git clone https://github.com/Bruce-OS/BruceOS.git
cd BruceOS
```

### Validate kickstart

```bash
ksvalidator kickstart/bruceos-base.ks
```

### Build the ISO

```bash
sudo podman run --rm --privileged --pid=host \
  --security-opt label=disable \
  -v /dev:/dev \
  -v $(pwd):/build \
  fedora:43 bash -c "bash /build/iso/build.sh bruceos-base.ks"
```

Output: `output/BruceOS-1.0-x86_64.iso` (~2 GB)

### Test in a VM

Boot the ISO in GNOME Boxes, QEMU, or virt-manager:

| Setting | Value |
|---------|-------|
| OS | Fedora 43 |
| Firmware | UEFI |
| Memory | 4 GB+ |
| Storage | 30 GB |

## Architecture

```
kickstart/
  bruceos-base.ks      Fedora 43 kickstart — packages, repos, %post config

config/
  ghostty/config        Catppuccin Mocha, JetBrains Mono 13pt, Fish default
  fish/bruce.fish       Starship + Atuin + zoxide init, eza/bat aliases
  starship/starship.toml  Minimal prompt — directory, git, status
  zellij/config.kdl     Catppuccin theme, Alt+hjkl nav

iso/
  build.sh              livemedia-creator wrapper — runs in Podman
  Containerfile         Fedora 43 build container

theme/
  bruceos-logo.svg      Logo — green gradient rounded square, white B
  plymouth/             Boot splash theme (dark bg, green spinner)

site/
  index.html            Static landing page (pre-VitePress)

docs/
  .vitepress/           VitePress config + theme
  guide/                Getting started, installation, building, first boot
  reference/            Kickstart, packages, terminal, AI
```

### Kickstart Flow

The ISO is built from a single kickstart file via `livemedia-creator --no-virt`:

1. **%packages** — Base GNOME desktop, fonts, terminal tools (Fedora repos only)
2. **%post** — CachyOS kernel (COPR), terminal tools (COPR), RPM Fusion codecs, GPU detection, Fish/Starship/Ghostty config, ZRAM, sysctl, GDM auto-login, Plymouth
3. **%post --nochroot** — WhiteSur theme install (network-dependent, skips gracefully offline), dconf defaults

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Base | Fedora 43, RPM, dnf5, systemd |
| Kernel | CachyOS BORE (COPR, with fallback to stock Fedora) |
| Desktop | GNOME 47+, WhiteSur Dark, Dash to Dock |
| Terminal | Ghostty 1.3 (GPU-accelerated, GTK4) |
| Shell | Fish 4.4 (zero-config autocomplete) |
| Prompt | Starship (Rust, TOML config) |
| Multiplexer | Zellij (WASM plugins) |
| History | Atuin (encrypted, SQLite) |
| AI | Ollama + GTK4 chat app (Newelle fork) |
| Installer | Anaconda (Calamares planned) |
| Gaming | Steam, Proton-GE, MangoHud, GameMode |
| VFX Compat | Distrobox + Rocky Linux |
| ISO Build | lorax/livemedia-creator in Podman |
| Docs | VitePress, deployed to Cloudflare Pages |

## Design

Dark mode. The brand palette is used across the landing page, docs, Plymouth theme, and Calamares installer.

| Token | Value | Usage |
|-------|-------|-------|
| Background | `#0a0a0a` | Main background |
| Surface | `#141414` | Cards, panels |
| Border | `#2a2a2a` | Dividers |
| Text | `#f5f5f5` | Primary text |
| Muted | `#a1a1a1` | Secondary text |
| Accent | `#10b981` | Primary accent (emerald green) |
| Accent Dark | `#059669` | Hover, active states |
| Font Display | Red Hat Display | Headings (700–900) |
| Font Body | Red Hat Text | Body copy (400–700) |
| Font Mono | JetBrains Mono | Terminal, code |
| Icons | Lucide | All iconography |

## Contributing

Contributions welcome. Please:

1. Validate kickstart before committing: `ksvalidator kickstart/bruceos-base.ks`
2. Test ISO changes in a VM before opening a PR
3. Fedora packages go in `%packages`, COPR packages in `%post`
4. Shell scripts in Bash, not Zsh or Fish (CI compatibility)
5. All BruceOS packages prefixed `bruce-`

## Commands

| Command | Purpose |
|---------|---------|
| `/build` | Build ISO locally via Podman |
| `/docs` | Regenerate reference docs from source |
| `npm run docs:dev` | Local docs dev server (hot reload) |
| `npm run docs:build` | Production docs build |

## Roadmap

- [x] Fedora 43 base kickstart (validated, builds)
- [x] GNOME + WhiteSur dark theme
- [x] Terminal stack (Ghostty, Fish, Starship, Zellij, Atuin)
- [x] GitHub Actions CI (lint, shellcheck, ISO build)
- [x] Landing page + VitePress docs on Cloudflare Pages
- [ ] Calamares installer with profile selector
- [ ] `bruce-setup` first-boot TUI configurator
- [ ] BruceAI GTK4 chat app + Ollama integration
- [ ] `bruce-wine-adobe` package (Photoshop 2021 via Wine)
- [ ] Gaming profile (Steam, Proton-GE, MangoHud)
- [ ] VFX profile (Blender, DaVinci, Distrobox + Rocky)
- [ ] Raspberry Pi ARM64 build
- [ ] Windows Bridge — VFIO + Looking Glass (v2.0)

## License

[GPL-2.0](LICENSE)

---

<div align="center">

*They call me Bruce.*

Built by [Danger Studio](https://danger.studio) for [BruceOS Inc.](https://bruceos.com)

</div>
