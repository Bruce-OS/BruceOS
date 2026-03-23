# BruceOS — Claude Code Project Context

## What is BruceOS?

BruceOS is a custom Linux distribution built on Fedora 43+. It targets three audiences:
- **Kids & schools** (Raspberry Pi + x86_64)
- **VFX/multimedia artists** (Blender, DaVinci, GIMP, Krita, Houdini-adjacent tools)
- **Gamers** (Steam, Proton, DXVK, Looking Glass)

The name is deliberately deadpan. No pretension. Bruce just works.

**Domain:** bruceos.com  
**Org:** github.com/bruceos  
**Company:** BruceOS Inc. (Delaware C-Corp, pending)  
**Lead:** Mark Cameron Williams (Dirk), Wellington NZ  

---

## Repository Layout

```
bruceos/
├── CLAUDE.md               # You are here
├── MEMORY.md               # Persistent state across sessions
├── PROGRESS.md             # What's done, what's in flight
├── ROADMAP.md              # Versioned milestones
├── kickstart/              # Fedora kickstart configs
│   ├── bruceos-base.ks
│   ├── bruceos-gaming.ks
│   ├── bruceos-vfx.ks
│   └── bruceos-pi.ks
├── kernel/                 # Kernel config and patches
│   └── cachyos-bore/
├── installer/              # Calamares QML customisation
│   ├── branding/
│   └── modules/
├── packages/               # RPM specs and copr configs
│   ├── bruce-ai/
│   ├── bruce-terminal/
│   ├── bruce-wine-adobe/
│   └── bruce-setup/
├── config/                 # Default dotfiles and system config
│   ├── ghostty/
│   ├── fish/
│   ├── starship/
│   └── zellij/
├── theme/                  # GNOME WhiteSur theme + Bruce tweaks
├── pi/                     # Raspberry Pi ARM64 specific
├── iso/                    # ISO build scripts
│   ├── build.sh
│   └── Containerfile
├── ci/                     # GitHub Actions workflows
└── docs/                   # Documentation
```

---

## Core Rules (Read Every Session)

### Coding Philosophy
- **KISS always.** If it feels complex, it is. Back up and simplify.
- **grep first.** Before writing any new file or function, search for existing implementations.
- **No orphaned code.** Every file must be referenced somewhere or it gets deleted.
- **Composition over inheritance.** Always.
- **Shell scripts over Python** for build/packaging tasks unless Python is unavoidable.
- **Bash, not Zsh or Fish** for CI scripts — maximum compatibility.

### Git Workflow
- Main branch: `main`
- Feature branches: `feature/descriptive-name`
- Worktrees for parallel features (see WORKTREES.md)
- Commit messages: imperative mood, 72 char subject line
- Never commit directly to `main`
- PRs require passing CI

### Build System
- Fedora 43+ base, built via `lorax`/`livemedia-creator` from kickstart
- All package additions go through kickstart `%packages` section
- COPR repos for non-Fedora packages
- ARM64 (Pi) built separately via `bruceos-pi.ks`
- ISO built in Podman container for reproducibility

### Package Naming Convention
- All BruceOS packages prefixed `bruce-`
- e.g. `bruce-ai`, `bruce-terminal`, `bruce-setup`, `bruce-wine-adobe`

### No Broken Defaults
- Every config file committed must produce a working system
- Test in a VM before merging
- Default experience must work without internet (offline install)

---

## Tech Stack Summary

| Layer | Choice | Notes |
|---|---|---|
| Base | Fedora 43+ | RPM, dnf5, systemd |
| Kernel | CachyOS BORE | AUR-style COPR |
| Desktop | GNOME 47+ | WhiteSur theme |
| Terminal | Ghostty 1.3 | GPU-accelerated |
| Shell | Fish 4.4 | Zero-config autocomplete |
| Prompt | Starship | Rust, TOML |
| Multiplexer | Zellij | WASM plugins |
| AI | Ollama + GTK4 app | Fork of Newelle |
| Installer | Calamares | Custom QML branding |
| Gaming | Steam + Proton-GE | MangoHud, GameMode |
| VFX compat | Distrobox/Rocky | VFX Reference Platform |
| Windows compat | VFIO + Looking Glass | Dual-GPU setups |

---

## What NOT To Do

- Don't add GNOME extensions without a clear use case — we have a curated list
- Don't change the default Fish config without updating `config/fish/`
- Don't add Python deps to shell-script tools
- Don't break offline install capability
- Don't commit ISOs or large binaries to git
- Don't add systemd units without corresponding `%post` in kickstart
- Don't use `sudo` in scripts — document privilege requirements instead

---

## Current Focus: v1.0

See PROGRESS.md for detailed status. High-level v1.0 scope:

1. **Base OS** — Fedora 43, CachyOS kernel, GNOME, WhiteSur, Calamares installer
2. **BruceTerminal** — Ghostty + Fish + Starship + Atuin + Zellij, first-boot `bruce-setup` TUI
3. **BruceAI** — GTK4 chat app, Ollama backend, basic MCP servers (filesystem, terminal, git)
4. **Adobe Wine** — `bruce-wine-adobe` package, Photoshop 2021 via PhialsBasement patches
5. **Landing page** — bruceos.com, Cloudflare Pages

v1.0 is NOT: Windows Bridge (v2.0), full AI desktop control (v2.0), TRELLIS.2 (v2.0+)
