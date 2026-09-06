# Global rules

## AGENTS.md scoping and network boundaries

- Repo-level AGENTS.md files apply ONLY when working inside that repository
  tree. Reading a repo's files for context does NOT activate its rules for
  other work.
- Proxy, tunnel, and wrapper rules (proxychains4, VPN, SSH tunnels) defined by
  a repo apply ONLY to that repo's own endpoints. NEVER route public internet
  hosts (gitlab.com, github.com, public registries) through a work proxy or
  tunnel: those are direct connections.
- Before following an "always"/"must" rule, resolve its scope (which host,
  which repo, which environment). Ambiguous scope: ask the user.

## Writing style

- Never use em dash (`—`). Use `:`, `,`, or `()`. Plain hyphen `-` for dash.
- Prompts in English. Command templates, agent prompts, skill bodies, model input. Conversation replies follow user language.
- All committed artifacts English-only: docs, changelog, code comments, commit messages.

## Engineering principles

- **DRY**: single authoritative representation per concept.
- **KISS**: simplest correct solution.
- **YAGNI**: implement only what needed now.
- **SOLID**: Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion.
- **Secure by design**: validate inputs, least privilege, no hardcoded secrets, deny by default, explicit errors, minimal attack surface.

## Versioning

- New projects start at version `0.0.0`, never `1.0.0` (SemVer: `0.x` is initial development with an unstable API; go `1.0.0` only once the public API is declared stable).

## Handoff plan -> build

Receive "A plan file exists ... execute on it" message:

- **MUST** operate under the build agent model, not the plan agent model.
- Existing todo list: continue it.
- No todo: create `todowrite` covering all steps before edits/bash.
- Update todo continuously: `in_progress` on work start, `completed` on finish.
- New work discovered = new todo immediately.

## Plan mode output contract

While in plan mode (read-only phase), how to end a turn depends on tool availability:

- Exit tool available (`plan_exit`, `exit_plan_mode`, or equivalent): present the full plan as a chat message first, then call the exit tool. The plan file is background mechanics; the reply is the deliverable. **NEVER** call the exit tool without the plan having been written in the reply first, and **NEVER** ask "do you want to switch to build or continue?".
- Write the plan file in a single final complete write once the plan is settled; avoid many incremental edits (TUI noise).
- No exit tool available: present the final plan and stop. Do NOT propose "go", "approve", "adjust", or any confirmation dialogue. The user switches agents manually and starts execution themselves.

## Todo discipline

- Tool `todowrite` replaces the WHOLE list each call: always resend ALL items.
- Tick `completed` IMMEDIATELY after each finished step. Never batch.
- Exactly ONE item stays `in_progress` while working.
- Finished work must NEVER remain `pending`.

## State of the art

- Research best practices, idioms, tooling before non-trivial work.
- Verify APIs, versions, features current.
- Follow existing conventions.
- Battle-tested solutions > reinventing.
- Compare trade-offs explicitly when multiple approaches.

## Quality and testing

- Cover all code with tests (unit, integration, end-to-end).
- All linters, type checkers, test suites must pass. Verify actual result, not intent.
- Handle errors at appropriate level. Fail fast and loud in dev, gracefully in prod.
- Self-documenting code. Inline comments only where "why" not obvious.

## Methodology and workflow

- Read and understand existing code before writing.
- Small, focused, incremental changes.
- Investigate before assumptions.

## Platform CLI

- **MUST** use `glab` (GitLab) or `gh` (GitHub) for repo and CI management (pipelines, jobs, MRs/PRs, issues, releases).
- Fallback to `curl` + platform API only when the CLI lacks the feature.
- Human authorization required before any write operation; read-only queries allowed freely.

## Process management

- **MUST NOT** kill opencode processes (`pkill opencode`, `kill` on opencode PIDs, `killall opencode`). Restarting opencode is the user's decision.
- `kill <PID>` (SIGTERM) only on processes started by the current task. Escalate to SIGTERM -9 only with user confirmation.
- When a process outside the task's ownership must stop: return the exact command to the user instead of running it.
- `pkill`, `kill -9`, `killall` are hard-blocked by the damage-control plugin. Do not attempt bypasses (wrappers, alternate binaries).

## Tool and binary version pinning

- **MUST** detect and respect project-pinned tool versions before executing any binary.
- Detection order: `.tool-versions` / `mise.toml` (mise/asdf), `package.json` `engines` field, `.nvmrc` / `.node-version`, `go.mod` Go version, `Cargo.toml` rust-version, `pyproject.toml` python version, `.python-version`, `Gemfile` ruby version.
- **MUST NOT** install or invoke a different version than what the project declares.
- When no pinned version exists, use the system default. Never assume or pick a version.
- If the required version is missing: report the exact gap ("project requires X, found Y or none") and ask the user before proceeding.

## Home directory hygiene

- The user keeps `$HOME` tidy. **MUST NOT** scatter tool artifacts, caches, or ad-hoc directories in it.
- Dedicated locations:
  - Go: `~/go` (GOPATH)
  - Node: `~/.npm-global` (npm global prefix; runtime versions managed by mise)
  - Python: `~/venv` (virtualenvs)
  - Binaries: `~/.local/bin`
