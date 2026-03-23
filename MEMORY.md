# BruceOS — Session Memory

> This file is updated at the END of every Claude Code session.
> It captures decisions, discoveries, and state that must persist.
> Read this FIRST at the start of every session.

---

## Project Identity

- **Name:** BruceOS
- **Domain:** bruceos.com ✅ (registered March 2026)
- **GitHub org:** github.com/Bruce-OS ✅ (created 2026-03-11)
- **Company:** BruceOS Inc. (TODO: Delaware C-Corp via Stripe Atlas)
- **Trademark:** TODO — USPTO class 9, "BRUCEOS"
- **Parent entity:** Danger Studio / Mark Cameron Williams, Wellington NZ

---

## Key Decisions (Permanent Record)

| Date | Decision | Rationale |
|---|---|---|
| 2026-03 | Name: BruceOS | Deadpan, memorable, zero conflicts, honours Bruce Perens unintentionally |
| 2026-03 | Base: Fedora 43+ | RPM ecosystem, fast updates, best NVIDIA/gaming support |
| 2026-03 | Kernel: CachyOS BORE | Best desktop/gaming latency, COPR available |
| 2026-03 | Desktop: GNOME + WhiteSur | Polished OOB, MIT licensed theme |
| 2026-03 | Terminal: Ghostty | GPU-accel, native GTK, MIT, best-in-class |
| 2026-03 | Shell: Fish | Zero-config, schools-friendly, fast |
| 2026-03 | AI: Ollama + Newelle fork | Local-first, no subscriptions, GTK4 native |
| 2026-03 | v1 scope: NO Windows Bridge | Too complex for v1, deferred to v2 |
| 2026-03 | Fedora 43 is latest release | Confirmed by Dirk, build directly on F43 |

---

## Active Work

<!-- Update this section each session -->

| Item | Status | Owner | Notes |
|---|---|---|---|
| Repo scaffold | IN PROGRESS | Claude | This session |
| bruceos.com landing page | TODO | - | Cloudflare Pages |
| Delaware C-Corp | TODO | Dirk | Via Stripe Atlas |
| GitHub org | TODO | Dirk | github.com/bruceos |
| Fedora 43 base kickstart | TODO | - | Start from Fedora Workstation ks |
| bruce-setup TUI | TODO | - | Charm Bubble Tea, Go |
| BruceAI GTK4 app | TODO | - | Fork Newelle v1.2 |

---

## Blockers

- ~~GitHub org not created yet — can't push~~ ✅ Resolved: github.com/Bruce-OS
- Delaware C-Corp pending — needed before trademark filing
- No CI runner set up yet

---

## Environment Notes

<!-- Add anything Claude needs to know about the dev environment -->

- Lead dev machine: likely macOS/Linux (Wellington NZ)
- Target build env: Fedora 43 in Podman container
- Pi target: Raspberry Pi 4/5, Debian Bookworm ARM64

---

## Gotchas Discovered

<!-- Add bugs, surprises, or non-obvious facts here as discovered -->

- CachyOS BORE kernel requires separate COPR, not in default Fedora repos
- Ghostty requires GTK4 — verify Fedora 43 GTK4 version compatibility
- PhialsBasement Wine patches not upstream in Proton — must maintain fork
- Fish shell: `vivi` is a Linux kernel V4L2 module name — avoid in scripts
- IBM VIOS conflict killed "ViOS" name

---

## Last Session Summary

**Date:** 2026-03-12  
**What happened:** Initial project naming resolved (BruceOS), domain registered (bruceos.com), full repo scaffold created  
**Next session should:** Create GitHub org, push scaffold, start bruceos.com landing page
