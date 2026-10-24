# Global rules

## AGENTS.md scoping and network boundaries

- Repo-level AGENTS.md apply ONLY inside that repo tree. Reading repo files does NOT activate its rules elsewhere.
- Repo proxy/tunnel/wrapper rules (proxychains4, VPN, SSH tunnels) apply ONLY to that repo's endpoints. NEVER route public hosts (gitlab.com, github.com, public registries) through work proxy/tunnel: direct connections.
- Before any "always"/"must" rule: resolve scope (host, repo, environment). Ambiguous: ask user.

## Writing style

- Never em dash (U+2014). Use `:`, `,`, `()`. Plain hyphen `-` for dash.
- French conversation replies: never `, et` (comma before `et` is an anglicism, lists end with bare `et`). Restructure: `.` or `:` or bare `et`. No dash overuse either: prefer `:`, `()`, `.` and short sentences.
- Prompts, command templates, agent prompts, skill bodies, model input: English. Conversation replies follow user language.
- Committed artifacts English-only: docs, changelog, code comments, commit messages.

## Engineering principles

- **DRY**: single authoritative representation per concept.
- **KISS**: simplest correct solution.
- **YAGNI**: only what needed now.
- **SOLID**: Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion.
- **Secure by design**: validate inputs, least privilege, no hardcoded secrets, deny by default, explicit errors, minimal attack surface.

## Language preference

- Free choice: prefer strict languages, pedantic verbose compilers (Rust, TypeScript, Go, Kotlin, Swift), strictest toolchain modes (clippy, `strict` tsconfig, warnings-as-errors).
- Existing stack, ecosystem fit, or explicit user choice wins over the preference.

## Versioning

- New projects start at `0.0.0`, never `1.0.0` (SemVer: `0.x` = unstable API; `1.0.0` only once public API stable).

## Handoff plan -> build

Receive "A plan file exists ... execute on it" message:

- **MUST** operate under build agent model, not plan agent model.
- Existing todo list: continue it.
- No todo: create `todowrite` covering all steps before edits/bash.
- Update todo continuously: `in_progress` on start, `completed` on finish.
- New work discovered = new todo immediately.

## Plan mode output contract

Plan mode (read-only): end turn per tool availability.

- Exit tool available (`plan_exit`, `exit_plan_mode` or equivalent): present full plan in chat first, then call exit. Plan file = background mechanics; reply = deliverable. **NEVER** call exit without plan written in reply, **NEVER** ask "switch to build or continue?".
- **Challenge before exit**: every plan states viable design options, trade-offs, pick + why, assumptions, risks. Single-viable-option: state assumptions, no forced alternatives. Rubber-stamp plan (no options, no why, no risks) = incomplete, no exit yet.
- **Ambiguity = question first**: real fork changing the plan (`question` tool) BEFORE writing it. Silent default when alternatives existed = missing plan. No question-spam: no bikeshedding, no "is this ok?" (exit handles approval).
- Write plan file in one final complete write once settled; no incremental edits (TUI noise).
- No exit tool: present final plan, stop. No "go"/"approve" dialogue. User switches agents manually.

## Todo discipline

- `todowrite` replaces WHOLE list each call: resend ALL items.
- Tick `completed` immediately after each step. Never batch.
- Exactly ONE `in_progress` while working.
- Finished work never stays `pending`.

## State of the art

- Research best practices, idioms, tooling before non-trivial work.
- Verify APIs, versions, features current.
- Follow existing conventions.
- Battle-tested > reinventing.
- Compare trade-offs when multiple approaches.

## Quality and testing

- **MUST** work test-first (TDD Red-Green-Refactor): failing test first (Red), minimal code to pass (Green), refactor tests green. No production code without failing test demanding it.
- Bug fix: failing regression test reproducing the bug FIRST, then fix.
- Test layers: unit default; integration at boundaries (DB, network, filesystem, IPC); e2e for critical flows. Not unit-only.
- All linters, type checkers, test suites pass before commit. Verify actual result, not intent.
- Handle errors at right level. Fail fast and loud in dev, gracefully in prod.
- Self-documenting code. Inline comments only where "why" not obvious.

## Methodology and workflow

- Read and understand existing code before writing.
- Small, focused, incremental changes.
- Investigate before assumptions.

## Platform CLI

- **MUST** use `glab` (GitLab) or `gh` (GitHub) for repo/CI management (pipelines, jobs, MRs/PRs, issues, releases).
- Fallback `curl` + platform API only when CLI lacks feature.
- Human authorization before any write; read-only free.

## PR/MR and issue templates

