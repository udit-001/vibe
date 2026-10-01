---
name: vscode
description: Open diffs and file comparisons in VS Code. Use when showing the user what changed in a file, comparing two files or versions, or reviewing git changes visually.
license: MIT
---

# VS Code diffs

> Adapted from [pi-skills](https://github.com/badlogic/pi-skills) by Mario Zechner (MIT).

Show the user a real side-by-side diff instead of pasting two files. This needs VS Code with the `code` CLI on `PATH`; if `code` is missing, say so and fall back to `git diff` in the terminal.

## Compare two files

```bash
code -d <file1> <file2>
```

## Compare a file against a git revision

Write the old revision to a temp file, then open both:

```bash
# Against the previous commit
tmp=$(mktemp); git show HEAD~1:path/to/file > "$tmp" && code -d "$tmp" path/to/file

# Against a specific commit
tmp=$(mktemp); git show abc123:path/to/file > "$tmp" && code -d "$tmp" path/to/file

# Staged version against the working tree
tmp=$(mktemp); git show :path/to/file > "$tmp" && code -d "$tmp" path/to/file
```

Before diffing, confirm the file has history: `git log --oneline -5 -- path/to/file`. `code -d` shows nothing useful when there is no change between the two revisions.
