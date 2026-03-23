# First Boot

Here's what happens when BruceOS boots for the first time.

## Desktop

GDM starts and auto-logs in as `liveuser` (on the live ISO) or your created user (on an installed system). No login screen on live boot.

You land on a GNOME desktop with:

- **WhiteSur dark theme** applied to GTK, icons, and window decorations (if network was available during build; falls back to Adwaita otherwise)
- **Dash to Dock** at the bottom of the screen, fixed position
- **Window buttons** on the left side (close, minimize, maximize) -- Mac-style layout
- **Favorite apps** in the dock: Files, Ghostty, Firefox, Software

The default wallpaper is GNOME's stock wallpaper. A BruceOS wallpaper is planned.

## Terminal

Open Ghostty from the dock or press `Ctrl+\`` for the dropdown terminal.

You get:

- **Fish shell** with autocomplete and syntax highlighting. No plugins needed.
- **Starship prompt** showing your current directory, git branch, and git status. Nothing else.
- **Catppuccin Mocha** color scheme with JetBrains Mono at 13pt.

The following aliases are pre-configured:

```
ls  → eza --icons
ll  → eza -la --icons
cat → bat --paging=never
tree → eza --tree --icons
```

Run `fastfetch` to see your system info.

## Zellij

Start a multiplexed terminal session with:

```bash
zellij
```

Navigation uses Alt+hjkl (vim-style). Fish is the default shell inside Zellij panes. Pane frames are disabled for a clean look.

## What's not there yet

The following features are planned but not available on first boot today:

**bruce-setup TUI.** A first-boot configuration wizard that handles profile selection, shell preference, theme customization, and AI model downloads. Coming soon.

**AI assistant.** Ollama and the GTK4 chat application are not yet pre-installed. The model download and configuration will be handled by bruce-setup.

**Gaming stack.** Steam, Proton-GE, and related tools are not included in the base profile yet.

**Creative tools.** Blender, GIMP, Krita, and DaVinci Resolve are planned for the VFX profile.

## System details

A few things the kickstart configures under the hood:

- **Kernel:** CachyOS BORE scheduler (falls back to stock Fedora kernel if COPR was unavailable)
- **GPU drivers:** Auto-detected during build. NVIDIA gets proprietary drivers, AMD and Intel use the kernel drivers.
- **ZRAM swap:** Enabled, sized to half your RAM, compressed with zstd
- **vm.max_map_count:** Set to 1048576 (required by many games and large applications)
- **vm.swappiness:** Set to 10 (prefers keeping data in RAM)
- **SELinux:** Enforcing
- **Firewall:** Enabled with SSH allowed
- **Flatpak:** Flathub remote added for installing additional applications
- **Podman and Distrobox:** Installed for running containers and alternate Linux environments

## Next steps

- [Terminal reference](/reference/terminal) -- full configuration details for Ghostty, Fish, Starship, and Zellij
- [Package list](/reference/packages) -- everything that's installed
- [Kickstart reference](/reference/kickstart) -- how the system is built
