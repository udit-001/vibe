# VS Code diffs

`code -d <file1> <file2>` opens two files side by side.

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

`code -d` takes two files only. For a whole commit, open the changed files one at a time.
