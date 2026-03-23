# Terminal Stack

BruceOS ships a complete terminal environment: Ghostty as the emulator, Fish as the shell, Starship as the prompt, Zellij as the multiplexer, and Atuin for shell history. Everything is configured system-wide out of the box.

User-level overrides in `~/.config/` take precedence over the system defaults described here.

## Ghostty

System config: `/etc/ghostty/config`

```
font-family = JetBrains Mono
font-size = 13
theme = catppuccin-mocha
shell-integration = fish
gtk-single-instance = true
quit-after-last-window-closed = false
keybind = ctrl+grave_accent=toggle_quick_terminal
```

### Key settings

**Font.** JetBrains Mono at 13pt. Change it in `~/.config/ghostty/config` if you prefer something else.

**Theme.** Catppuccin Mocha (dark). Ghostty ships with Catppuccin built in, so no external theme files are needed.

**Dropdown terminal.** Press `Ctrl+\`` to toggle a dropdown terminal from the top of the screen. This is the `toggle_quick_terminal` keybind.

**Single instance.** `gtk-single-instance = true` means opening Ghostty from the dock or a file manager reuses the existing process instead of spawning a new one.

**Shell integration.** Fish shell integration is enabled. This gives Ghostty awareness of the current working directory, command boundaries, and exit codes.

### Override

Create `~/.config/ghostty/config` with any settings you want to change. Ghostty merges user config on top of the system config.

## Fish

System config: `/etc/fish/conf.d/bruce.fish`

```fish
# BruceOS default Fish configuration
starship init fish | source
atuin init fish | source
zoxide init fish | source

# Aliases
alias ls="eza --icons"
alias ll="eza -la --icons"
alias cat="bat --paging=never"
alias tree="eza --tree --icons"
```

### What this does

**Starship init.** Activates the Starship prompt. Fish's built-in prompt is replaced.

**Atuin init.** Hooks into Fish's history system. Press `Ctrl+R` to search command history with Atuin's fuzzy finder instead of Fish's default history search.

**Zoxide init.** Replaces `cd` with `z` for smart directory jumping. Use `cd` normally or use `z partial-path` to jump to frequently visited directories.

### Aliases

| Alias | Expands to | Why |
|-------|-----------|-----|
| `ls` | `eza --icons` | Colored output with file type icons |
| `ll` | `eza -la --icons` | Long listing with hidden files |
| `cat` | `bat --paging=never` | Syntax highlighting, no pager |
| `tree` | `eza --tree --icons` | Tree view with icons |

### Override

Add your own Fish configuration to `~/.config/fish/config.fish` or drop files in `~/.config/fish/conf.d/`. Fish sources all `.fish` files in `conf.d/` directories, so the system-wide BruceOS config and your personal config both apply.

## Starship

System config: `/etc/xdg/starship.toml`

```toml
# BruceOS Starship Prompt
format = """
$directory\
$git_branch\
$git_status\
$character"""

[directory]
truncation_length = 3
truncation_symbol = ".../"

[git_branch]
symbol = " "

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
```

### What you see

The prompt shows three things and nothing else:

1. **Directory** -- current path, truncated to 3 levels deep
2. **Git branch** -- shown with a branch icon when inside a git repository
3. **Git status** -- modified, staged, or untracked indicators

The prompt character is `❯`. Green means the last command succeeded, red means it failed.

### Override

Create `~/.config/starship.toml` to replace the system config entirely, or set the `STARSHIP_CONFIG` environment variable to point to a custom location.

## Zellij

System config: `/etc/xdg/zellij/config.kdl` (copied during build from `config/zellij/config.kdl`)

```kdl
// BruceOS Zellij Configuration
theme "catppuccin-mocha"

default_shell "fish"

pane_frames false

keybinds {
    shared {
        bind "Alt h" { MoveFocusOrTab "Left"; }
        bind "Alt l" { MoveFocusOrTab "Right"; }
        bind "Alt j" { MoveFocus "Down"; }
        bind "Alt k" { MoveFocus "Up"; }
    }
}
```

### Key settings

**Theme.** Catppuccin Mocha, matching Ghostty.

**Default shell.** Fish. New panes and tabs open Fish, not Bash.

**Pane frames.** Disabled. Panes are separated by thin lines instead of bordered frames, which saves screen space.

**Navigation.** Vim-style with Alt as the modifier:

| Keybind | Action |
|---------|--------|
| `Alt+h` | Move focus left (or previous tab) |
| `Alt+l` | Move focus right (or next tab) |
| `Alt+j` | Move focus down |
| `Alt+k` | Move focus up |

### Override

Create `~/.config/zellij/config.kdl` to override the system config. Zellij does not merge configs -- the user config replaces the system config entirely.

## Atuin

Atuin is initialized via the Fish config (`atuin init fish | source`) but has no custom BruceOS configuration. It uses its defaults:

- SQLite database for history storage at `~/.local/share/atuin/`
- `Ctrl+R` opens the interactive history search
- History is stored locally by default (cloud sync is opt-in)

Configure Atuin by creating `~/.config/atuin/config.toml`. See the [Atuin documentation](https://docs.atuin.sh/) for options.
