# Repository analysis

Reach here only when llms.txt yields nothing (Step 3).

## Find and verify the repo

Search `"{name} github repository"`, or read the package registry for the official link (`npm info {pkg} repository`, PyPI, crates.io, etc.). Trust it only when it is official: org matches the project, commits are recent, and the README links back. Otherwise treat it as community and say so in the report's Gaps.

## Pack with Repomix

```bash
git clone --depth 1 {url} /tmp/docs-analysis
cd /tmp/docs-analysis
repomix --output repomix-output.xml      # install once: npm i -g repomix
```

Read the output and extract `README.md`, `docs/`, `examples/`, `CONTRIBUTING.md`.

## When the repo is too big, or Repomix fails

Scope instead of packing everything:

```bash
repomix --include "docs/**,README.md,*.md" --output docs.xml
repomix --exclude "*.png,*.jpg,*.pdf,dist/**,node_modules/**" --output repomix-output.xml
```

For repos >1GB or binary-heavy, skip Repomix entirely and **fan out** over the key files (`README`, `docs/`) directly.

## No repo at all

Descend to research: fan out over the package registry, the official site, and recent community sources, and mark the coverage as fragmented in Gaps.