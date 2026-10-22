# Code comments

> Antislop reference: comment hygiene -- filter out comments that read as generically AI (decorative, restating the obvious, stiff, loud) while preserving the comments that carry real information. Load alongside the core (`SKILL.md`).

Every entry below has the same shape: **Tell** (the pattern), **Why** (why it reads as slop), **Fix** (what to do instead), with the governing core rule cited as R-XX.

**Scope guardrail:** this reference only modifies comments. Never modify executable code, identifiers, imports, formatting, indentation, whitespace, control flow, or logic. When in doubt, leave the code untouched -- and resolve doubt about a comment the other way, toward removal.

The core's Delivery Gate remains the gate; the "Code Comment Checklist" at the end is the comment-specific supplement to run alongside it.

## Comments That Add Nothing

### Decorative Separators

- **Tell:** banner comments built from repeated characters, ALL CAPS labels, or box drawing around a section name: `// =======================` around `Authentication`, `// -------- WORKFLOW --------`, or a `/* ---- ROUTES ---- */` header.
- **Why:** the decoration is the message. A label wrapped in `=` or `-` signals "AI made this" without adding information, and ALL CAPS reads as shouting.
- **Fix:** replace with a single plain line, or remove entirely if the label adds nothing (R-31).

### Restating the Obvious

- **Tell:** a comment that repeats what the next line or declaration already shows, like `// Initialize the variable` above `let count = 0`, `// User class` above `class User {}`, `// Validate user` above `function validateUser()`, or `const userAge = 25; // User age is 25`.
- **Why:** it doubles the reading load without adding anything. The code already says it; the comment just repeats it.
- **Fix:** remove and leave the line of code alone.

### Workflow Narration

- **Tell:** comments that narrate the flow step by step, like `// Step 1: Validate input`, `// Step 2: Process request`, `// Step 3: Return response`, or `// First...`, `// Next...`, `// Finally...`.
- **Why:** the control flow is visible in the code itself. Numbering it reads as a checklist, not an explanation.
- **Fix:** remove. If the flow is genuinely hard to follow, that is a structure problem, not a missing comment problem.

### Empty Labels

- **Tell:** generic labels with no information behind them: `// Main logic`, `// Core logic`, `// Business logic`, `// Helper function`, `// Entry point`, `// Error handling`, or `// Note: This is important.` / `// Important: Please read.`
- **Why:** the label names a category, not a fact. "Main logic" tells the reader nothing they could not infer from the code.
- **Fix:** remove unless the label carries specific information. "Note: retries happen only on 5xx" earns its place; "Note: this is important" does not.

### Vague Placeholders

- **Tell:** comments that promise future work without saying what: `// TODO: Improve this`, `// Future improvements`, `// Additional optimization can be added here`, `// Add more validation`.
- **Why:** a vague TODO is noise. It names a feeling (this could be better) instead of a task (what, and why).
- **Fix:** remove. Keep a TODO only when it names a specific task with enough context to act on.

### Signature Echo

- **Tell:** documentation that only restates the signature, like a JSDoc block that repeats `@param price The price.`, or a docstring that echoes every parameter back verbatim ("price: The price to total.").
- **Why:** docs that echo the signature add length, not understanding. The reader learns nothing new.
- **Fix:** simplify or remove the echo. Keep documentation that explains business rules, edge cases, assumptions, algorithms, limitations, side effects, API behavior, or security implications. Never strip real documentation.

### Decorative Emoji

- **Tell:** emoji used as decoration in comments, like `// ✅ Validation` or `// 🚀 Performance`.
- **Why:** emoji is visual noise in code, and the specific set (✅, 🚀, 🔒) is the AI default vocabulary.
- **Fix:** replace with plain English, or remove if the label adds nothing.

### Commented-Out Code

- **Tell:** executable code commented out and left in place, with or without a note like `// Removed for now` or `// Keeping this just in case`.
- **Why:** version control already keeps history, so a corpse is dead weight the reader must parse and skip, and its presence turns the file into a junk drawer.
- **Fix:** delete. If the removal needs a record, the commit message is the record.

### Suppression Directives

- **Tell:** suppressions with no reason attached: `// eslint-disable-next-line`, `// @ts-ignore`, `# type: ignore`, `# fmt: skip`, `# pylint: disable=...`, `# noqa`.
- **Why:** a suppression is a claim about the rule, not about the code. Bare, the reader cannot tell a faulty rule from a real bug being silenced.
- **Fix:** keep the suppression when the suppressed rule is genuinely faulty or style-only, and say why on the same line (`// eslint-disable-next-line no-useless-escape -- pattern is built from user input`, `# noqa: E501 -- log message must stay on one line`). Formatting suppressions (`# fmt: skip`, `# fmt: off`) survive when the formatter is provably wrong, such as preserving aligned data literals. When the suppression guards real correctness, leave it in place and flag the guarded symbol with a one-line `// MUST FIX:` note naming the change that would make the suppression unnecessary; the suppression itself stays until that fix lands.

### Loud Keep-Claims

