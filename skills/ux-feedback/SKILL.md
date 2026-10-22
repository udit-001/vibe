---
name: ux-feedback
description: Communicate system status so users know every action registered and every state change explained itself — action acknowledgment, busy/progress states, optimistic UI, backstage signals, externally-driven changes. Use when the user says an action "doesn't do anything" or feels unacknowledged, asks where feedback or progress is missing, invokes Nielsen's heuristic #1, or wants status communication added. Wording of status copy belongs to ux-clarity; recovery after failure belongs to ux-resilience.
---

# System status visibility

Nielsen's heuristic #1: keep users informed through appropriate feedback within reasonable time. Informed users steer toward their goal, avoid double-taps, and trust the product. The failure mode is the **silent spot** — an action or state change the interface doesn't reflect — and it reads to users as "the system ignored me."

## Scope

- **In scope**: the *behavior* of communicating state — what to show, when, and where.
- Wording of status, loading, and progress messages belongs to ux-clarity; what happens when the action *fails* belongs to ux-resilience (recovery, rollback UX); where a feature first *appears* belongs to ux-onboarding.
- The user names the target; if none, the current view or flow being worked on.

## 1. Map the state loop

Walk the target and list every **action** (user input the UI accepts) and every **arrival** (state change the user didn't cause: server updates, other users, elapsed time, async completion). For each, note the expected visible response and its latency class:

- **Instant** (<100ms) — can be shown immediately
- **Busy** (100ms–3s) — needs a working indicator
- **Long** (3s+) — needs progress or an expectation, plus an escape hatch
- **Background** — completes without the user waiting

Mark every action with no defined response as a silent spot, every arrival with no defined presentation as an unexplained change.

**Done when** every action and every arrival in the target is accounted for — acknowledged, or flagged as a silent spot or unexplained change.

## Judge the layer before fixing

A feedback gap is usually a symptom of an undecided decision below the surface. For every gap the map surfaces, name the layer that owns the fix, and patch only surface-owned gaps at the surface:

- **No state to show** — nothing in the model passes through "saving", "syncing", "pending". Intermediate action states are conceptual-model decisions; settle them there before styling any indicator.
- **Timing unknown** — whether the wait is seconds or minutes is an engineering fact. State the UX requirement and carry the latency question to engineering; a guessed duration lies.
- **Optimistic vs pessimistic undecided, post-action state unnamed** — the "then what?" after submit is a flow-structure decision. Breadboard it first — a text outline of places, affordances, destinations — before designing any indicator.
- **A backstage signal serves no decision** — if the signal exists only to be shown, it's noise. Whether surfacing it moves any outcome is a strategy-layer call; hiding it is a legitimate verdict.
- **The response exists but goes unseen** — a hierarchy question this layer owns: decide what must be noticed and rebuild prominence; the words themselves stay with ux-clarity.

When the fix needs a method this skill doesn't carry — state modeling (conceptual model) or flow breadboarding (interaction flow) — reach the `layers-*` skills if installed. When they're not, refuse the surface patch: state the settled UX requirement ("the user must see X, informed by Y, within N of Z") and carry it as a named open question into the design/engineering conversation.

## 2. Acknowledge every action

Every action from the map produces visible feedback within 100ms of the input:

- **Input states**: pressed, selected, toggled-on, drag-over — the control visibly took the event.
- **Optimistic UI** for low-risk actions (reactions, reordering, toggles): the new state shows immediately and reverts on failure — the revert path is ux-resilience's to design, this skill requires only that optimistic actions are flagged for one.
- **In-flight guard**: a submitting button shows its busy state and can't take a second click.
- **High-latency only**: don't decorate instant operations with spinners; acknowledgment is the response, not a ritual.

**Done when** no silent spot remains — every action in the map has a visible response within 100ms.

## 3. Show progress for anything over 1s

Match the indicator to the wait:

- **1–3s**: skeleton or spinner; say what's busy when the cause isn't obvious at a glance.
- **3s+**: percentage, stage name, or "this usually takes N seconds" — pick the honest one; long waits also get a Cancel or close.
- **Background completion**: announce it (badge, toast) when the user may have moved on; silent completion is an unexplained arrival.
- **Never** bound an unbounded spinner: if duration is unknown, show activity and an escape hatch rather than a fake percentage.

**Done when** every Busy and Long item in the map has an indicator matched to its expected wait, and every Background item has a completion signal.

## 4. Surface backstage state only when it changes the decision

Most internals (asset loading, retries, server topology) should stay hidden. Concealed state exactly when it would otherwise leave the user acting blind:

- **Scarcity**: "only 2 left", sold-out sizes shown crossed out — moves the action from "someday" to "now".
- **Thresholds**: progress-to-goal ("$15 more for free shipping") shows the distance, not just the fact.
- **Limits**: remaining quota, storage, seats — shown before the wall, not at it.

**Done when**: every surfaced signal names the decision it changes, and every candidate signal below that bar is hidden.

## 5. Explain every arrival

State the user didn't cause arrives announced, never silently applied:

- **What changed**: the item, its new state ("this session expired").
- **Why it changed**: brief and causal ("the store stopped selling this") — no internals.
- **User control**: let the user act on it — remove, replace, keep visible. Out-of-stock wishlist items stay listed with their status; silent removal destroys trust in the list itself.
- **Recovered state**: if the user returns to changed state (saved draft moved, items re-ordered), the first view says so.

**Done when** every arrival from step 1 explains what, why, and offers control — none applied silently.

## Verify

Re-run the map from step 1 against the changed UI: walk each action at normal speed and again with the network throttled, trigger each arrival (kill the connection, expire a token, complete a background task). Each expected response fires within its latency class.

**Done when** the map runs clean — no silent spot, no unexplained change, no indicator lying about duration.
