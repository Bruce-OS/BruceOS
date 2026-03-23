# BruceOS — Rules

Hard rules. Read before every session. Non-negotiable.

---

## 🔴 Never Do These

1. **Never commit to `main` directly.** Always a branch + PR.
2. **Never add packages without a kickstart entry.** If it's not in the `.ks` file, it doesn't exist.
3. **Never break offline install.** Every default must work air-gapped.
4. **Never add GNOME extensions not on the approved list** (see SKILLS.md).
5. **Never write Python where Bash will do.**
6. **Never ship a config that hasn't been tested** in a VM or container.
7. **Never commit ISOs, model weights, or binaries** to git.
8. **Never claim Photoshop 2025 works** — only 2021 is supported via bruce-wine-adobe.
9. **Never add external npm/pip deps to bruce-setup** — it's a Go binary, keep it self-contained.
10. **Never use `sudo` inside scripts** — document privilege requirements instead.

---

## 🟡 Always Do These

1. **grep before creating.** Search the codebase before writing new code.
2. **Update PROGRESS.md** when completing a task.
3. **Update MEMORY.md** when making a decision or discovering a gotcha.
4. **Test in a VM** before marking any installer/kickstart work done.
5. **Label experimental features clearly** in UI and docs.
6. **Run the end-of-session prompt** before closing Claude Code.
7. **Keep commits atomic** — one logical change per commit.
8. **Write commit messages in imperative mood** — "Add Ghostty config" not "Added Ghostty config".
9. **Check ROADMAP.md** before starting any task — don't build v2 things in a v1 sprint.
10. **Keep the landing page deployable** — it should always be deployable from `main`.

---

## 🟢 Preferences

- **Bash > Python > anything else** for build/packaging scripts
- **Fish functions** for user-facing terminal helpers
- **Go** for compiled TUI tools (bruce-setup)
- **GTK4/libadwaita** for GUI apps (BruceAI)
- **systemd** for services — no init.d, no launchd
- **Podman** for build containers — not Docker
- **RPM/COPR** for packages — not Flatpak, not AppImage (for core system packages)
- **Flatpak** is fine for optional user apps (Steam, DaVinci Resolve)
- **TOML** for config files where possible
- **Short functions** — if a bash function exceeds 30 lines, split it

---

## Tone / Branding Rules

- The OS is called **Bruce** or **BruceOS** — not "bruce-os", not "BRUCE"
- Tagline: **"Linux. But it's called Bruce."**
- Tone: dry, deadpan, confident — never corporate, never cutesy
- Documentation voice: direct, no filler words
- Error messages: helpful and specific, never condescending
- AI assistant name: **Bruce** (not BruceAI in user-facing text)

---

## What v1.0 Is NOT

Do not build these in v1. Defer firmly.

- Windows Bridge (VFIO + Looking Glass)
- AT-SPI desktop control for BruceAI
- Voice input / TTS
- TRELLIS.2 or any generative AI models
- MCP marketplace
- Education mode guardrails
- Certified hardware program
- Cloud streaming (Parsec / NICE DCV)