- **Tell:** comments that assert their own importance to survive review: `// IMPORTANT: do not remove`, `// too risky to change`, `// fine for now`.
- **Why:** the assertion is the comment vouching for itself. A real constraint stays obvious after reading the nearby code; a fake one only sounds important.
- **Fix:** verify the claim against the code it guards before preserving it. A claim that survives the check earns plain wording without the label; one that does not is noise like any other. For a verified constraint, a comment is the weakest enforcement available: prefer the cheapest in-scope encoding -- a type, a runtime assertion, a test, a lint rule -- and delete the comment once the constraint enforces itself. Encode only with the reader's approval on the shape; otherwise keep the claim as plain wording.

### End Markers

- **Tell:** comments that only mark the end of a block, like `} // end if`, `# End of function`, or `// End processOrder`.
- **Why:** the closing brace already ends the block. The marker exists out of habit, not need.
- **Fix:** remove. In the rare case an end marker genuinely helps a long file, keep it only where it prevents confusion, not as a habit.

## How It Should Read

### The Over-Explained Comment

- **Tell:** one comment that runs on for several lines, stacking reasons, context, and history around a fact that fits in one line: a four-line block explaining that a stub sits on PATH, which release introduced the workaround, and what broke before it. Every sentence is true. The length is the tell.
- **Why:** a person leaves a note, a generator writes a case. Padding a one-line fact into a paragraph, building a "because X, so Y, and therefore Z" chain, or citing the issue number and the version that fixed it are the same flourish as any other AI pattern, and they bury the one line that matters under the ones that do not.
- **Fix:** cut to the constraint alone: one line, two at most, never three. Keep the platform trap, the silent failure, the protocol rule, the performance cost. Drop the issue number, the version history, and the reasoning chain.

### Line-by-Line Narration

- **Tell:** a comment on every trivial statement, narrating each line as it is written: `// Initialize count`, then `// Loop items`, then `// Get item`, then `// Increment`, then `// Return result`.
- **Why:** when every line is commented, none of the comments matter. The reader has to check each one to find the one that carries meaning.
- **Fix:** write one concise comment per logical block instead of one per line. If the block needs no comment, write none.

### Stiff or Loud Wording

- **Tell:** comments that sound formal, long, or shout: "This function is responsible for validating whether the supplied credentials are valid before continuing with the authentication process", or `// MAIN LOGIC` in caps.
- **Why:** formal and loud wording reads as generated, not as an engineer leaving a note for the next person.
- **Fix:** write short, sentence-case lines in a natural developer voice: `// Validate credentials before issuing a token.` Good comments explain why, not what, and they stay short.

## Not a Ban (preserve these)

Never remove comments that explain:

- business logic and intent
- architectural decisions
- security considerations
- performance trade-offs
- concurrency behavior
- protocol details
- API contracts
- docstrings that serve as API surface: in Python, `help()`, Sphinx, and doctests read them, so a module's or public function's docstring is an interface, not a comment
- workarounds
- edge cases and assumptions
- licensing and legal notices

Example that must stay:

```js
// Stripe may retry webhook deliveries for up to three days.
// Ignore duplicate events using the event ID.
```

A comment earns its place when it explains something the code does not already show: the reason, the constraint, the non-obvious behavior.

The keep-list draws its line by ownership. A constraint from outside the codebase -- a platform trap, a vendor quirk, a protocol rule, an external dependency -- is preserved. A surprise the codebase created for itself is not: a workaround comment describing our own tangled code is a symptom, and deleting it should leave the problem visible to the next reader. When removal does leave something genuinely surprising, add a one-line `// MUST FIX:` note naming the symbol and the change that would make the comment unnecessary (rename, extract, retype), so its next reader gets a task instead of a sermon. The fix itself stays out of scope.

Earning a place says what may stay, never how long it may run. A workaround note is one line about the workaround, not a paragraph about it. The example above is two lines because two facts are real, not because two lines is a target. This list is the most common reason a comment survives a review it should not: the content is legitimately valuable, so the length goes unexamined. Value is not length. And a comment that fails the keep-test is deleted, not compressed: shortening an unearned comment produces a shorter unearned comment.

## Code Comment Checklist

Run these alongside the core Delivery Gate when the task touches comments. All answers must be **yes**:

- [ ] Does every comment add information the code does not already show? (R-31)
- [ ] Do the comments avoid decorative separators, ALL CAPS banners, and box-drawn headers?
- [ ] Do the comments avoid restating the obvious line, declaration, or signature?
- [ ] Do the comments avoid step-by-step workflow narration?
- [ ] Do the comments avoid empty labels and vague TODOs that name no task?
- [ ] Do the comments avoid decorative emoji and end markers?
- [ ] Is the comment density one per logical block, not one per line?
- [ ] Is every comment one line, or two only when the second carries a new fact?
- [ ] Do the remaining comments read short, natural, and in sentence case?
- [ ] Are commented-out code blocks deleted, with history left to version control?
- [ ] Do suppressions keep only faulty or style-only rules, with the reason on the line?
- [ ] Are keep-claims (`IMPORTANT`, `do not remove`) verified against the code they guard before being preserved?
- [ ] Is the scope guardrail held: only comments changed, the code untouched?
