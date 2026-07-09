# AI Coding Toolkit

A lightweight catalog of tools used with Claude Code, Pi, and opencode.

## Skills

Opencode skills live in `skills/`. Each is a folder with a `SKILL.md` that teaches the agent a reusable workflow.

### image-fetcher

Fetch a free-licensed image and drop it into the project — no API keys, no setup. Searches Openverse, NASA, and Wikimedia Commons for CC0/public-domain photos and downloads them to a scratch dir for preview.

- **Sources** — `openverse` (general photos, the default), `nasa` (space/science/history, all public domain), `wikimedia` (landmarks/diagrams/SVGs/historical), or `all` for maximum breadth.
- **License** — defaults to CC0/public-domain (no attribution needed); `-l any` widens to CC-BY etc. with credit recorded in `attribution.json`.
- **Prerequisites** — [`uv`](https://docs.astral.sh/uv/) on PATH. It installs `requests` automatically on first run; no manual `pip install`.

**Install:**

```bash
# global — available in every project
cp -r skills/image-fetcher ~/.agents/skills/

# or symlink — stays in sync with this repo
ln -s "$(pwd)/skills/image-fetcher" ~/.agents/skills/image-fetcher
```

**Usage:** Once installed, just ask the agent — "find me a hero photo of a modern office", "add a picture of mars", "fetch images for this page". The agent runs `fetch.py` under the hood. To use the CLI directly:

```bash
uv run skills/image-fetcher/fetch.py "modern office" -d                # download 5 to scratch
uv run skills/image-fetcher/fetch.py "mars surface" -s nasa -d         # NASA source
uv run skills/image-fetcher/fetch.py "eiffel tower" -s wikimedia --full -d  # full-res
```

**Higher rate limits (optional):** The skill works keyless by default. If you hit Openverse's 200/day anonymous cap, run the setup wizard for free OAuth credentials (200/day → 10,000/day):

```bash
bash skills/image-fetcher/setup.sh
```

See [`SKILL.md`](skills/image-fetcher/SKILL.md) and [`SOURCES.md`](skills/image-fetcher/SOURCES.md) for full details.

## Claude Code Plugins
- Voice Mode: https://github.com/mbailey/voicemode
- Vibe Log CLI: https://github.com/vibe-log/vibe-log-cli
- Handy Computer: https://handy.computer
- Basic Memory: https://github.com/basicmachines-co/basic-memory
- Episodic Memory: https://github.com/obra/episodic-memory
- Claude Code Viewer: https://github.com/d-kimuson/claude-code-viewer
- Recall: https://github.com/zippoxer/recall

## Pi Extensions

### Project
- Answer: pi-extensions/answer
- Usage Status: pi-extensions/usage-status
- Powerline Footer: pi-extensions/powerline-footer
- Review: pi-extensions/review
- Todos: pi-extensions/todos
- Permission: pi-extensions/permission
- Handoff: pi-extensions/handoff (prepare a prompt for a focused new session)
- Input Transform: pi-extensions/input-transform (rewrite special inputs or handle commands before they reach the LLM)
- Prompt Stash: pi-extensions/prompt-stash (stash input with Alt+S, browse with /stashed-prompts)
- Tools: pi-extensions/tools (enable/disable Pi tools interactively)
- Titlebar Spinner: pi-extensions/titlebar-spinner (show an animated spinner in the terminal title while the agent runs)

**Permission commands (in Pi):**
- `/permission` (or `/permission <minimal|low|medium|high>`) — view/change permission level
- `/permission-mode <ask|block>` — whether Pi prompts or blocks when higher permission is required

**Print mode:** `PI_PERMISSION_LEVEL=medium pi -p "..."`

### Global
- [pi-interactive-shell](https://github.com/nicobailon/pi-interactive-shell)
- [pi-mcp-adapter](https://github.com/nicobailon/pi-mcp-adapter)
- [pi-rewind-hook](https://github.com/nicobailon/pi-rewind-hook)
- [@tmustier/pi-tab-status](https://github.com/tmustier/pi-extensions/tree/main/tab-status)
- [@tmustier/pi-usage-extension](https://github.com/tmustier/pi-extensions/tree/main/usage-extension)
- [pi-powerline-footer](https://github.com/nicobailon/pi-powerline-footer)
- [threads](https://github.com/laulauland/dotfiles/tree/main/shared/.pi/agent/extensions/threads)

## MCP Servers
- Exa MCP: https://docs.exa.ai/reference/exa-mcp
- Deepwiki MCP: https://docs.devin.ai/work-with-devin/deepwiki-mcp?utm_source=ai-bot.cn
- Grep MCP: https://vercel.com/blog/grep-a-million-github-repositories-via-mcp
- LLMs.txt MCP: https://github.com/langchain-ai/mcpdoc
- FastMCP MCP: https://gofastmcp.com/getting-started/welcome#mcp-server

## Status Lines
- CCometixLine: https://github.com/Haleclipse/CCometixLine

## Skills
- Tufte Chart Skills: https://github.com/aref-vc/tufte-claude-skill

## LLMs.txt References
- Langgraph: https://langchain-ai.github.io/langgraph/llms.txt
- Pydantic AI: https://ai.pydantic.dev/llms.txt
- FastMCP: https://gofastmcp.com/getting-started/welcome#text-formats
