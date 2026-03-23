# BruceOS — Progress Tracker

> Single source of truth for what's done, in progress, and blocked.
> Updated every session. Checked before starting any task.

---

## v1.0 Milestone — Target: Q3 2026

### Foundation

- [x] GitHub org `Bruce-OS` created (2026-03-11)
- [x] Repo structure scaffolded
- [x] Domain `bruceos.com` registered
- [ ] Delaware C-Corp filed (BruceOS Inc.)
- [ ] USPTO trademark filed (class 9, "BRUCEOS")
- [x] CI pipeline (GitHub Actions) — ISO build + lint + shellcheck
- [x] Podman-based ISO build container (`iso/Containerfile`)

### Base OS

- [x] Fedora 43 base kickstart (`bruceos-base.ks`) — validated with pykickstart
- [x] CachyOS BORE kernel COPR configured (in kickstart %post, with fallback)
- [x] GNOME 47+ with WhiteSur theme (kickstart %post, network-dependent with offline guard)
- [ ] Calamares installer with Bruce branding
  - [ ] Custom QML branding screen
  - [ ] Profile selector (Default / Gaming / VFX / Kids)
  - [ ] First-boot flow triggers `bruce-setup`
- [x] Auto GPU detection (NVIDIA open kernel / AMD amdgpu / Intel)
- [x] Btrfs autopart layout
- [x] Offline install works (WhiteSur theme gracefully skipped)

### Bruce Terminal Stack (`bruce-terminal`)

- [x] Ghostty config (Catppuccin Mocha, JetBrains Mono 13pt, dropdown, Fish default)
- [x] Fish config (Starship, Atuin, zoxide init + aliases)
- [x] Starship prompt config
- [x] Zellij config (Catppuccin, Fish default, vim keybinds)
- [x] Core TUI tools in kickstart: bat, eza, fzf, zoxide, ripgrep, yazi, lazygit, btop, fastfetch
- [ ] `bruce-setup` first-boot TUI configurator
  - [ ] Profile selection
  - [ ] Shell selection (Fish default, Zsh optional)
  - [ ] Theme selection
  - [ ] Font selection
  - [ ] AI setup (model download)
  - [ ] Applies configs to `~/.config/`

### BruceAI (`bruce-ai`)

- [ ] Ollama systemd service (auto-start)
- [ ] GTK4/libadwaita chat app (Newelle fork)
  - [ ] Basic chat interface
  - [ ] Model selector (local models)
  - [ ] GNOME Shell extension (Ctrl+Space overlay)
- [ ] Default model download: Qwen3 8B + Phi-3 Mini
- [ ] MCP servers (basic set):
  - [ ] Filesystem
  - [ ] Terminal
  - [ ] Git
- [ ] First-boot AI setup wizard (hardware detect → model download)
- [ ] Terminal AI: `mods` (Charm) + Fish `ai` function

### Gaming Stack

- [ ] Steam pre-installed
- [ ] Proton-GE latest
- [ ] DXVK 2.7+, VKD3D-Proton
- [ ] GameMode + MangoHud + vkBasalt
- [ ] Gamescope
- [x] vm.max_map_count=1048576 sysctl (in kickstart)
- [x] ZRAM configured (in kickstart)
- [ ] ananicy-cpp

### VFX Stack

- [ ] Blender 5.x
- [ ] DaVinci Resolve 20 (installer + launcher)
- [ ] GIMP 3.0
- [ ] Krita
- [ ] Inkscape
- [ ] Kdenlive
- [ ] OBS Studio
- [ ] Ardour
- [ ] FFmpeg (full build)
- [ ] Distrobox + Rocky Linux for VFX Reference Platform

### Adobe Wine (`bruce-wine-adobe`)

- [ ] PhialsBasement patches applied to Wine fork
- [ ] Packaged as `bruce-wine-adobe` RPM
- [ ] Bottles integration for Photoshop 2021 setup
- [ ] Warning labels: "Experimental — Photoshop 2021 only"
- [ ] Documented limitations

### Landing Page (bruceos.com)

- [x] Single-page HTML/CSS (`site/index.html`)
- [x] Hero section: "They call me Bruce."
- [x] Feature sections: AI / Terminal / Gaming / VFX
- [x] Download section (placeholder)
- [ ] Email signup (wait list backend)
- [x] GitHub link
- [ ] Deployed to Cloudflare Pages

### Documentation

- [x] README.md (project overview)
- [ ] CONTRIBUTING.md
- [ ] BUILD.md (how to build the ISO)
- [ ] docs/architecture.md

---

## v2.0 Scope (Not v1)

- Windows Bridge (VFIO + Looking Glass + WinApps)
- Full AT-SPI desktop control for BruceAI
- Voice input (faster-whisper)
- TRELLIS.2 3D generation service
- MCP marketplace
- Education mode with guardrails
- Certified hardware list

---

## Known Issues / Tech Debt

- No container runtime on dev machine — can't test ISO builds locally
- WhiteSur theme install requires network (gracefully degrades offline)
- CachyOS BORE COPR repo URL needs periodic verification
- Dual %packages sections removed; kernel now installed in %post (less elegant but more reliable)
- Remote currently points to megasupersoft/BruceOS — needs updating to Bruce-OS org
