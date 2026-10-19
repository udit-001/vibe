---
name: bug-hunt
description: Hunt bugs in code before they are reported. Use for "find bugs", "bug hunt", "what's broken here", a sweep before a PR, release, or migration, or "does this bug happen anywhere else?" — a sweep, not one failure to root-cause.
---

# Bug hunt

Hunt genuine, demonstrable bugs in the given scope. The deliverable is a short list of findings the user would actually fix, each backed by evidence.

## Scope

Resolve the scope from the argument:

- A path or module -> that code plus its direct callers and callees.
- "recent changes", or no argument in a git repo -> `git diff` against the default branch, or the last few commits if the branch is clean. Recently changed code is where bugs concentrate.
- No argument and no recent changes -> pick the highest-risk area (see the hotspot map) and say which you picked.

Keep the scope small enough to read thoroughly. A deep pass over one module beats a shallow pass over ten.

## Method

### 1. Pick the entry

Two ways in. Name the one you took, in one line.

**Hotspot map** — no known defect; find where bugs are likely to live:

- **Boundaries**: parsing, serialization, user input, external APIs, file and network I/O, unit conversions, timezone and encoding handling.
- **Concurrency**: shared mutable state, async ordering assumptions, locks, caches, anything with race potential.
- **Arithmetic and indexing**: off-by-one candidates, integer overflow and truncation, division, float comparison, empty collections.
- **Error paths**: catch blocks that swallow, cleanup skipped on one path, partial-failure states, retries without idempotency.
- **State machines and invariants**: code that assumes an order of operations or a field being set; find who can violate it.
- **Recent churn**: `git log --stat` for files changed often or by many hands, and lines fixed repeatedly.

**Pattern sweep** — a defect already reported or fixed; the question is where else it lives:

- State the defect as a pattern: the invariant it violated, and the operation that violated it (parse, copy, lock, diff, index, compare, serialize).
- Grep the pattern's siblings: the same operation on the same shape of data, under the same assumption.
- Verify each sibling as a finding (step 4). The known instance is the reference shape for its repro.

Step 1 is done when you can name the scope and the entry in one line: "hotspot map of `src/parser/` — boundaries and error paths", or "pattern sweep of the substring index bug ID-412".

### 2. Read adversarially

For each hotspot or sibling, ask "what input or sequence of events makes this wrong?" instead of "what does this do?":

- Trace data flow end to end: where a value is produced, every transformation, where it is consumed. Mismatched assumptions between producer and consumer are the richest seam.
- Check every function against its callers: pass null, empty, negative, huge, unicode, and concurrent calls, and find which the function mishandles.
- Check the contract, not just the code: compare behavior against docstrings, type hints, comments, tests, and names. A `getOrCreate` that can return null is a bug even when every line is correct.
- Look for asymmetry: a lock taken but not released on one path, a resource opened without close on error, pairs (start/stop, push/pop, encode/decode) that fail to mirror each other.
- For diffs, read the surrounding unchanged code too: most regressions are a changed line invalidating an assumption in an unchanged one.

### 3. Triage suspicions

For each suspicion, find the concrete input or event sequence that triggers it. A suspicion with no describable trigger is not a finding yet — dig until you find one, or drop it. Hold each to three bars:

- **Reachable**: the triggering input can occur in practice. Dead code and impossible inputs fail here.
- **Wrong**: the behavior differs from what the contract, caller, or user expects.
- **Not deliberate**: check git blame, comments, and tests. A test asserting the behavior makes it a design decision; note it separately.

### 4. Verify before reporting

This step turns a suspicion into a finding. Demonstrate it:

- Write and run a minimal repro: a small script, a REPL session, or a failing test that exercises the exact trigger.
- Where a repro is impractical (production data, hardware, a race window), trace the exact code path line by line instead, quoting the lines and the triggering values.
- When the repro passes, the suspicion was wrong: drop it, or report it downgraded and labelled unverified.

Step 4 is done when each finding carries one of:

- [ ] **Repro output** — the command you ran and its output, going red on the trigger.
- [ ] **Quoted trace** — the `file:line` path with the triggering values, for triggers a repro cannot reach.

Report fixes only when the user asks for them; the default deliverable is the findings.

## Report format

Order findings by severity: data loss, corruption, and security first; then wrong results; then crashes; then degraded behavior. For each:

```
### N. <one-line summary>  — <severity>  — <file:line>

**Trigger:** the concrete input or sequence that causes it.
**What happens:** observed or derived wrong behavior vs. expected.
**Evidence:** repro output, or the quoted code-path trace.
**Suggested fix:** one or two sentences, no patch unless asked.
```

Close with a "Checked but clean" line naming the hotspots or pattern-sweep areas that held up, so the user sees what was covered as well as what failed.

## The bar

Every finding names a trigger, a reachable path, and a demonstrated wrong result. Style, naming, and refactoring commentary stays out. Reachability is required, so a pattern scan that flags every `eval` regardless of context fails the bar.

That bar admits zero findings from a thorough pass as a valid, useful result — the "Checked but clean" line carries the coverage. Padding the list with speculation is noise, not thoroughness.