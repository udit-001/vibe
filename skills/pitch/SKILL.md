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

Three questions settle everything. They split into two kinds:

- **Facts** — the agent's job. Look them up, then report them. What's
  the product? What's the reader's real action path — is there a published
  release, an install script, a resolvable module? Is the repo safe to work
  in (sensitive files tracked in a public repo)? Derive the reader and the
  wanted action from the product itself: a recipe app's reader taps an
  app-store link, a dev tool's pastes a curl, a feed-scroller decides to
  click through. Contributor content (build steps, architecture trees)
  moves behind one pointer line. If the obvious action path doesn't hold
  up, flag the gap — a pitch that promises an install the product can't
  deliver is a worse bug than a blank install section.
- **Decisions** — the user's job. Put each with your recommended answer.
  Is this a polish or a ground-up rewrite? Does the privacy / local-first
  claim go public? Should the repo description change too, or just the
  README? When a decision blocks downstream writing, surface it and wait
  one round.

Order them as the writing does: the audience decision blocks the action
path, the action path blocks the install section, the install section
blocks the skim-budget split. Settle an upstream premise before writing
into it.

**Done when** every fact is looked up and every decision either settled by
the user or recorded as an assumption the draft proceeds on.

## 1. Ground the pitch's claims

The pitch's own claims must be **grounded** — verified against the product
before the copy ships. This is what makes the rewrite durable instead of
plausible: walk each feature bullet to the thing that implements it — the
command, the route, the screen — and each action path to the artifact it
depends on.

Grounding stops at the pitch document. If companion docs (AGENTS.md,
docs/) have drifted — stale architecture trees, dead entries, wrong
counts — that's separate accuracy work: report the drift and let the
user decide whether to commission it.

**Done when** every claim the pitch makes is checked against the product.
Drifted companion docs are reported, not repaired here.

## 2. Write to the budgets

The section order follows the budgets — whatever the artifact's size:

- **Five seconds:** title + pitch. The pitch carries the product — what it
  does, for whom, and the differentiator ("runs locally", "no cloud").
  Mechanism ("server-rendered Go monolith", "MVVM") never leads.
- **Thirty seconds:** bold verbs + action path. Install before features —
  a skimmer who wants in should trip over the path in. Features as
  `- **Bold verb** — one line.` — the skimmer reads the verbs and gets the
  product; headed prose paragraphs are for companion docs.
- Bullets say **what the reader gets**, not what the code has: "locks
  your screen when you walk away", not "BLE proximity daemon".
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
("A garden planner that knows your local frost dates"), not
category nouns ("AI-Powered Gardening Workspace"); differentiator hook in
the second sentence ("Runs locally, no account"); no repeated words, no
jargon, no truncation at 100 chars.

Topics: product words for discovery (the job, the domain, the
integrations), stack words for the audience you want (the language, the
storage engine), and privacy terms when the privacy story is real. Check
what exists first — both must match the pitch the README now makes.

Offer the update; apply it when the user accepts. Both must match the
pitch the README now makes.
