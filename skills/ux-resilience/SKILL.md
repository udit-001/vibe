---
name: ux-resilience
description: Harden frontend UI against edge cases — error states, i18n, text overflow, empty/loading states, boundary rendering, and accessibility resilience. Use when the user asks to harden a UI or component, fix edge cases, handle errors/i18n/text overflow, or make the interface survive real-world input. Not for backend error handling or visual polish.
---

# Resilience hardening

Harden the UI against **production reality** — the inputs, connections, and locales that break a demo. Perfect-data designs aren't production-ready: every component should survive the longest text, the worst network, and the most hostile locale without breaking layout or losing the user.

## Scope

- Target: the component or feature the user names; if none, the current view.
- Wording of error/empty/loading *copy* belongs to ux-clarity; flow structure to ux-onboarding. This skill owns rendering and recovery behaviour.
- Backend error handling is out of scope.

## 1. Assess the weak points

Probe the target against each attack surface and note what breaks:

- **Extreme input** — very long text (100+ chars), empty/single-char, emoji, RTL, accents, huge numbers, 1000+ list items, 50+ options
- **Error scenarios** — offline/slow/timeout, API status codes (400/401/403/404/429/500), validation, permissions, rate limits, double-submits, races
- **i18n** — translations ~30% longer (German is the usual worst case), RTL (Arabic, Hebrew), CJK and emoji, date/time and number formats, currency
- **Accessibility** — keyboard-only, screen reader, 200% zoom, reduced motion, high contrast
- **Boundaries** — empty data, first/last item, loading and refresh states, concurrent operations

**Done when** every attack surface above is probed against the target — a documented pass or a found break, none skipped.

## 2. Harden, dimension by dimension

### Text overflow & wrapping

Single line: `overflow: hidden; text-overflow: ellipsis; white-space: nowrap`. Multi-line: `-webkit-line-clamp`. Long text: `overflow-wrap: break-word; hyphens: auto`. Flex/grid children: `min-width: 0` so items shrink below content size. Fluid type: `clamp()`, minimum readable size (14px mobile), test at 200% zoom. No fixed widths on text containers.

### i18n

- Budget 30-40% growth for translations; layouts adapt (flex/grid), never fixed-width buttons (`px-4 py-2`, not `w-24`).
- RTL: use logical properties (`margin-inline-start`, `padding-inline`, `border-inline-end`) or the `dir` attribute; flip directional icons.
- Format dates/numbers/currency with `Intl` (`Intl.DateTimeFormat`, `Intl.NumberFormat`) — never hand-rolled separators.
- Pluralize through the i18n library's plural rules (`t('items', { count })`), never string concatenation.

### Error handling

- **Network**: clear message + retry; say what failed; handle timeouts; design the offline path deliberately.
- **API status**: 400 → validation errors; 401 → login; 403 → permission message; 404 → not-found state; 429 → rate-limit message; 500 → generic message + support route.
- **Form validation**: inline next to the field, specific, suggests the fix, preserves input on error, doesn't block submission for fixable issues.
- **Isolate failures**: one component's error renders its own error state (with retry); the rest of the interface keeps working.
- **Slow connections**: skeleton screens, progressive image loading, optimistic updates with rollback.

### Edge cases & boundaries

- **Empty**: no items / no results / no notifications each get a designed state (copy: ux-clarity; activation: ux-onboarding).
- **Loading**: initial, pagination, and refresh states; say what's loading; time estimates for long operations (copy: ux-clarity).
- **Large data**: paginate or virtualize; filter/search rather than rendering everything.
- **Concurrency**: disable submit while in flight; guard against races; optimistic updates roll back on failure.
- **Permissions**: read-only/denied states explain why and how to get access.
- **Compat**: feature detection over browser detection; polyfill what you need; core function works without JS; alt text everywhere.

### Validation & sanitization

Client-side for UX (required, format, length, pattern — hint states the constraint via `aria-describedby`); server-side for truth (never trust client alone; sanitize all input; rate-limit). Constrain with `maxlength`/`pattern` and say the constraint in the hint.

### Accessibility resilience

Keyboard: everything reachable, logical tab order, focus managed in modals, skip links. Screen readers: ARIA labels, live regions announce dynamic changes, descriptive alt, semantic HTML. Motion: `prefers-reduced-motion` collapses animation. Contrast: never color-only signals; passes Windows high-contrast.

## 3. Verify

Re-probe the target with the attack surface from step 1: 100+ char text, emoji everywhere, Arabic/Hebrew, CJK, offline + throttled 3G, 1000+ items, 10 rapid submits, forced API errors across status codes, fully empty data.

**Done when** the target survives every probe from step 1 — no layout break, no unhandled error state, no lost input; every break found in step 1 is fixed or explicitly accepted.
