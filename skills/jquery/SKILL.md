---
name: jquery
description: >
  Work with legacy jQuery codebases: read and extend jQuery 1.x-3.x patterns,
  write idiomatic plugins, debug selector/event/ajax issues, and plan gradual
  migration to vanilla JS. Use when a project imports `$`/`jQuery`, when asked
  to fix or add features to jQuery code, or when converting jQuery to modern
  JavaScript.
---

# jQuery (legacy maintenance)

## Context

jQuery appears in legacy CMS themes, WordPress plugins, and enterprise apps.
Default goal: preserve behavior with minimal diff. Rewrite to vanilla only when
explicitly requested.

## Idiomatic patterns

- Cache selections: `const $rows = $('.row')` before loops; re-query only after DOM changes.
- Event delegation for dynamic content: `$('#list').on('click', '.item', handler)`.
- Namespaced events (`'click.myplugin'`) so `off('.myplugin')` cleans up completely.
- Chain deliberately; break chains when intermediate results are reused.
- AJAX: prefer `$.ajax` with explicit `dataType` over shorthand helpers in shared code.
- Plugins: `(function ($) { $.fn.name = function () { return this.each(...) }; })(jQuery)`; always `return this`.

## Vanilla equivalents (for migration)

| jQuery | Native |
|---|---|
| `$(sel)` | `document.querySelectorAll(sel)` |
| `.on('click', fn)` | `addEventListener('click', fn)` |
| `.addClass/.removeClass` | `classList.add/remove/toggle` |
| `.attr('x', v)` | `setAttribute('x', v)` / direct property |
| `$.getJSON(url)` | `fetch(url).then(r => r.json())` |
| `$(fn)` | `DOMContentLoaded` event |

Migration order: drop Sizzle-only selectors, replace animations with CSS transitions, then remove `$.ajax` wrappers, then delete the library.

## Pitfalls

- `$(document).ready` inside modules may run after DOM is already ready; guard it.
- Implicit iteration hides per-element state bugs; make loops explicit when debugging.
- Old plugins assume global `$`; under `jQuery.noConflict()` wrap them in an IIFE.
