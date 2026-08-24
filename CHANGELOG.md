# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `@slkiser/opencode-quota`: quota monitoring + `/tokens_*` reports via opencode.db local
- Submodule `nextlevelbuilder/ui-ux-pro-max-skill` (MIT, 120k stars): 7 UI/UX design skills via dual path `skills/` and `skills/ui-ux-pro-max/.claude/skills/`
- AGENTS.md rule: always verify subagent findings (reviewer/investigator) before acting
- AGENTS.md rule: all committed artifacts English-only
- AGENTS.md rule: `gitleaks` as the standard secret scanner (pre-commit hook on commit, CI job on push)
- AGENTS.md rule: prefer `glab`/`gh` over `curl` for repo and CI management, human-gated writes
- pre-commit quality gates: JSON checks, markdownlint on owned docs, gitleaks secret scan (checksum-verified binary), commitlint (Conventional Commits)
- Makefile targets: `lint`, `smoke`, `skills-update`
- GitLab CI pipeline: pre-commit lint job + gitleaks security job
- Skill submodules per tech stack (11 repos; discovered by the recursive `skills/` scan, explicit `skills.paths` entries added only for hidden skill dirs `ui-ux-pro-max/.claude` and `impeccable/.opencode`):
  - `pbakaus/impeccable` (Apache-2.0, 62k stars): design quality + AI-slop detector, native `.opencode/skills/`
  - `antfu/skills` (MIT, 5.8k): Vue, Vite, Pinia, VueUse, Vitest, pnpm, Turborepo
  - `onmax/nuxt-skills` (701): Nuxt, NuxtHub, Vue ecosystem
  - `mcollina/skills` (MIT, 1.9k): Node.js, Fastify, TypeScript by Node TSC member
  - `laravel/agent-skills` (official Laravel org, 699; no LICENSE file yet): starter-kit upgrade, Laravel Cloud deploy, Nightwatch
  - `dev-toolings/superpowers-symfony` (MIT, 205): 44 Symfony 7.4 LTS / 8.x skills
  - `Lombiq/Tailwind-Agent-Skills` (BSD-3-Clause): Tailwind CSS v4 docs skill
  - `trailofbits/skills` (CC-BY-SA-4.0, 6.8k): cherry-picked modern-python, modern-cpp, c-review, rust-review
  - `wsvincent/django-skills` (MIT): Django
  - `edgarMeinart/ruby-rails-rspec-skill` (no LICENSE file yet): Ruby style + Rails conventions + RSpec, exposed via local `ruby` wrapper skill
  - `leonardomso/rust-skills` (MIT, 440): 265 Rust rules with progressive disclosure
- Self-authored skills: `web-fundamentals` (HTML/CSS/vanilla JS), `jquery`, `php-lang`, `flask-fastapi`, `cpp`, `asm-x86-arm`, `ruby` (wrapper over ruby-rails-rspec-skill)

### Planned

- Sandboxing: Evaluate bubblewrap wrapper or `opencode-sandbox` plugin for command execution containment
- `nigel-dev/opencode-mission-control`: parallel AI sessions in git worktrees + tmux (heavy)
- `@devtheops/opencode-plugin-otel`: OTLP telemetry (waiting for OTEL stack)
- `apisec-inc/mcp-audit`: scan configs (on first local stdio MCP)

### Changed

- Translate remaining French documentation strings to English
- AGENTS.md rule: plan mode ends silently when no exit tool is available (no "go"/"approve" proposals); with `plan_exit` available, call it and never duplicate approval in text

## [0.1.0]

### Added

- Initial opencode configuration repository
- AGENTS.md with agent instructions
- AGENTS.md rewrite (reduced from 11KB to 3.9KB)
- Model naming convention (`<think|nothink>[, mtp], <role>`)
- Disabled model comments with `// disabled:` prefix
- Custom agents (cavecrew-builder, cavecrew-investigator, cavecrew-reviewer)
- Custom commands (caveman, caveman-commit, caveman-compress, caveman-help, caveman-review, caveman-stats, go)
- Caveman plugin
- Skills for infrastructure management (ansible, apache, aws, docker-swarm, foreman, gcp, kubernetes, nginx, nomad, openbao, opentofu, ovh, packer, puppet, salt, traefik, vault)
- Formatter enabled (prettier, terraform, ruff, gofmt)
- MCP server context7 for documentation lookups
- `autoupdate: "notify"` for update notifications without automatic installation
- `share: "disabled"` to prevent automatic session sharing
- `enabled_providers` allowlist for provider control
- Pinning `small_model`, `title`, `summary`, `compaction` agents to `qwen3.5-9b-mtp` to avoid model swap overhead with `--models-max 1`
- Conventional commits workflow
- Semver release tags
- `shfmt` 3.8.0 via apt (distro repositories)
- `gh` 2.98.0 via repo apt officiel cli.github.com (keyring signé)
- `glab` 1.114.0 via .deb officiel, sha256 vérifié

### Changed

- `build` and `explore` agent models renamed to `qwen3.5-9b-mtp`
- `glm-4.7-flash` name updated to include `(think, coder)`
- `qwen3.5-9b` name updated to include `(think, generalist)`
- `qwen3.5-9b-nt` name updated to include `(nothink, generalist)`
- `qwen3-coder-30b` name updated to include `(nothink, coder)`
- Default model + 3 cavecrew subagents pinned to `qwen3.5-9b-mtp` (temporary)
