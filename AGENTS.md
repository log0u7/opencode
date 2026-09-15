# Global rules

## AGENTS.md scoping and network boundaries

- Repo-level AGENTS.md apply ONLY inside that repo tree. Reading repo files for context does NOT activate its rules elsewhere.
- Repo proxy/tunnel/wrapper rules (proxychains4, VPN, SSH tunnels) apply ONLY to that repo's endpoints. NEVER route public hosts (gitlab.com, github.com, public registries) through work proxy/tunnel: direct connections.
- Before any "always"/"must" rule: resolve scope (host, repo, environment). Ambiguous: ask user.

## Writing style

- Never em dash (`—`). Use `:`, `,`, `()`. Plain hyphen `-` for dash.
- Prompts, command templates, agent prompts, skill bodies, model input: English. Conversation replies follow user language.
- Committed artifacts English-only: docs, changelog, code comments, commit messages.

## Engineering principles

- **DRY**: single authoritative representation per concept.
- **KISS**: simplest correct solution.
- **YAGNI**: only what needed now.
- **SOLID**: Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion.
- **Secure by design**: validate inputs, least privilege, no hardcoded secrets, deny by default, explicit errors, minimal attack surface.

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

Plan mode (read-only): how to end turn depends on tool availability:

- Exit tool available (`plan_exit`, `exit_plan_mode`, or equivalent): present full plan as chat message first, then call exit tool. Plan file is background mechanics; reply is deliverable. **NEVER** call exit tool without plan written in reply first, **NEVER** ask "switch to build or continue?".
- Write plan file in single final complete write once settled; avoid incremental edits (TUI noise).
- No exit tool: present final plan, stop. Do NOT propose "go"/"approve"/confirmation dialogue. User switches agents manually.

## Todo discipline

- `todowrite` replaces WHOLE list each call: always resend ALL items.
- Tick `completed` IMMEDIATELY after each step. Never batch.
- Exactly ONE `in_progress` while working.
- Finished work NEVER remains `pending`.

## State of the art

- Research best practices, idioms, tooling before non-trivial work.
- Verify APIs, versions, features current.
- Follow existing conventions.
- Battle-tested > reinventing.
- Compare trade-offs when multiple approaches.

## Quality and testing

- Cover all code with tests (unit, integration, e2e).
- All linters, type checkers, test suites pass. Verify actual result, not intent.
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

## Process management

- **MUST NOT** kill opencode processes (`pkill opencode`, `kill` on opencode PIDs, `killall opencode`). Restart is user's decision.
- `kill <PID>` (SIGTERM) only on task-owned processes. SIGTERM -9 only with user confirmation.
- Process outside task ownership must stop: return exact command to user, do not run it.
- `pkill`, `kill -9`, `killall` hard-blocked by damage-control plugin. No bypasses (wrappers, alternate binaries).

## Tool and binary version pinning

- **MUST** detect and respect project-pinned tool versions before executing any binary.
- Detection order: `.tool-versions` / `mise.toml` (mise/asdf), `package.json` `engines`, `.nvmrc` / `.node-version`, `go.mod`, `Cargo.toml` rust-version, `pyproject.toml` python version, `.python-version`, `Gemfile` ruby version.
- **MUST NOT** install or invoke different version than project declares.
- No pin: system default. Never assume or pick a version.
- Required version missing: report exact gap ("project requires X, found Y or none"), ask user before proceeding.

## Home directory hygiene

- User keeps `$HOME` tidy. **MUST NOT** scatter tool artifacts, caches, ad-hoc dirs in it.
- Dedicated locations:
  - Go: `~/go` (GOPATH)
  - Node: `~/.npm-global` (npm prefix; runtimes via mise)
  - Python: `~/venv` (virtualenvs)
  - Binaries: `~/.local/bin`
- Project-local artifacts (`node_modules/`, `.venv/`, `vendor/`, build outputs) inside project: fine.
- User-wide or non-standard (global install, new toolchain location): check how user manages it first, then ask. Never invent ad-hoc locations like `~/opt/<tool>`; past-agent messes, not conventions.

## Docker builds (local plugin repos)

Applies to local repos whose build targets damage-control protected paths (`dist/`, `build/`), e.g. `opencode-quota`, `opencode-damage-control`.

- Repos live in `~/projets/github/logout/<name>` (symlink target: `~/projets/logout/<name>`). Canonical location: never reference stale or copied paths in configs, commands, or `opencode.json`.
- Repo layout landmine: `github/logout/` holds own projects AND forks with local fixes; `github/` root holds upstream clones and org groupings only. New fork/fix work goes in `logout/`.
- Build with docker, bind-mounting repo. Purpose: reproducible environment, zero `$HOME` pollution with build artifacts or root-owned files. Sanctioned method, NOT damage-control bypass.
- **MUST** run container with `--user "$(id -u):$(id -g)"` so bind-mount writes belong to user. Container-root writes through bind mount create root-owned `$HOME` files (2026-08-28 incident: 22k files chown).
- **MUST NOT** evade damage-control matcher other ways (script-name aliases, quoting tricks, wrappers). Docker command blocked: hand exact command to user, do not reformulate.
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

## Changelog

- Keep `CHANGELOG.md` updated (Keep a Changelog format).
- `[Unreleased]` accumulates changes.
- Release: move to dated section, tag `vX.Y.Z`.
- Version sections split correctly, no duplicates.
- Validate before release.

## GitHub forks layout

- Personal fork clones live under `~/projets/github/logout/<repo>` (existing
  convention: `logout/` = repos the user actively contributes to). NEVER clone
  into `~/projets/github/` directly.
- Before cloning any repo under `~/projets/`, check whether a local clone
  already exists (`ls` the sibling directories first) and reuse it.
