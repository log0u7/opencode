# ub-mode companion tools

Local clones of the deterministic quality-gate tools required by the
"Then Make it Right" sections of this skill. Paths are absolute; run the
tools from the root of the project under review.

| Tool | Command | Purpose |
| ---- | ------- | ------- |
| crapper | `~/projets/github/unclebob/crapper/crapper` | CRAP score per function (CC^2 x (1 - coverage)^3 + CC). Keep every function under CRAP 10. |
| dryer | `~/projets/github/unclebob/dryer/dryer` | Structural duplication. Eliminate candidate pairs scoring >= 0.8. |
| mutator | `~/projets/github/unclebob/mutator/mutator` | Mutation testing. Cover the uncovered, kill the survivors, delete dead code. |

## Quick reference

```bash
~/projets/github/unclebob/crapper/crapper --no-coverage   # complexity only, does not run the test suite
~/projets/github/unclebob/dryer/dryer
~/projets/github/unclebob/mutator/mutator <file-or-dir>   # runs the project test suite; starts with --scan to list sites
```

Useful flags shared by the tools: `--changed` (git additions and edits only),
`--use-existing-coverage`, `--no-coverage` (crapper/mutator), `--scan`
(mutator, list sites without running tests), `--test-command`, `--max-workers`.

## Layout notes

- The first run of each tool creates its own `.venv` inside its clone
  directory; no global installation.
- `mutator` reads namespace and function names from the `crapper` clone at
  `../crapper` relative to its own directory. The sibling layout
  `~/projets/github/unclebob/{crapper,dryer,mutator}` satisfies this.
- Tools write snapshots under `.metrics/` in the project under review
  (`crap.edn`, `dry.edn`, `mutate/*.edn`).
- Coverage integration runs the project's own test tooling and may install
  coverage helpers (for example `cargo-llvm-cov`, `pytest` + `coverage`, or
  `@vitest/coverage-v8`) when missing. Use `--no-coverage` to avoid that.

- Source: https://github.com/unclebob/ub-mode (skill), companion repos
  unclebob/crapper, unclebob/dryer, unclebob/mutator.