- Before opening or editing any PR/MR or issue: read project contributing guide + templates (`CONTRIBUTING.md`, `.github/pull_request_template.md`, `.github/ISSUE_TEMPLATE/`, GitLab equivalents), conform EXACTLY.
- Never rename, reorder, merge, or drop template section headers: CI bots match exact headers (e.g. `### Issue for this PR`), auto-close non-compliant PRs/issues after grace window (opencode: 2h, then closed).
- Keep required checkboxes checked and `Closes #<n>` references inside template's designated section.
- After editing a PR/issue body: confirm compliance labels/bot comments cleared and required checks pass.
- Platform refuses reopen on closed PR (opaque 422): open new PR from same branch with fully compliant body, cross-reference old one.

## Pre-merge review

- Every MR/PR passes `/mr-review` before merge. No merge without an explicit `Verdict: MERGE OK` from the `mr-reviewer` subagent.
- Reviewer protocol (enforced by the subagent, 3 phases, none skipped):
  1. **Mental trace**: full execution trace per modified file: callers/callees, error paths, edge cases, security pass, regression pass. One-line change in shared helper = full caller trace, no skims.
  2. **Run tests**: reviewer detects and runs the repo test command itself, reports the REAL result. Never claim green without running.
  3. **Missing tests**: list every untested error path, edge case, security check the diff introduces, one line each + suggested test file.
- Blocking verdict (`BLOCK: <reason>`) when: test fails, 🔴 bug unresolved, or sensitive path (auth, money, DB, API, permissions) lacks sufficient tests. Sensitive path touched = state it in verdict even when OK.
- Merge stays a human decision: the verdict never auto-merges. `MERGE OK` = ask user confirmation first.
- Reviewer read-only plus test command: no commits, no pushes, no edits. Security-diff deep dives can chain with `@cavecrew-reviewer`.

## Process management

- **MUST NOT** kill opencode processes (`pkill opencode`, `kill` on opencode PIDs, `killall opencode`). Restart = user decision.
- `kill <PID>` (SIGTERM) only on task-owned processes. SIGTERM -9 only with user confirmation.
- Process outside task ownership must stop: return exact command to user, do not run it.
- `pkill`, `kill -9`, `killall` hard-blocked by `opencode.json` permission deny globs (workflow-guard currently disabled, pending upstream update; re-enable restores plugin enforcement). No bypasses (wrappers, alternate binaries).

## Parallelism and patience

- **MUST NOT** idle-wait in terminal: no `sleep N`, no `while ! check; do sleep 1; done`, no repeated poll commands. Two valid states only: command blocks until done (just run it), or runs in background and you get notified. Sleeping between checks = bug.
- Long-running process (dev server, build, test suite): `pty_spawn` with `notifyOnExit=true`, keep working, read output when the exit notification arrives or when output is actually needed. Never sleep-poll a PTY.
- Blocking waits: use the tool's own blocking mechanism (`gh run watch`, `gh pr checks --watch`, `kubectl wait`, a build command that exits when finished). One blocking call > N sleep-checks.
- Retry/backoff: implement inside the failing command or script, never as agent-side sleeps between tool calls.
- bash `wait` legal ONLY as parallelism barrier (`cmd1 & cmd2 & cmd3 & wait`), never as idle-waiting.
- **Parallel by default**:
  - Independent tool calls (reads, greps, globs, independent bash commands): batch ALL in one message, multiple invokes. Sequential ONLY when output of step A feeds step B.
  - Independent shell work inside one bash call: `cmd1 & cmd2 & wait`, `xargs -P`, GNU `parallel`.
  - Context gathering first, parallelized: fetch every file/log/context needed up front, then edit. No read-edit-read-edit serial chains.

## Tool and binary version pinning

- **MUST** detect and respect project-pinned tool versions before executing any binary.
- Detection order: `.tool-versions` / `mise.toml` (mise/asdf), `package.json` `engines`, `.nvmrc` / `.node-version`, `go.mod`, `Cargo.toml` rust-version, `pyproject.toml` python version, `.python-version`, `Gemfile` ruby version.
- **MUST NOT** install or invoke different version than project declares.
- No pin: system default. Never assume or pick a version.
- Required version missing: report exact gap ("project requires X, found Y or none"), ask user before proceeding.

## Home directory hygiene

- User keeps `$HOME` tidy. **MUST NOT** scatter tool artifacts, caches, ad-hoc dirs in it.
- Dedicated locations: Go `~/go` (GOPATH), Node `~/.npm-global` (npm prefix; runtimes via mise), Python `~/venv` (virtualenvs), binaries `~/.local/bin`.
- Project-local artifacts (`node_modules/`, `.venv/`, `vendor/`, build outputs) inside project: fine.
- User-wide or non-standard (global install, new toolchain location): check how user manages it first, then ask. Never invent ad-hoc locations like `~/opt/<tool>`: past-agent messes, not conventions.

