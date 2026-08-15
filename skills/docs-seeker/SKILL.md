---
name: docs-seeker
description: Discover and synthesize a library, framework, or API's technical documentation. Use when the user wants docs ("how do I use X", the latest API reference, llms.txt), or wants a GitHub repo's documentation analyzed.
---

# docs-seeker

Work a fixed **fallback chain** to its earliest success, then synthesize everything into one report. The chain is the steps below; each step's completion criterion tells you when it is genuinely done before you may descend.

## Steps

### 1. Identify the target
Pin down exactly one thing to document — a library, framework, repo, or website — and its version (default: latest). If the request is ambiguous, ask one clarifying question before fetching anything.

**Done when:** you can state the target and version in one line.

### 2. llms.txt-first
Construct the llms.txt URL directly and fetch it, before any web search. context7 is the fast path; official docs are the fallback. Patterns live in [llms-txt.md](references/llms-txt.md).

**Done when:** you hold a list of 0+ documentation URLs, **or** you've confirmed llms.txt doesn't exist (404 / empty) and are ready to descend to the repository step.

### 3. Repository
Only when llms.txt yields nothing: find the official repo, clone shallow, and pack with Repomix. If there's no repo either, fall back to research over the package registry, official site, and community. Details in [repo.md](references/repo.md).

**Done when:** you have packable source you can extract docs from, **or** you've confirmed no repo exists and are descending to research.

### 4. Fan out and synthesize
Fetch the discovered pages. One URL → fetch directly; 3+ → **fan out** across subagents in a single batch, then merge their returns by topic, deduped and in one voice (never paste raw per-agent dumps). Distribution and tool rules in [fanout.md](references/fanout.md).

**Done when:** every discovered URL that matters to the request has been read, and no requested topic is left uncovered.

### 5. Write the report
Deliver one markdown report:

```markdown
# [Library] [Version]

## Source
- Method: llms.txt / repository / research
- URLs / repo / commit
- Accessed: [date]

## [Topic sections — installation, usage, API, examples … as the request needs]

## Gaps
- What's missing, unofficial, or version-mismatched.
```

**Done when:** the report has a Source section, topic sections that answer the user's question, and an honest Gaps section.

## Rules

- **llms.txt-first**: construct and try an llms.txt URL before any search — a deterministic URL beats a search.
- **Fall forward, don't grind**: give each method at most ~2–3 attempts, then descend the chain; never retry the same endpoint.
- **Fan out, then merge**: parallelize reads, then dedupe and synthesize into a single voice.

When a step fails, apply the matching fix and drop down the chain — see [recovery.md](references/recovery.md).