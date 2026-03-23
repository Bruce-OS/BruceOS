# Contributing to BruceOS

Thanks for helping. Here's how to not break things.

## Getting Started

1. Fork the repo and clone it
2. Read [CLAUDE.md](CLAUDE.md) — project rules, tech stack, what not to do
3. Build the ISO to make sure it works before changing anything:

```bash
sudo podman run --rm --privileged --pid=host \
  --security-opt label=disable -v /dev:/dev \
  -v $(pwd):/build fedora:43 \
  bash -c "bash /build/iso/build.sh bruceos-base.ks"
```

## Before You Submit

- Validate the kickstart: `ksvalidator kickstart/bruceos-base.ks`
- Test your changes in a VM (GNOME Boxes, UEFI, 4GB+ RAM)
- Shell scripts must be Bash, not Zsh or Fish
- Run shellcheck on any `.sh` files you touch

## Kickstart Rules

- Packages available in Fedora repos go in `%packages`
- Packages from COPR go in `%post` with `dnf copr enable`
- Every COPR install must have a fallback (`|| echo "WARN: ..."`)
- Don't break offline install — guard network-dependent steps

## Package Naming

All BruceOS packages are prefixed `bruce-`:
- `bruce-ai`, `bruce-terminal`, `bruce-setup`, `bruce-wine-adobe`

## Commit Messages

- Imperative mood, 72 char subject line
- Explain the why, not just the what

## What Not to Do

- Don't commit ISOs or large binaries
- Don't add GNOME extensions without discussion
- Don't add Python deps to shell scripts
- Don't use `sudo` in scripts — document privilege requirements
- Don't commit secrets, tokens, or credentials

## Profiles

BruceOS has multiple kickstart profiles:

| File | Purpose |
|---|---|
| `bruceos-base.ks` | Default desktop — everyone gets this |
| `bruceos-gaming.ks` | Includes base + Steam, Proton-GE, MangoHud |
| `bruceos-vfx.ks` | Includes base + Blender, GIMP, Krita, DaVinci |

Profile kickstarts use `%include bruceos-base.ks` and add their own packages/post scripts.

## License

By contributing, you agree your work is licensed under [GPL-2.0](LICENSE).
