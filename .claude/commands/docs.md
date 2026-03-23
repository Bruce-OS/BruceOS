Regenerate the BruceOS reference documentation from current source files.

Read the following source files and update the corresponding docs:

1. `kickstart/bruceos-base.ks` → update `docs/reference/kickstart.md` with current packages, repos, and %post steps
2. `kickstart/bruceos-base.ks` %packages section → update `docs/reference/packages.md` with the full package list
3. `config/ghostty/config` + `config/fish/bruce.fish` + `config/starship/starship.toml` + `config/zellij/config.kdl` → update `docs/reference/terminal.md` with current config examples

Keep the existing doc structure and tone. Only update the technical content to match current source. Mark anything planned but not yet implemented as "(planned)".

After updating, run `npm run docs:build` to verify the build passes.
