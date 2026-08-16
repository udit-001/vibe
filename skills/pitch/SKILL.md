---
name: pitch
description: "Write the document that sells a project to a skimmer — READMEs, repo descriptions, landing-page heroes, store listings, taglines. Use when the user wants a README rewritten, audited, or made non-technical; landing or store copy written; or AI-sounding writing scrubbed from project docs. Scope is the document a stranger reads before deciding to care: copy inside the product, page layout, and companion-doc accuracy (grounding docs/ trees against code) each belong to other skills."
---

# Pitch documents

A pitch document has one job: win a **skimmer** — a reader who gives it five
seconds, then maybe thirty. The README, the repo description, the landing
hero, the store blurb are all the same object at different sizes. The skill
is writing to those **skim budgets** so each one lands.

Leading words: the **skimmer** (who you're writing for), the **pitch** (the
one-line why that survives the skim), **grounded** (the pitch's claims
verified against the product before they ship), and the **budgets** (what
survives at each reading depth).

## 0. Scope the document

Three questions settle everything. Look the answers up, don't ask:

- **Who's the reader, and what's the wanted action?** Derive it from the
  product: a bulb-app's reader installs an APK, a CLI's pastes a curl,
  a repo-card reader stars or scrolls past. Contributor content (build
  steps, architecture trees, make tables) moves behind one pointer line.
- **What's the real action path?** Verify it exists before documenting it:
  `gh release view` for artifacts, `install.sh` for the script, `go.mod`
  for the module path. No releases and an unqualified module means
  `go install` can't work — document what's true and flag the gap.
- **Is the repo safe to work in?** If the working tree holds personal files
  (payslips, credentials, PAN-named archives) and the repo is public, check
  `git ls-files` and `.gitignore` first and report leaks.

**Done when** reader, action, and safety are settled — one line each to the user.

## 1. Ground the pitch's claims

The pitch's own claims must be **grounded** — verified against the product
before the copy ships. This is what makes the rewrite durable instead of
plausible:

- Feature bullets ↔ actual commands, flags, routes, views (`ls internal/`,
  `grep` the flags, read the skill files)
- Action path ↔ artifacts that exist (`gh release view`, module path,
  `install.sh`)

Grounding stops at the pitch document. If companion docs (AGENTS.md,
docs/) have drifted — stale architecture trees, dead entries, wrong
counts — that's separate accuracy work: report the drift to the user and
let them commission it, or hand it to a docs task.

**Done when** every claim the pitch makes is checked against the code and
infrastructure. Drifted companion docs are reported, not repaired here.

## 2. Write to the budgets

The section order follows the budgets — whatever the artifact's size:

- **Five seconds:** title + pitch. The pitch carries the product — what it
  does, for whom, and the differentiator ("runs locally", "no cloud").
  Mechanism ("server-rendered Go monolith", "MVVM") never leads.
- **Thirty seconds:** bold verbs + action path. Install before features —
  a skimmer who wants in should trip over the path in. Features as
  `- **Bold verb** — one line.` — the skimmer reads the verbs and gets the
  product; headed prose paragraphs are for companion docs.
- Bullets say **what the reader gets**, not what the code has: "strips your
  phone number and email before the resume reaches an AI", not
  "deterministic redaction module".
- A **data/privacy** line whenever "local" is a real claim; skip it when it isn't.
- One **pointer line** to contributor docs if they exist; skip when starting
  from scratch — a fresh project's README is the honest dev setup, clearly
  labeled, not a manufactured installer.

**Skim-test the draft**: read only the title, pitch, and bold verbs top to
bottom. If that doesn't sell the product, the rewrite isn't done.

**Done when** both budgets are satisfied by pure top-down reading and the
skim test passes.

## 3. Scrub AI tells

A pitch written by an agent will sound like one. Audit the draft against
[TELLS.md](TELLS.md) — rule-of-three stacks, reassurance tails, smoothed
generics ("and more" where a real list exists), promotional register. The
deeper fix is always **specificity**: replace the smoothed phrase with the
actual enumeration, not a synonym swap.

**Done when** the draft passes the checklist with each tell removed or
justified aloud (a triple that is the literal product scope may stay).

## GitHub repo metadata (reference)

A README rewrite on GitHub usually pulls its metadata along — the user
benefit rides along with the core work. Reach for this when the rewrite
touched a GitHub-hosted repo:

The repo description is the **zero-second** budget — what shows on cards
and search. Same pitch discipline, ~100 chars: lead with what it does
("Track every job application, let your AI write the paperwork"), not
category nouns ("AI Guided Learning Workspace"); differentiator hook in
the second sentence ("Runs locally, no account"); no repeated words, no
jargon, no truncation at 100 chars.

Topics via `gh repo edit --add-topic`: product words for discovery (the
job, the domain, the integrations), stack words for hackers (`golang`,
`sqlite`), `local-first`/`self-hosted` when the privacy story is real.
Check what exists first with `gh repo view --json repositoryTopics`.

Offer the update; apply it when the user accepts. Both must match the
pitch the README now makes.
