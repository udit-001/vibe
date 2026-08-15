---
name: ux-clarity
description: Improve interface microcopy — labels, buttons, instructions, helper text, validation, error, success, loading, and empty-state copy. Use when the user asks to fix wording inside the product, says copy is confusing or unclear, or wants labels, errors, or empty states rewritten. For interaction-level clarity, not marketing pages (see ux-onboarding for first-run flows) or visual polish (see impeccable).
---

# Microcopy clarity

Make interface text *invisible*: users take in the meaning and never notice the words. Copy that draws attention to itself is broken copy. Fix it.

## Scope

- **In scope**: labels, buttons, instructions, helper text, validation, error, success, loading, confirmation, empty-state, and navigation copy — anything a user reads inside the product.
- **Out of scope**: page-level marketing copy, and first-run flow structure (ux-onboarding — hand the target off there if it's a flow).
- The user names the target; if none is named, survey the copy of the view being worked on (screen, dialog, or form).

## 1. Assess the copy

Walk every piece of text in the target and classify it against the seven clarity problems:

1. **Jargon** — a term a new user won't know
2. **Ambiguity** — more than one reading possible
3. **Passive voice** — "Your file has been uploaded" vs "We uploaded your file"
4. **Length** — wordy where short works, or so terse the meaning is lost
5. **Assumptions** — knowledge the user hasn't got
6. **Missing context** — the user can't tell what to do or why
7. **Tone mismatch** — formality that doesn't fit the moment (error vs success)

Gather per piece: who reads it (technical level), their mental state at that moment (stressed on error, confident on success), the action you want them to take, and any constraint (space, length limits).

**Done when** every piece of copy in the target is classified against all seven problems — none left unexamined.

## 2. Plan the fix

Before rewriting, settle each in one line:

- **Primary message** — the ONE thing the user needs to know
- **Action** — what they should do next (or explicitly nothing)
- **Tone** — how the moment should feel (helpful, apologetic, encouraging)
- **Constraints** — length limits, brand voice, localization

**Done when** all four are written down for the target.

## 3. Rewrite, area by area

Apply the area patterns to every piece classified in step 1. Standing rules: state what happened in plain language, tell the user what to do about it, blame the field not the user, and keep the label on the field — placeholders are for format examples, not for carrying the label.

### Errors
Bad: "Error 403: Forbidden" → Good: "You don't have permission to view this page. Contact your admin for access."
Bad: "Invalid input" → Good: "Email addresses need an @ symbol. Try: name@example.com"

### Form labels & instructions
Bad: "DOB (MM/DD/YYYY)" → Good: "Date of birth" (placeholder shows the format)
Bad: "Enter value here" → Good: "Your email address" or "Company name"
Instructions go before the field; explain why you're asking when it isn't obvious; keep required markers unambiguous.

### Buttons & CTAs
Bad: "Click here" | "Submit" | "OK" → Good: "Create account" | "Save changes" | "Got it, thanks"
Verb + object; match the user's mental model; "Save" beats "OK".

### Help text & tooltips
Bad: "This is the username field" → Good: "Choose a username. You can change this later in Settings."
Add value beyond the label; answer the implicit question (what is this / why do you ask); link to docs when it runs long.

### Empty states
Bad: "No items" → Good: "No projects yet. Create your first project to get started."
Say why it's empty when it isn't obvious, show the next action, make it a doorway not a dead end. (Flow structure belongs to ux-onboarding; this is the wording.)

### Success messages
Bad: "Success" → Good: "Settings saved! Your changes will take effect immediately."
Confirm what happened, say what happens next when it matters, match the emotional weight of the win.

### Loading states
Bad: "Loading..." (for 30+ seconds) → Good: "Analyzing your data... this usually takes 30-60 seconds"
Set the time expectation, say what's happening when it isn't obvious, offer an escape hatch ("Cancel") when the wait is long.

### Confirmation dialogs
Bad: "Are you sure?" → Good: "Delete 'Project Alpha'? This can't be undone."
Name the specific action, state the consequence, label buttons with the action ("Delete project", not "Yes"), and reserve confirmations for genuinely risky actions.

### Navigation & wayfinding
Bad: "Items" | "Things" | "Stuff" → Good: "Your projects" | "Team members" | "Settings"
Be specific, use the user's vocabulary not internal jargon, keep hierarchy and current location (breadcrumbs) legible.

**Done when** every piece classified in step 1 is rewritten against its area's patterns — none skipped.

## 4. Run the six rules over the rewrite

Re-read every rewritten piece against the rules — this is the check, not a summary:

1. **Specific** — "Enter email", not "Enter value"
2. **Concise** — the shortest clear form
3. **Active** — "Save changes", not "Changes will be saved"
4. **Human** — "Oops, something went wrong", not "System error encountered"
5. **Helpful** — what to do next, not just what happened
6. **Consistent** — one term, repeated; never vary for variety

**Done when** every rewritten piece passes all six rules, and a piece that still needs a sentence to explain gets fixed rather than explained.
