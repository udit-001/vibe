# Zed diffs

`zed --diff <OLD> <NEW>` opens a diff tab. It is repeatable, and given two directories it recurses and shows every changed file in one multi-diff view.

## Compare two files

```bash
zed --diff <file1> <file2>
```

## Compare a file against a git revision

Write the old revision to a temp file, then open both:

```bash
# Against the previous commit
tmp=$(mktemp); git show HEAD~1:path/to/file > "$tmp" && zed --diff "$tmp" path/to/file

# Against a specific commit
tmp=$(mktemp); git show abc123:path/to/file > "$tmp" && zed --diff "$tmp" path/to/file

# Staged version against the working tree
tmp=$(mktemp); git show :path/to/file > "$tmp" && zed --diff "$tmp" path/to/file
```

## Whole commit or branch as one multi-diff

Materialize the two trees, then diff the directories:

```bash
tmp=$(mktemp -d); mkdir -p "$tmp/old" "$tmp/new"
git archive HEAD~1 | tar -x -C "$tmp/old"
git archive HEAD   | tar -x -C "$tmp/new"
zed --diff "$tmp/old" "$tmp/new"
```

Check the scope first with `git diff --name-only HEAD~1 HEAD`; a multi-diff over a large tree opens a tab per changed file.