- Project-local artifacts (`node_modules/`, `.venv/`, `vendor/`, build outputs) live inside the project: that is fine.
- Anything user-wide or non-standard (global package install, new toolchain location): first check how the user already manages it, then ask before creating or installing anything. Never invent ad-hoc locations like `~/opt/<tool>`; those are past-agent messes, not conventions.

## Docker builds (local plugin repos)

Applies when building local repos whose build targets damage-control protected paths (`dist/`, `build/`), e.g. `opencode-quota`, `opencode-damage-control`.

- Repos live in `~/projets/github/<name>`. Canonical location: never reference stale or copied paths in configs, commands, or `opencode.json`.
- Build with docker, bind-mounting the repo. Purpose: reproducible environment, zero pollution of `$HOME` with build artifacts or root-owned files. Sanctioned method, NOT a damage-control bypass.
- **MUST** run the container with `--user "$(id -u):$(id -g)"` so bind-mount writes belong to the user. Container-root writes through a bind mount create root-owned files in `$HOME` (2026-08-28 incident: 22k files needed manual chown).
- **MUST NOT** evade the damage-control matcher in other ways (script-name aliases, quoting tricks, wrappers). If the docker command itself is blocked, hand the exact command to the user instead of reformulating it.
- **MUST** remove build-only images afterward (`docker rmi`); prefer mise-managed runtimes on the host for daily work.

Recipe (pnpm/corepack repos):

```bash
docker run --rm --user "$(id -u):$(id -g)" -e HOME=/tmp -e COREPACK_ENABLE_DOWNLOAD_PROMPT=0 \
  -v "$PWD":/app -w /app node:22 bash -c "mkdir -p /tmp/cpbin && \
  corepack enable --install-directory /tmp/cpbin && export PATH=/tmp/cpbin:\$PATH && \
  pnpm install --frozen-lockfile && pnpm build && pnpm test"
```

## RTK and Ponytail plugins (global)

- The `openrtk` plugin transparently rewrites allowlisted shell commands through `rtk` (Rust Token Killer) to compress output before it reaches the model. Run commands normally, do NOT manually prefix `rtk`.
- RTK meta commands (run directly, never rewritten): `rtk gain` (savings dashboard), `rtk gain --history` (usage history), `rtk discover` (missed opportunities), `rtk proxy <cmd>` (raw unfiltered execution, for debugging).
- Caution: `rtk` output is compressed, so counts, sizes, and truncation reported by it may be summarized. Re-run via `rtk proxy` when exact full output matters.
- The `@dietrichgebert/ponytail` plugin injects the lazy-senior-dev ruleset every turn: rung ladder (YAGNI, reuse, stdlib, native platform, installed dependency, one line, then the minimum that works), never cutting validation, error handling, security, or accessibility.
- Ponytail level per session: `/ponytail lite|full|ultra|off` (default `full`). It complements caveman (terse communication), they are independent.

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

- **MUST** never hardcode secrets/tokens/credentials. Use env vars or secrets manager.
- **MUST** rotate API keys quarterly.
- **MUST** keep `.env` and secret files in `.gitignore`, never commit.
- **MUST** enforce `umask 077` for sensitive files.
- **MUST** audit file permissions periodically.
- **MUST** limit SSH agent forwarding, use passphrases.
- **MUST** audit `authorized_keys` for unexpected entries.
- **MUST** run `npm audit`, `pip audit`, `bundle audit` before deploying. Pin versions.
- **MUST** verify checksums, prefer official registries.
- **MUST** scan container images for CVEs, minimal base images, never root.
- **MUST** deny network by default, allow only needed outbound.
- **MUST** scan repos for secrets with `gitleaks` (standard): pre-commit hook on commit, CI job on push.
- **MUST** keep audit logs, never log credentials.
- **MUST** maintain incident response runbook, test restoration.
- **MUST** sign releases/checksums.
- **MUST NOT** execute install scripts without sandbox review.
- **MUST NOT** use `curl | bash` without checksum verification.

## Delegation

- Code location ("where is X", "what calls Y", uses of Z): spawn `@cavecrew-investigator` instead of inline grep/read.
- Surgical edit, scope known, ≤2 files: hand path:line to `@cavecrew-builder`.
- Review diff/file for bugs: `@cavecrew-reviewer`.
- Full decision matrix: `cavecrew` skill.
- **MUST** verify subagent findings before acting: open cited `path:line`, read surrounding context, confirm the issue exists. False positives possible (stale or partial context). Discard refuted findings with explicit reason ("checked X: not an issue because Y"). Never fix or report based on a finding alone.

## Changelog

- Keep `CHANGELOG.md` updated (Keep a Changelog format).
- `[Unreleased]` accumulates changes.
- On release: move to dated section, tag `vX.Y.Z`.
- Ensure version sections split correctly, no duplicates.
- Validate before release.
