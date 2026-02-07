# deslop

Remove AI-generated slop **only from the changes currently present in this repo** (committed diff vs `origin/main` plus any staged/unstaged working tree changes). Be conservative: keep the feature; make the code look like it was written by a human in this codebase.

## Scope (what you are allowed to touch)
You may only edit files that appear in **at least one** of these lists:
- `git diff --name-only origin/main...HEAD` (committed changes on the branch)
- `git diff --name-only --cached` (staged changes)
- `git diff --name-only` (unstaged changes)

Take the **union** of those file lists. **It is valid for `origin/main...HEAD` to be empty** (e.g. you are on `main` but have staged changes); in that case, operate on staged/unstaged files only.

Do not edit any other files.

## Hard rules (do not violate)
1. **Never revert/cleanup the workspace unless explicitly asked.**
   - Never run: `git reset`, `git checkout`, `git restore`, `git clean`.
   - Never delete files/dirs (e.g. `rm`, `rm -rf`) unless explicitly asked.
2. **Do not remove whole features.** If a new file is sloppy, edit it; don’t delete it.
3. **No broad refactors.** Do not rename/move files, change module boundaries, or redesign APIs.
4. **Preserve behavior.** If removing slop would change behavior, ask first.
5. **If tools are blocked (permissions / prompts), stop and ask.** Don’t try alternative destructive commands to “get unstuck”.

## What counts as “AI slop” (remove it)
- Big banner/docblock headers that restate obvious things.
- Section divider comments like `// ======` unless the file already uses them consistently.
- `as any` / type escape hatches.
- Over-generic abstractions/helpers that aren’t pulling their weight.
- Over-defensive code that’s inconsistent with local style (unneeded caching layers, excessive validation, “security paranoia” comments).

### What to *keep*
- Error handling around truly unreliable inputs (e.g. reading user config files).
- Minimal guards that are standard in this repo.
- Upstream/third-party logic: prefer minimal touch (strip banners / `any` casts) over semantic rewrites.

## Workflow
1. Compute target files from the three diffs above; if the set is large, ask before touching everything.
2. For each target file:
   - Read the whole file.
   - Compare style with nearby project files (same folder/package); if none exist, default to minimal deletions only.
   - Remove slop with minimal edits (prefer deleting code/comments over adding new layers).
3. Run minimal verification (typecheck/tests) if available.

## Output requirement
At the end, output **only 1–3 sentences** summarizing what you changed.
