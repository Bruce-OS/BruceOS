# Getting Started

BruceOS is an operating system built on Fedora 43 with the CachyOS BORE kernel. It ships with a local AI assistant, a terminal that works out of the box, and gaming that doesn't require a weekend of troubleshooting.

It's a Linux distribution. It does what a computer should do.

## Who it's for

BruceOS targets three groups of people who are tired of fighting their operating system:

**Kids and schools.** A simple desktop that runs on a Raspberry Pi or classroom x86 hardware. No ads, no accounts, no telemetry.

**VFX and multimedia artists.** Blender, GIMP, Krita, DaVinci Resolve, and a VFX Reference Platform container via Distrobox. Creative tools that are installed and ready, not hidden behind package managers.

**Gamers.** Steam and Proton-GE pre-configured. MangoHud, GameMode, and Gamescope included. Games run. That's the feature.

## Profiles

BruceOS ships four profiles, each tuned for a different use case:

| Profile | What you get |
|---------|-------------|
| **Default** | GNOME desktop, terminal stack, AI assistant. For most people. |
| **Gaming** | Everything in Default plus Steam, Proton-GE, MangoHud, GameMode. |
| **VFX** | Everything in Default plus Blender, DaVinci Resolve, GIMP, Krita, Distrobox with Rocky Linux. |
| **Kids** | Simplified desktop for schools and Raspberry Pi hardware. |

Profile selection happens during installation (coming soon -- currently only the Default profile is available).

## What's in the box

### Desktop

GNOME with the WhiteSur dark theme applied. Dash to Dock at the bottom. Mac-style window buttons on the left. Noto Sans and JetBrains Mono fonts. No configuration required.

### Terminal stack

- **Ghostty** -- GPU-accelerated terminal with Catppuccin Mocha theme
- **Fish** -- shell with autocompletion that works without plugins
- **Starship** -- minimal prompt showing directory, git branch, and status
- **Zellij** -- terminal multiplexer with vim-style navigation
- **Atuin** -- shell history synced across sessions and searchable
- **Modern CLI tools** -- `bat`, `eza`, `fzf`, `zoxide`, `ripgrep`, `yazi`, `lazygit`, `btop`, `fastfetch`

Open a terminal. It works. No `.bashrc` archaeology required.

### AI

Ollama runs locally for model inference. A GTK4 chat application (coming soon) provides a desktop interface. MCP servers for filesystem, terminal, and git access are planned.

No subscription. No cloud. No data leaves your machine.

### Gaming (planned)

Steam, Proton-GE, DXVK, VKD3D-Proton, MangoHud, GameMode, and Gamescope. The kernel ships with `vm.max_map_count=1048576` already set.

### Creative tools (planned)

Blender, GIMP, Krita, DaVinci Resolve, Inkscape, Kdenlive, OBS Studio, Ardour, and a full FFmpeg build.

## System requirements

| | Minimum | Recommended |
|---|---------|-------------|
| **Architecture** | x86_64 | x86_64 |
| **RAM** | 4 GB | 8 GB (16 GB for AI models) |
| **Disk** | 20 GB | 50 GB |
| **GPU** | Any (NVIDIA, AMD, Intel) | NVIDIA or AMD discrete for gaming/AI |
| **Boot** | UEFI or Legacy BIOS | UEFI |

Raspberry Pi support (ARM64) is planned for the Kids profile.

## Next steps

- [Install BruceOS](/guide/installation) -- write the ISO to a USB drive and boot it
- [Build from source](/guide/building) -- build your own ISO from the kickstart configuration
- [First boot](/guide/first-boot) -- what to expect when you boot BruceOS for the first time
