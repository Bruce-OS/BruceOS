# BruceOS — Session Prompts

Paste the relevant prompt at the start of each Claude Code session.

---

## 🟢 Generic Init (use every session)

```
Read CLAUDE.md, MEMORY.md, and PROGRESS.md before doing anything.

Give me a 3-line status summary, then confirm what we're working on today.

Current task: [FILL THIS IN]
```

---

## 🏗️ Base OS / Kickstart Session

```
Read CLAUDE.md, MEMORY.md, PROGRESS.md, and the "Fedora Kickstart" and 
"CachyOS BORE Kernel" sections of SKILLS.md.

We are working on the Fedora kickstart files in kickstart/.

Current task: [FILL THIS IN]

Rules:
- grep first before creating any new file
- Test changes build in Podman before marking done
- Update PROGRESS.md when a checkbox is completed
```

---

## 🖥️ Terminal Stack Session

```
Read CLAUDE.md, MEMORY.md, PROGRESS.md, and the "Ghostty Config", 
"Fish Config", and "bruce-setup" sections of SKILLS.md.

We are working on the terminal stack in packages/bruce-terminal/ and config/.

Current task: [FILL THIS IN]

Rules:
- All config changes must go in config/ as well as the RPM spec
- bruce-setup TUI is written in Go (Charm Bubble Tea)
- Test Fish config changes in a fresh Fish session
```

---

## 🤖 BruceAI Session

```
Read CLAUDE.md, MEMORY.md, PROGRESS.md, and the "Ollama Systemd Service" 
section of SKILLS.md.

We are working on BruceAI in packages/bruce-ai/.
This is a GTK4/libadwaita app forked from Newelle v1.2.

Current task: [FILL THIS IN]

Rules:
- GTK4 + libadwaita only, no Qt
- Local-first: works without internet or cloud API keys
- Ollama must be the default backend
- MCP servers communicate via stdio, not HTTP
```

---

## 🌐 Landing Page Session

```
Read CLAUDE.md and MEMORY.md.

We are building the bruceos.com landing page.
Single HTML file, deployed to Cloudflare Pages.
Tone: deadpan, dry humour, "They call me Bruce."
NO frameworks, NO build steps, NO npm.

Current task: [FILL THIS IN]

Design rules:
- Dark theme (near-black bg, white text, one accent colour)
- Mobile responsive
- Must load fast on slow connections
- CTA: email signup waitlist + GitHub link
```

---

## 🍷 Wine/Adobe Session

```
Read CLAUDE.md, MEMORY.md, and the "PhialsBasement Wine Patches" section 
of SKILLS.md.

We are working on bruce-wine-adobe in packages/bruce-wine-adobe/.

Current task: [FILL THIS IN]

Rules:
- Everything labelled "Experimental" in UI and docs
- Only claim Photoshop 2021 support — not 2025, not Illustrator
- Must work via Bottles frontend (no raw Wine commands for users)
- Patches must be clearly documented with attribution to PhialsBasement
```

---

## 📦 Packaging Session (RPM)

```
Read CLAUDE.md, MEMORY.md, and the "RPM Spec Basics" section of SKILLS.md.

We are working on RPM packaging in packages/.

Current task: [FILL THIS IN]

Rules:
- All packages prefixed bruce-
- Specs go in packages/<name>/<name>.spec
- Test build with: rpmbuild -ba packages/<name>/<name>.spec
- COPR submission after local build passes
```

---

## 🔁 End of Session (always run this)

```
Session wrap-up:

1. Update PROGRESS.md — check off completed items, add new ones discovered
2. Update MEMORY.md — add any decisions made, gotchas found, or state changes
3. Summarise what we did in 3 bullet points
4. State the recommended first task for next session
```
