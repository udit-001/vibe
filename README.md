# AI Coding Toolkit

Skills, output styles, and extensions for Claude Code, Pi, and opencode.

## Install (Windows)

One line. PowerShell:

```powershell
irm https://cdn.jsdelivr.net/gh/udit-001/vibe@7cd55827f57bdc7550a078e6d3260683728a88b5/pi-setup/install.ps1 | iex
```

Installs [Pi](https://github.com/earendil-works/pi-coding-agent) (Node and Git included if missing), then adds:

- `pi-zen`: free OpenCode Zen models
- `pi-vision`: vision for text-only models
- `pi-mcp-adapter`: MCP support
- `pi-subagents`: multi-agent workflows

After install: run `pi`, then `/login pi-zen` (key at https://opencode.ai/zen) and `/model`.

## Skills

Skills live in `skills/` (each folder has a `SKILL.md`). Install with the [skills CLI](https://skills.sh):

```bash
npx skills add udit-001/vibe                       # interactive
npx skills add udit-001/vibe --all                 # all skills, all agents
npx skills add udit-001/vibe -s image-fetcher -a claude-code -a pi -a opencode  # specific
npx skills use udit-001/vibe -s ux-resilience      # use without installing
```

Installs to `./<agent>/skills/` (add `-g` for global); symlinks by default (`--copy` for copies).

**Included:**
- `image-fetcher`: fetch free-licensed photos (Openverse/NASA/Wikimedia, needs `uv`)
- `docs-seeker`: find tech docs via llms.txt/context7, GitHub repo analysis (Repomix), parallel exploration
- `search`: deep research with Exa (lead gen, literature reviews, competitive analysis)
- `ux-clarity`: interface microcopy
- `ux-onboarding`: first-run flows
- `ux-resilience`: edge-case hardening

## Claude Code Plugins

This repo doubles as a Claude Code plugin marketplace. It ships the **Focus** output style (answer first, one decision at a time, cheap to verify, no filler):

```bash
/plugin marketplace add udit-001/vibe
/plugin install focus-output-style@vibe
```

Or non-interactively:

```bash
claude plugin marketplace add udit-001/vibe
claude plugin install focus-output-style@vibe
```

The style ships with `force-for-plugin: true`, so installing the plugin applies **Focus** to every session automatically (verified with `claude plugin validate`). To make it opt-in instead, remove `force-for-plugin: true` from `claude-plugins/focus-output-style/output-styles/focus.md` and pick it via `/config` → Output style. Uninstall with `/plugin uninstall focus-output-style@vibe`.

The canonical Focus text lives in the separate `output-style` project (`styles/Focus.md`); this copy is what the plugin ships.

## Pi Extensions

Sources for the extensions in this repo: copy or symlink any of them into `.pi/extensions/` (project) or `~/.pi/agent/extensions/` (global) to load, then `/reload`. The one-liners below are extracted from each extension's code.

**Working with the agent**
- [Todos](pi-extensions/todos): file-based todos (`.pi/todos`)
- [Review](pi-extensions/review): code review, inspired by Codex's review feature
- [Answer](pi-extensions/answer): extracts questions from assistant responses
- [Handoff](pi-extensions/handoff): prepare a prompt for a focused new session

**Control**
- [Permission](pi-extensions/permission): layered permission control
- [Input Transform](pi-extensions/input-transform): rewrite inputs or handle commands before they reach the LLM
- [Tools](pi-extensions/tools): enable/disable Pi tools interactively

**Display**
- [Usage Status](pi-extensions/usage-status): provider usage and rate-limit status
- [Powerline Footer](pi-extensions/powerline-footer): powerline-style status footer
- [Titlebar Spinner](pi-extensions/titlebar-spinner): animated spinner in the terminal title while the agent runs

**Permission commands (in Pi):**
- `/permission` (or `/permission <minimal|low|medium|high>`): view/change permission level
- `/permission-mode <ask|block>`: whether Pi prompts or blocks when higher permission is required

**Print mode:** `PI_PERMISSION_LEVEL=medium pi -p "..."`

## Reference

The full catalog of external tools I use lives in [REFERENCE.md](REFERENCE.md).