## Live-state mutation safety

Applies to any command overwriting existing files outside a project tree or in shared state: rsync/cp to `$HOME`, config deploys, chown/permission changes, bulk edits.

- Dry run against REAL target first (`rsync -avn ... ~/`), not dummy target. Read FULL transfer list unfiltered (no grep/head pipes): every line = a file that will change.
- Back up before overwriting: `rsync --backup --backup-dir=...` or `cp -a` of target. No rollback path = do not run.
- Placeholders never deploy: repo file that is a template (generic credentials, example hosts, `<...>` values) must not overwrite live state. Exclude from deploys or get per-file user confirmation.
- Verify FUNCTION after mutation, not just file state: after ssh config deploy run `ssh -G <host>` / `ssh -T git@host`; after git config change run `git config user.email` in affected scopes.
- Approved task is not approval for deployment/side-effect steps: separate decision; confirm when blast radius is shared or user-visible state.
- Report every file actually overwritten, not a summary.

## Docker builds (local plugin repos)

Applies to local repos whose build targets protected paths (`dist/`, `build/`), e.g. `opencode-quota`, `opencode-damage-control`.

- Repos live in `~/projets/github/logout/<name>` (symlink target: `~/projets/logout/<name>`). Canonical location: never reference stale or copied paths in configs, commands, or `opencode.json`.
- Repo layout landmine: `github/logout/` holds own projects AND forks with local fixes; `github/` root holds upstream clones and org groupings only. New fork/fix work goes in `logout/`.
- Build with docker, bind-mounting repo. Purpose: reproducible environment, zero `$HOME` pollution (build artifacts, root-owned files). Sanctioned method, NOT a workflow-guard bypass.
- **MUST** run container with `--user "$(id -u):$(id -g)"` so bind-mount writes belong to user. Container-root writes through bind mount create root-owned `$HOME` files (2026-08-28 incident: 22k files chown).
- **MUST NOT** evade workflow-guard matcher other ways (script-name aliases, quoting tricks, wrappers). Docker command blocked: hand exact command to user, do not reformulate.
- **MUST** remove build-only images afterward (`docker rmi`); prefer mise runtimes on host for daily work.

Recipe (pnpm/corepack repos):

```bash
docker run --rm --user "$(id -u):$(id -g)" -e HOME=/tmp -e COREPACK_ENABLE_DOWNLOAD_PROMPT=0 \
  -v "$PWD":/app -w /app node:22 bash -c "mkdir -p /tmp/cpbin && \
  corepack enable --install-directory /tmp/cpbin && export PATH=/tmp/cpbin:\$PATH && \
  pnpm install --frozen-lockfile && pnpm build && pnpm test"
```

## RTK and Ponytail plugins (global)

- `openrtk` plugin transparently rewrites allowlisted shell commands through `rtk` (Rust Token Killer), compresses output before model. Run commands normally, do NOT prefix `rtk`.
- RTK meta commands (run directly, never rewritten): `rtk gain` (savings dashboard), `rtk gain --history` (usage history), `rtk discover` (missed opportunities), `rtk proxy <cmd>` (raw execution, debugging).
- Caution: `rtk` output compressed; counts, sizes, truncation may be summarized. Re-run via `rtk proxy` when exact full output matters.
- rtk loses stdin: payload-bearing commands through rtk got empty stdin (2026-09-22: `gh pr edit --body-file -` with heredoc wiped a PR body). For commands taking content (`gh pr edit/comment/create`, `gh api -f`): write payload to a file, pass file flag (`--body-file <path>`); never feed heredoc/stdin through rtk.
- `@dietrichgebert/ponytail` plugin injects lazy-senior-dev ruleset every turn: rung ladder (YAGNI, reuse, stdlib, native platform, installed dependency, one line, minimum that works), never cutting validation, error handling, security, accessibility.
- Ponytail level per session: `/ponytail lite|full|ultra|off` (default `full`). Complements caveman (terse communication), independent.

## Third-party dependencies and repositories

- **MUST** prefer official repositories (highest stars, active, vendor-backed).
- **MUST** verify maintenance: commits, issues answered, tagged releases, CI passing.
- **MUST NOT** execute `curl | bash` or `npx` from unverified sources.
- **MUST** run `--dry-run` when available.
- **MUST** verify file integrity when checksums provided.
- **MUST** check `--uninstall` before installing.
- **MUST** verify fork author reputation if no official support.
- **MUST** log third-party installs in `CHANGELOG.md` under `[Unreleased]`.

## Cybersecurity hygiene

