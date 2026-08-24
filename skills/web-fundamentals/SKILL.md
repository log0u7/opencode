---
name: web-fundamentals
description: >
  Author and review semantic HTML, modern CSS (flexbox, grid, container queries,
  custom properties) and vanilla JavaScript (DOM, events, fetch, modules). Use
  when writing or fixing plain web pages/components without a framework,
  debugging layout or specificity issues, improving accessibility and semantics,
  or replacing jQuery-era patterns with native APIs.
---

# Web fundamentals: HTML, CSS, vanilla JS

## HTML

- Semantic elements first: `header`, `nav`, `main`, `section`, `article`, `aside`, `footer`. A `<div>` only when no element matches the meaning.
- One `<h1>` per page, heading levels never skip.
- Interactive elements are real buttons/links: `<button>` for actions, `<a href>` for navigation.
- Every image gets meaningful `alt` text; decorative images get `alt=""`.
- Label every form control (`<label for>`); group related inputs with `fieldset`.
- Landmark roles come free from semantics; add ARIA only when semantics cannot express it.

## CSS

- Prefer flexbox for one-axis layouts, grid for two-axis layouts.
- Custom properties (`--var`) for tokens: colors, spacing, radii. Define on `:root`, override per scope.
- Logical properties (`margin-inline`, `padding-block`) over physical ones.
- Specificity: keep selectors shallow (max 2 levels). No `!important` outside utility overrides.
- Container queries (`@container`) for component-level responsiveness; media queries for page-level.
- Modern color: `oklch()` for perceptual uniformity; `color-mix()` for derived shades.
- Transitions animate between explicit states; respect `prefers-reduced-motion`.

## JavaScript

- `"use strict"` implicit in ES modules; always `type="module"`.
- DOM queries: `querySelector`/`querySelectorAll`; event delegation via one listener on a stable ancestor instead of N listeners.
- Events: `addEventListener` with `{ once, passive, signal }` options; clean up with `AbortController` when lifetimes differ.
- Network: `fetch` + `async/await`; always handle non-2xx (`response.ok`) and network errors separately.
- State: prefer plain objects/arrays + functions over classes unless polymorphism is real.
- Never mutate function arguments or global state; return new values.

## Debugging workflow

1. Reproduce in DevTools; read console first, then Elements computed styles.
2. Layout bugs: check box model, then containing block, then stacking context.
3. For current API support details, use context7 (MDN web docs) instead of guessing.

## Anti-patterns

- Inline styles and inline event handlers (`onclick=`).
- Pixel-perfect fixed heights on text containers.
- `setTimeout`-based sequencing instead of promises/events.
- Reaching for a framework to render static content.
