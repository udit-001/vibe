---
name: ux-onboarding
description: Design or improve first-run onboarding, activation, guided setup, and adoption flows — getting users to their aha moment fast. Use when the user asks about onboarding, first-run experience, activation, guided setup, empty states as getting-started surfaces, or feature adoption. Not for isolated microcopy (ux-clarity) or visual polish (impeccable).
---

# Onboarding

Get users to their **aha moment** — the first time the product proves its worth — as fast as possible, teaching only what that requires. Onboarding that teaches everything teaches nothing: it's a race to first value, not a curriculum.

## Scope

- The user names the flow or area; if none is named, start with the first-run path (signup → first success).
- Wording inside the flow belongs to ux-clarity; empty-state *copy* belongs to ux-clarity. This skill owns flow structure: what to show, when, and how to get to the aha moment.

## 1. Assess the onboarding need

- **The challenge**: what are users trying to accomplish; what's confusing; where do they get stuck or drop off?
- **The users**: experience level (beginners, power users, mixed); motivation (exploring vs required by work); time budget (5 minutes? 30?); what they already know (coming from a competitor? new to the category?)
- **The aha moment**: the single action where value lands (first project created, first invite sent, first report run)
- **The metric**: how you'll know it worked (completion rate, time to value)

**Done when** you can state the aha moment in one sentence, with the shortest path to it.

## 2. Apply the principles

- **Show, don't tell** — real functionality with real data, one concept at a time (progressive disclosure)
- **Optional, always** — Skip is visible on every step; nothing gated behind ceremony
- **Time to value** — front-load the 20% that delivers 80%; advanced features wait for contextual discovery
- **Context over ceremony** — teach at point of use: empty states, tooltips, and hints where the feature lives
- **Respect the user** — assume standard patterns are known; explain only what's new; never patronize

## 3. Design the experience

### First run (the path to the aha moment)

- **Welcome**: the value proposition in one line, what they'll accomplish, an honest time estimate, and Skip.
- **Account setup**: collect the minimum; say why each field is asked; smart defaults; social login where it fits.
- **Core concepts**: 1-3, in plain language with examples; interactive if possible (do, not read); progress indication ("Step 1 of 3").
- **First success**: guide to a real, pre-populated accomplishment (template, sample data); mark the win without over-celebrating; show the next step.

### Feature discovery & adoption

- **Empty states**: the structure is what will appear here / why it's valuable / a CTA to create or use a template. (Wording lives in ux-clarity.)
- **Contextual tooltips**: fire the first time the feature is seen, point at the element, one line of benefit, dismissable ("Don't show again"), optional "Learn more".
- **Feature announcements**: what's new, why it matters, try it now, dismissable.
- **Progressive discovery**: teach on encounter; badge unused features; reveal options as the user levels up.

### Guided tours & interactive tutorials

- Tours earn their place on complex or changed interfaces: 3-7 steps, spotlight the element (dim the rest), click-through free, replayable from Help.
- Interactive > passive: users click real buttons; focus on the workflow ("Create a project"), not the widget ("This is the project button"); sample data so actions work.
- Sandbox tutorials (objectives, step-by-step, validation, a graduation moment) are for high-stakes or hands-on skills — use them rarely; a separate tutorial mode cuts against showing real functionality.

### Help

Contextual help links, keyboard shortcut reference (⌘K shown on the search box), searchable help center, short video tutorials for complex flows.

## 4. Respect the seen-state

Track what each user has seen and never show the same onboarding twice: the initial flow is first-run only, tooltips respect dismissals, returning users see none of it.

```js
localStorage.setItem('onboarding-completed', 'true') // seen-state: never re-show
```

## Done

The flow gets a new user to the aha moment in the fewest steps; every step is skippable; nothing repeats. Check the metrics: time to completion, completion rate, skip rate (high skip = too long or not valuable), and time to value.
