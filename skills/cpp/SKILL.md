---
name: cpp
description: >
  Write and review modern C++ (17/20/23): RAII, smart pointers, move semantics,
  templates, error handling, CMake builds, sanitizers and warnings. Use for
  authoring C++ code, fixing memory/UB bugs, build system work, and code
  review; complements the trailofbits modern-cpp skill which focuses on
  security review.
---

# Modern C++

## Ownership first

- RAII for every resource: ownership expressed as `std::unique_ptr` (default), `std::shared_ptr` (shared ownership only, never for single-owner lifetimes), raw pointers/references for non-owning views.
- No `new`/`delete` outside low-level containers; no owning raw pointers.
- Pass cheap-to-copy types by value; everything else by `const&` (in) / value+move (sink) / `&` (out).

## Language rules

- Compile with at least `-Wall -Wextra -Wpedantic`; treat new warnings as errors.
- Enable core guidelines checks where available; prefer `constexpr` and `const` aggressively.
- `std::optional` for "maybe no value", `std::variant` + visitor for closed alternatives, exceptions or `expected`-style types for errors per project convention (decide once).
- Ranges/views over index loops; structured bindings for pair/tuple destructuring.
- Templates: constrain with concepts (C++20); SFINAE only in legacy code.

## Undefined behavior watchlist

- Out-of-bounds access, dangling references after container growth/move, data races, signed overflow, use-after-move.
- Build/test with sanitizers: `-fsanitize=address,undefined` in CI test jobs; TSan for concurrent code.

## Build

- CMake ≥ 3.20: targets carry usage requirements (`target_link_libraries`, `target_include_directories` with PUBLIC/PRIVATE/INTERFACE), no global flags.
- Dependencies via FetchContent/CPM pinned to commits; never system-wide assumptions.
- One canonical debug and release preset in `CMakePresets.json`.

## Review checklist

1. Lifetime: does any reference/pointer outlive its owner?
2. Exceptions: what happens on bad_alloc mid-operation? Is state still consistent?
3. API: can this be misused? Make interfaces hard to use incorrectly.
4. Tests cover happy path, error path, and edge sizes (empty, one, many).
