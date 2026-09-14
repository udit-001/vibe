# Pi Extensions

The 10 extensions in `pi-extensions/`. Copy or symlink any of them into `.pi/extensions/` (project) or `~/.pi/agent/extensions/` (global), then `/reload` in Pi. The one-liners below come from each extension's code.

**Working with the agent**

| Extension | What it does |
|---|---|
| [todos](../pi-extensions/todos) | File-based todos (`.pi/todos`) |
| [review](../pi-extensions/review) | Code review, inspired by Codex's review feature |
| [answer](../pi-extensions/answer) | Extracts questions from assistant responses |
| [handoff](../pi-extensions/handoff) | Prepares a prompt for a focused new session |

**Control**

| Extension | What it does |
|---|---|
| [permission](../pi-extensions/permission) | Layered permission control |
| [input-transform](../pi-extensions/input-transform) | Rewrites inputs or handles commands before they reach the LLM |
| [tools](../pi-extensions/tools) | Enables and disables Pi tools interactively |

**Display**

| Extension | What it does |
|---|---|
| [usage-status](../pi-extensions/usage-status) | Provider usage and rate-limit status |
| [powerline-footer](../pi-extensions/powerline-footer) | Powerline-style status footer |
| [titlebar-spinner](../pi-extensions/titlebar-spinner) | Animated spinner in the terminal title while the agent runs |

## Permission commands

- `/permission` (or `/permission <minimal|low|medium|high>`): view or change the permission level
- `/permission-mode <ask|block>`: whether Pi prompts or blocks when higher permission is required

## Print mode

`PI_PERMISSION_LEVEL=medium pi -p "..."` runs a one-shot prompt at a set permission level.