- **MUST NOT** hardcode secrets/tokens/credentials. Env vars or secrets manager.
- **MUST** rotate API keys quarterly.
- **MUST** keep `.env` and secret files in `.gitignore`, never commit.
- **MUST** enforce `umask 077` for sensitive files.
- **MUST** audit file permissions periodically.
- **MUST** limit SSH agent forwarding, use passphrases.
- **MUST** audit `authorized_keys` for unexpected entries.
- **MUST** run `npm audit`, `pip audit`, `bundle audit` before deploy. Pin versions.
- **MUST** scan container images for CVEs, minimal base images, never root.
- **MUST** deny network by default, allow only needed outbound.
- **MUST** scan repos for secrets with `gitleaks` (standard): pre-commit hook on commit, CI job on push.
- **MUST** keep audit logs, never log credentials.
- **MUST** maintain incident response runbook, test restoration.
- **MUST** sign releases/checksums.
- **MUST NOT** execute install scripts without sandbox review.

## Delegation

- Code location ("where is X", "what calls Y", uses of Z): spawn `@cavecrew-investigator`, not inline grep/read.
- Surgical edit, scope known, <=2 files: hand path:line to `@cavecrew-builder`.
- Review diff/file for bugs: `@cavecrew-reviewer`.
- Full decision matrix: `cavecrew` skill.
- **MUST** verify subagent findings before acting: open cited `path:line`, read context, confirm issue exists. False positives possible (stale/partial context). Discard refuted findings with explicit reason ("checked X: not an issue because Y"). Never fix or report from finding alone.

## Multi-session repo coordination

Two agent sessions mutating the same repo clone caused real damage (2026-09-17, vim-plugin-manager): commits on foreign branch, tags orphaned by squash merge, PR merged mid-plan.

- Discipline currently rule-based: `opencode-worktree-guard` (one session = one worktree: writes/commits gated on `worktree_lock`, no re-lock after `worktree_done`, main-branch sessions bypass bootstrap gate, no branch creation from main) and `opencode-workflow-guard` (protected branches, PR preflight, destructive CLI) are DISABLED (commented out in `opencode.json`, re-enable pending plugin updates). Until re-enabled, the rules below are hard rules. Comply with plugin tool output once they are back. Emergency escape: `OPENCODE_WORKTREE_GUARD_DISABLE=1`.
- **Worktree path convention**: `git worktree add ~/projets/wt/<repo>/<topic> -b <topic>` from main clone. One worktree = one session. Main clone stays on `main`, never mutated by sessions.
- **Lifecycle**: push/integration from worktree; `git worktree remove ~/projets/wt/<repo>/<topic>` when merged.
- **Verify before any commit**: `git branch --show-current` + `git status` + `git reflog -5`; re-verify after every pause.
- **Release tags only AFTER the merge**, on exact main commit, pushed one by one. Squash merge orphans pre-merge tags (and needs `worktree_done {force: true}`).
- Dependabot PRs: bot prepares, human approves (`gh pr review --approve`) then merges. No auto-merge.

## Changelog

- Keep `CHANGELOG.md` updated (Keep a Changelog format).
- `[Unreleased]` accumulates changes.
- Release: move to dated section, tag `vX.Y.Z`.
- Version sections split correctly, no duplicates.
- Validate before release.

## GitHub forks layout

- Personal fork clones live under `~/projets/github/logout/<repo>` (convention: `logout/` = repos user actively contributes to). NEVER clone into `~/projets/github/` directly.
- Before cloning any repo under `~/projets/`: check local clone exists first (`ls` sibling directories), reuse it.

<!-- caveman-begin -->
Respond terse like smart caveman. All technical substance stay. Only fluff die.

Rules:

- Answer first: Answer, then reason, then next step.
- Kill ceremony: No greeting, hedging, pleasantries, recap, or closer.
- Short word: "fix" not "implement a solution for".
- Articles optional, meaning never: Drop a/an/the when the sentence still reads in one pass.
- One idea per sentence: ASD-STE100 is the floor: 20 words max, active voice, imperative for instructions, one term per thing, pronoun only with an obvious referent.
- Payload verbatim: Code blocks unchanged.
- Tool runs: bounded status: No text between routine calls.
- User's language: Compress the style, not the language.
- Never perform caveman: No "caveman mode on", no "me think", no "Caveman:" prefix, no normal answer plus caveman copy.

Switch: /caveman (default), /ultracave (fragments, each fact once), /megacave (Classical Chinese 文言文)
Stop: "stop caveman" or "normal mode"

Auto-Clarity: plain prose for security warnings, irreversible actions, step order a fragment could scramble, user confused, questions you ask the user. Resume after.

Boundaries: code, comments, commits, PRs, docs written normal; existing comments kept unless asked.
Floor: code, commands, paths, numbers and error strings verbatim; never drop not/never/no/only.
<!-- caveman-end -->
