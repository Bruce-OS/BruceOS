# AI Stack

BruceOS includes a local AI assistant that runs entirely on your hardware. No cloud services, no subscriptions, no data leaving your machine.

This feature is in early development. Most of what's described here is planned, not shipped.

## Architecture

The AI stack has three layers:

1. **Ollama** -- runs local language models. Handles model management, GPU acceleration, and inference.
2. **GTK4 chat application** (coming soon) -- desktop interface for talking to models. Fork of [Newelle](https://github.com/qwersyk/Newelle) with BruceOS integration.
3. **MCP servers** (coming soon) -- give the AI access to your filesystem, terminal, and git repositories through the Model Context Protocol.

## Ollama

Ollama provides the inference backend. It runs as a systemd service (coming soon) and exposes a local API at `http://localhost:11434`.

### Default models (planned)

| Model | Size | Use case |
|-------|------|----------|
| Qwen3 8B | ~5 GB | General purpose chat and coding assistance |
| Phi-3 Mini | ~2.3 GB | Lightweight tasks on machines with less RAM |

Model selection and download will be handled by the `bruce-setup` first-boot wizard, which detects your hardware and recommends appropriate models.

### Manual setup

Until `bruce-setup` is available, you can set up Ollama manually:

```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Start the service
systemctl --user start ollama

# Pull a model
ollama pull qwen3:8b

# Test it
ollama run qwen3:8b "Explain what BruceOS is in one sentence."
```

## GTK4 Chat Application (coming soon)

A native GNOME application for chatting with local models. Planned features:

- Chat interface with conversation history
- Model selector for switching between installed models
- GNOME Shell extension for quick access via `Ctrl+Space` overlay
- Markdown rendering in responses
- Code block copy-to-clipboard

This is a fork of Newelle, adapted for BruceOS defaults and Ollama integration.

## MCP Servers (coming soon)

Model Context Protocol servers give the AI structured access to your system. Three servers are planned for v1.0:

**Filesystem.** Read and write files. The AI can look at your project files, suggest edits, and create new files with your permission.

**Terminal.** Run commands. The AI can execute shell commands and see their output, useful for debugging and automation tasks.

**Git.** Repository operations. The AI can check status, view diffs, and help with commit messages.

MCP servers run locally and require explicit user permission for each action. Nothing runs without your approval.

## Terminal AI (coming soon)

For developers who prefer the command line, BruceOS plans to include:

- **mods** (from [Charm](https://github.com/charmbracelet/mods)) -- pipe command output to an LLM and get responses in the terminal
- **Fish `ai` function** -- a shell function for quick questions without leaving the terminal

Example (planned):

```bash
# Ask a question
ai "How do I find large files on this system?"

# Pipe output to the AI
dmesg | mods "What errors am I seeing?"
```

## Hardware requirements

Local AI inference is GPU-bound. Here's what to expect:

| Hardware | Experience |
|----------|-----------|
| No discrete GPU, 8 GB RAM | Phi-3 Mini runs, slowly. Qwen3 8B will struggle. |
| No discrete GPU, 16 GB RAM | Qwen3 8B runs at usable speed via CPU inference. |
| NVIDIA GPU, 8 GB VRAM | Qwen3 8B runs well with GPU acceleration. |
| NVIDIA GPU, 16+ GB VRAM | Larger models become practical. |
| AMD GPU, 8+ GB VRAM | ROCm support via Ollama. Works but less tested than NVIDIA. |

The first-boot wizard (coming soon) will detect your hardware and suggest models that will actually run well on your machine, rather than downloading something that crawls.
