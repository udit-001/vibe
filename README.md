# vibe: skills, plugins, and extensions for Claude Code, Pi, and opencode

One repo for the toolkit I run across three agents.

## What's here

| Path | What it is |
|---|---|
| `skills/` | 10 skills for any agent, installed via the [skills CLI](https://skills.sh) |
| `claude-plugins/` | Claude Code plugin marketplace, shipping the **Focus** output style |
| `pi-extensions/` | Pi extension sources |
| `pi-setup/` | Pi installer for Windows (optional on-ramp, see below) |
| `REFERENCE.md` | The external tools I use, cataloged |

## Skills

Skills are folders with a `SKILL.md`, installed from any agent (Claude Code, Pi, opencode):

```bash
npx skills add udit-001/vibe                       # interactive
npx skills add udit-001/vibe --all                 # all skills, all agents
npx skills add udit-001/vibe -s image-fetcher -a claude-code -a pi -a opencode  # specific
npx skills use udit-001/vibe -s ux-resilience      # use without installing
```

Installs to `./<agent>/skills/` (add `-g` for global); symlinks by default (`--copy` for copies).

The full catalog: [docs/skills.md](docs/skills.md).

## Claude Code

This repo doubles as a Claude Code plugin marketplace, shipping the **Focus** output style (answer first, one decision at a time, cheap to verify, no filler):

```bash
/plugin marketplace add udit-001/vibe
/plugin install focus-output-style@vibe
```

Or non-interactively:

```bash
claude plugin marketplace add udit-001/vibe
claude plugin install focus-output-style@vibe
```

> [!NOTE]
> The style ships with `force-for-plugin: true`, so installing it applies **Focus** to every session automatically (verified with `claude plugin validate`). To make it opt-in, remove that line from `claude-plugins/focus-output-style/output-styles/focus.md` and pick it via `/config` → Output style. Uninstall with `/plugin uninstall focus-output-style@vibe`.

The canonical Focus text lives in the separate `output-style` project (`styles/Focus.md`); this copy is what the plugin ships.

## Pi

Extensions for [Pi](https://github.com/earendil-works/pi-coding-agent) live in `pi-extensions/`. Copy or symlink any of them into `.pi/extensions/` (project) or `~/.pi/agent/extensions/` (global), then `/reload`.

The full table (10 extensions, permission commands, print mode): [docs/pi-extensions.md](docs/pi-extensions.md).

## opencode

The skills above work in opencode too: pass `-a opencode` when installing (see the example in Skills).

## Pi setup (Windows)

Optional on-ramp for getting someone started on Pi. Nothing above needs this.

```powershell
irm https://cdn.jsdelivr.net/gh/udit-001/vibe@7cd55827f57bdc7550a078e6d3260683728a88b5/pi-setup/install.ps1 | iex
```

Installs [Pi](https://github.com/earendil-works/pi-coding-agent) (Node and Git included if missing), then adds:

- `pi-zen`: free OpenCode Zen models
- `pi-vision`: vision for text-only models
- `pi-mcp-adapter`: MCP support
- `pi-subagents`: multi-agent workflows

After install: run `pi`, then `/login pi-zen` (key at https://opencode.ai/zen) and `/model`.

## Reference

The full catalog of external tools I use lives in [REFERENCE.md](REFERENCE.md).