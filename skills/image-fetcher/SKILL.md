---
name: image-fetcher
description: Fetch a free-licensed image and drop it into the project — no API keys, no setup. Use when the user wants a real photo, picture, or artwork found and added to the project ("find me an image of", "need a hero photo", "add a picture of", "fetch images for this page").
---

Drop a real, free-licensed image into the project. Downloads land in a scratch dir by default; you copy the winner into the project.

## The engine

All searching and downloading is one script in this skill's folder:

```
uv run SKILL_DIR/fetch.py "QUERY" [opts]
```

`SKILL_DIR` is the folder this `SKILL.md` lives in — substitute the real absolute path. Run with `uv run` (PEP 723 inline metadata declares `requests`, which uv installs automatically on first run; no manual `pip install`). Requires `uv` on PATH.

Options:
- `-n N` — results (default 5)
- `-s` — source: `openverse` (default) | `nasa` | `wikimedia` | `all`
- `-l` — license: `cc0,pd` (default, no attribution needed) | `any` (CC-BY etc.)
- `-d` — download to scratch (default `/tmp/opencode/image-fetcher/`); without `-d`, just list
- `-o DIR` — output dir (overrides scratch — use to place directly into the project)
- `-w N` — max width px (Wikimedia thumbnail); `--full` — full-res original
- `--json` — machine-readable output

## Picking a source

Pick by subject using [`SOURCES.md`](SOURCES.md) — it lists what each source is strong at, its license, and its quirks. Default `openverse` (broadest); reach for `nasa` (space/science/history), `wikimedia` (landmarks/diagrams/historical), or `all` (breadth) when the subject fits.

## Workflow

1. **Parse intent** — subject, how many, where it goes in the project, and the source (per `SOURCES.md`).
2. **Fetch to scratch** — `uv run SKILL_DIR/fetch.py "q" -s <source> -d`. Downloads the top N to scratch and prints the scratch path. The stdout list is a human preview; your structured source for picking is `scratch/attribution.json` (filename ↔ title ↔ license ↔ creator ↔ dimensions).
   - Done when: the scratch path holds the image files and `attribution.json`.
3. **Inspect** — read `scratch/attribution.json` to pick by title, license, or creator; or open the image files to judge visually. Choose the winner.
   - Done when: you've settled which file to place.
4. **Place the winner** — `cp` the chosen file from scratch into the target project path.
   - Done when: the chosen image exists at the project target path.
5. **Attribution (nice-to-have, not a gate)** — if the placed image is non-CC0 and it's cheap, grab the credit line from `scratch/attribution.json` and drop it near the image (a code comment, a `CREDITS` file). If not cheap, just tell the user the license. Never block "done" on this.

## License default

`-l cc0,pd` returns only no-attribution-needed images — safe to ship as-is. `-l any` widens to CC-BY etc.; the script records the credit in `attribution.json` — surface it if easy.

## When results are thin

Empty or poor results → broaden the query, switch source (per `SOURCES.md`), or try `-l any`. A source error → try another source. The script reports state and exits nonzero only on total failure.

## Higher rate limits (optional)

The skill works keyless by default. If you hit rate limits (especially Openverse's 200/day anonymous cap), run the setup wizard:

```bash
bash SKILL_DIR/setup.sh
```

It walks you through getting free Openverse OAuth credentials (200/day → 10,000/day) and optional Wikimedia bot auth (higher concurrency). Credentials are stored in `~/.config/image-fetcher/.env` and read automatically — no env vars or code changes needed. To revert to keyless mode, delete that file.

## Examples

```bash
# Preview without downloading
uv run SKILL_DIR/fetch.py "modern office"

# Fetch 5 to scratch, then copy the winner into the project
uv run SKILL_DIR/fetch.py "modern office" -d
cp /tmp/opencode/image-fetcher/02_open-plan-desk.jpg ./public/hero.jpg

# NASA, place directly into the project (skip scratch)
uv run SKILL_DIR/fetch.py "mars surface" -s nasa -d -o ./public/hero

# Wikimedia, allow CC-BY, full-res
uv run SKILL_DIR/fetch.py "eiffel tower" -s wikimedia -l any --full -d
```
