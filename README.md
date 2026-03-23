# BruceOS

**Linux. But it's called Bruce.**

A custom Linux distribution for people who want a system that just works — with built-in AI, a proper terminal experience, and gaming that actually runs. Named Bruce because every other distro is called Aurora or Nebula or something.

---

## What's in the box

- **Fedora 43** base with CachyOS BORE kernel
- **GNOME** desktop with WhiteSur theme (looks good, no config required)
- **Bruce** — a built-in AI assistant. Local models, no subscription, no cloud required.
- **Ghostty + Fish + Starship** — terminal stack that works out of the box
- **Steam + Proton-GE** — gaming pre-configured
- **Blender, GIMP, Krita, DaVinci Resolve** — creative tools ready to go
- **bruce-wine-adobe** — experimental Photoshop 2021 support via Wine

---

## Profiles

| Profile | For |
|---|---|
| Default | Most people |
| Gaming | Gamers, OBS streamers |
| VFX | 3D artists, compositors, VFX professionals |
| Kids | Schools, Raspberry Pi |

---

## Status

🚧 **Pre-release / Active Development** — not ready for daily use yet.

See [PROGRESS.md](PROGRESS.md) for detailed build status.

---

## Building

```bash
# Build ISO in Podman (requires privileged container)
podman run --rm --privileged \
  -v $(pwd):/build \
  -w /build \
  fedora:43 \
  bash iso/build.sh bruceos-base.ks
```

See [docs/BUILD.md](docs/BUILD.md) for full build instructions.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). PRs welcome.

---

## Website

[bruceos.com](https://bruceos.com)

---

## License

GPL-2.0 (same as the Linux kernel). See [LICENSE](LICENSE).

---

*BruceOS is not affiliated with Bruce Willis, Bruce Lee, Bruce Springsteen, or Bruce Perens (though we respect all of them).*
