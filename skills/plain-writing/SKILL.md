---
name: plain-writing
description: Write docs, READMEs, RFCs, PR descriptions, and commit messages a tired engineer understands on the first read.
disable-model-invocation: true
---

# Plain writing

A prose standard for deliverables the reader must act on: docs, READMEs, RFCs, PR descriptions, commit messages, changelogs. The reader is a tired engineer reading once. Every rule below serves that person.

Boundaries: the **antislop** skill owns the AI-tell catalog and UI copy; apply its copywriting reference to everything this skill touches, and do not re-list tells here. The **pitch** skill owns the document that sells a project to a skimmer. Chat replies follow the Focus output style. This skill owns the prose itself.

## Three rules above the rest

- **Cut every word that does no work.** If the sentence survives without a word, the word goes.
- **Use the short, everyday word.** "Use", not "utilize". "Help", not "facilitate". A long word has to buy its length with precision.
- **When a rule makes a sentence worse, fix the sentence another way or leave it alone.** A sentence that follows every rule and sounds machine-written has failed.

## The codebase is the word list

Write the real symbol, file, flag, or command name, never a synonym or a description of it. Use the words a developer would say out loud: "move", "delete", "a budget that only decreases", not coinages standing in for them. A named pattern is fine when the doc defines it the first time it appears.

## Pick the mode first

One document, one mode. Two questions pick it: does the content serve doing or understanding, learning or work?

- Action + learning: **tutorial**. The learner's success is your job. Open with what they will build, not what they will "learn". Every step produces a visible result, and you say what they should see: the expected output, the log line. Explanation is one clause and a link.
- Action + work: **how-to**. Solve a problem a person has. Assume competence, skip teaching. Steps and forks only: no digressions, no background, no completeness for its own sake -- link those. Name the guide by the task: "How to calibrate the radar array", not "Radar array calibration".
- Understanding + work: **reference**. Only describe. Dry, complete, sure: facts, options, limits, errors, no hedging. Mirror the structure of the thing described so code and docs navigate together.
- Understanding + learning: **explanation**. One bounded topic, readable away from the product, anchored on a real why question. Design decisions, history, constraints, alternatives. Opinion is allowed here and nowhere else.

Mixing modes is a defect, not a convenience: no reference tables inside a tutorial, no hand-holding inside reference, no arguing inside a how-to. Split and link instead.

## Write sentences to the reader

- Talk to the reader as "you", in the present tense. "Will" only for things that genuinely happen later.
- Say who does what: "the compiler checks", not "is checked". Passive only when the actor is unknown or beside the point.
- Write instructions as commands: "Click Submit." Put the condition before the instruction: "To delete the document, click Delete."
- Put the common case first. Exceptions after.
- Sound like a knowledgeable friend. No "please" in instructions, and never "simply", "easy", or "quickly" in a procedure. If it were simple, the reader would not be here.
- Headings carry the point, not just the topic: "Pick the mode first", not "Modes". Sentence case. A task heading is a bare verb phrase; a concept heading is a noun phrase. One h1 per page, no skipped levels.
- Numbered lists for sequences, bullets for everything else. Introduce a list with a complete sentence. Keep items parallel.
- Link with words that say where the link goes, never "click here". Prefer a sentence of context on the page over a link off it.

## One thought per sentence

- One instruction per sentence. Split instructions past about 20 words and other sentences past about 25.
- Put the warning before the step it guards: "If the port is taken, the server exits", then the step.
- Keep "the" and "a": "Remove backup file" reads two ways; "Remove the backup file" reads one.
- Keep words like "only" and "not" next to the word they change: "only fails on growth" and "fails only on growth" differ.
- Break up long noun strings: "the proto import budget check script" becomes "the script that checks the proto-import budget".
- Make every "it", "they", and "this" point at one obvious thing. Repeat the noun when in doubt, and never let "this" point at a whole clause.
- Call each thing by one name everywhere. A doc that says "the gate", "the ratchet", and "the budget check" for one thing teaches three things.
- Say which parts "and" or "or" joins when a sentence can group two ways: "both X and Y", "either X or Y", "if X, then Y".
- Periods, not semicolons. Keep the small words that show structure ("that", "which") even when word count could drop them.

## Vary the rhythm

A document can obey every rule above and still read machine-written: every sentence clipped, no view anywhere, nothing specific.

- Mix sentence lengths on purpose. Short sentences land a point; longer ones carry a fact with its condition or consequence. One thought per sentence does not mean one length per sentence.
- Have a view where the mode allows it. Explanation weighs trade-offs, so say what you make of them instead of listing pros and cons. Reference stays dry.
- Be specific over sterile: not "schema changes can cause issues" but "a column rename fails the build".

## PR descriptions and commit messages

They are writing too; every rule above applies except the mode compass. A PR body is a briefing a reviewer reads in under a minute:

- First line: what changed and why, in one sentence.
- Then: the one or two spots that need human eyes, and anything you did not verify. Separate "I ran this" from "I believe this".
- Do not paste logs, SHA lists, or metric dumps. Link them.

## How to apply

1. **Pick the mode** for the document before writing a sentence.
2. **Draft**, applying the sentence rules and the codebase word list.
3. **Audit**: read it aloud; run the antislop copywriting reference over it. A sentence you stumble on reading aloud is not done.
4. **Final**: fix what the audit surfaced, then check the checklist below.

Done when every claim is checkable, every instruction is executable on the first read, and the mode never shifts mid-document.

## Worked example

Before:

> Configuration of the theme parameters is performed via the config panel. Note that it's important to remember that enabling dark mode, which changes the palette applied across all components, should only be done after the tokens have been migrated.

After:

> Set theme parameters in the config panel. Enable dark mode only after migrating the tokens; it changes the palette for every component.

## Checklist

- [ ] One mode per document, and the mode fits the reader's job
- [ ] Every instruction is a command, executable on the first read, with the condition before the step
- [ ] Every fact names its actor and its real symbol, path, or flag from the codebase
- [ ] No sentence over ~25 words carrying two thoughts; no noun strings, no ambiguous "it"/"this"
- [ ] One name per concept across the document; sentence-case headings that carry the point
- [ ] Sentence lengths vary; specific facts over sterile claims; no unverified numbers (antislop R-17)
- [ ] PR bodies state what changed, what needs eyes, and what was not verified, within a one-minute read
