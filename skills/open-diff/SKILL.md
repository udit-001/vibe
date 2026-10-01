---
name: open-diff
description: Open diffs and file comparisons in the user's editor (VS Code or Zed). Use when showing the user what changed in a file, comparing two files or versions, or reviewing git changes visually.
license: MIT
---

# Open a diff

> Adapted from [pi-skills](https://github.com/badlogic/pi-skills) by Mario Zechner (MIT).

Show the user a real side-by-side diff instead of pasting two files. Use the editor whose CLI is on `PATH`: `code` for VS Code, `zed` for Zed. If neither is installed, say so and fall back to `git diff` in the terminal.

Load the reference for the editor in use:

- `references/vscode.md` -- `code -d` commands.
- `references/zed.md` -- `zed --diff` commands, including whole-tree multi-diff.

Before diffing, confirm the file has history: `git log --oneline -5 -- path/to/file`. A diff shows nothing useful when there is no change between the two revisions.
