---
name: php-lang
description: >
  Write and review modern PHP 8.2+ independent of framework: strict types,
  enums, readonly properties, Composer autoloading, PSR conventions, error
  handling, and testing with PHPUnit/Pest. Use for PHP language questions,
  plain-PHP or library code, legacy PHP upgrades, and any PHP work not covered
  by the Laravel or Symfony skills.
---

# Modern PHP (language level)

## Baseline

- `declare(strict_types=1);` in every file.
- Typed everything: properties, parameters, return types. `readonly` for value objects; `enum` for closed sets (backed enums for persistence).
- Constructor property promotion + `static` factory methods for readable instantiation.
- Match expression over switch when mapping values; `nullsafe` operator `?->` over nested isset ladders.

## Project layout

- PSR-4 autoload via Composer: `src/` maps to namespace root, `tests/` mirrors it.
- Follow PSR-12 (style) and PSR-18/PSR-14 where interfaces apply (HTTP client, events).
- Public API documented with PHPDoc only where types cannot express intent (`@throws`, `@template`).

## Error handling

- Exceptions for exceptional flow; result objects/enums for expected failures.
- Domain exceptions extend a project base exception; never throw bare `\Exception`.
- No `@` suppression; no try/catch that only logs and swallows.

## Tooling

- Static analysis: PHPStan (level max aspirational) or Psalm; fix new violations immediately.
- Style: PHP-CS-Fixer or Pint, run in CI.
- Tests: PHPUnit or Pest; test names describe behavior; data providers for input matrices.

## Version discipline

- Target the version declared in `composer.json` `"php"` constraint; do not use features newer than the floor.
- For current function/API behavior across PHP versions, use context7 PHP documentation instead of memory.

## Anti-patterns

- Service locators and singletons via global state.
- `array` typed as "everything": introduce DTOs/value objects once shape stabilizes.
- Business logic in getters/setters or constructors with side effects.
