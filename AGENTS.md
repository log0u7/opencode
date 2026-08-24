# Global rules

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

## Handoff plan -> build

Receive "A plan file exists ... execute on it" message:

- Existing todo list: continue it.
- No todo: create `todowrite` covering all steps before edits/bash.
- Update todo continuously: `in_progress` on work start, `completed` on finish.
- New work discovered = new todo immediately.

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
