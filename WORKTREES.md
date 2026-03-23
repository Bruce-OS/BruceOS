# BruceOS — Git Worktrees

Git worktrees let us work on multiple features in parallel without stashing or branch-switching.

---

## Setup

```bash
# Clone main repo
git clone git@github.com:bruceos/bruceos.git
cd bruceos

# Create worktrees for active features
git worktree add ../bruceos-installer feature/calamares-branding
git worktree add ../bruceos-ai feature/bruce-ai-gtk4
git worktree add ../bruceos-terminal feature/bruce-terminal-stack
git worktree add ../bruceos-landing feature/landing-page
```

---

## Active Worktrees

| Directory | Branch | Purpose |
|---|---|---|
| `bruceos/` | `main` | Stable, CI-passing only |
| `bruceos-installer/` | `feature/calamares-branding` | Calamares QML + branding |
| `bruceos-ai/` | `feature/bruce-ai-gtk4` | BruceAI GTK4 app |
| `bruceos-terminal/` | `feature/bruce-terminal-stack` | Ghostty + Fish + bruce-setup |
| `bruceos-landing/` | `feature/landing-page` | bruceos.com site |

---

## Worktree Rules

- Each worktree has its own Claude Code session
- Each worktree has its own `.claude/` state if needed
- Never work on `main` directly in any worktree
- Merge via PR only — no direct pushes to main
- Delete worktree + branch after merge: `git worktree remove ../bruceos-landing`

---

## Starting a New Feature Worktree

```bash
# From main bruceos/ directory
git fetch origin
git worktree add ../bruceos-<feature> feature/<feature-name>
cd ../bruceos-<feature>

# Start Claude Code here
claude
```

---

## Claude Code Per-Worktree Init

Each worktree should have a `.claude/` folder with session state. The root `CLAUDE.md` applies everywhere (it's in the repo). The `.claude/` folder in each worktree holds worktree-specific context.

```
bruceos-ai/
├── CLAUDE.md          (symlink or copy from root)
├── .claude/
│   └── session.md     (worktree-specific context)
└── packages/
    └── bruce-ai/
```
