# opencode configuration

## What

Personal OpenCode configuration directory, versioned on GitLab, driving opencode CLI behavior globally.

Replaces manual `AGENTS.md` edits and scattered settings with a single source of truth for:

- Model providers and naming conventions
- Skill discovery and loading
- Quality gates (pre-commit, commitlint, gitleaks)
- TUI extensions and quota monitoring

## Why

- Reproducible setup across machines via `git pull`

- Versioned evolution tracked in `CHANGELOG.md`
- Quality gates enforced locally (`make lint`) and centrally (GitLab CI)
- Centralized quota monitoring via `@slkiser/opencode-quota`
- Clear separation of concerns: server plugins (`opencode.json`) vs TUI extensions (`tui.json`)

## Layout

```md

.
├── AGENTS.md              # Agent instructions (English-only, third-party rules)
├── opencode.json          # Main config: providers, models, agents, skills.paths, compaction
├── agents/                # Custom agents (markdown, markmap)
├── commands/              # Custom commands (markdown)
├── plugins/               # Node.js plugins (server-side, loaded via "plugin" array)
├── skills/                # Agent skills (markdown)
│   ├── 27 skills maison (web-fundamentals, jquery, php-lang, flask-fastapi, cpp, asm-x86-arm, ruby)
│   └── 11 submodules (impeccable, antfu-skills, nuxt-skills, node-skills, laravel, symfony, tailwind, trailofbits, django, ruby-rails, rust)
├── package.json           # Plugin dependencies
├── package-lock.json      # Reproducible builds
├── .gitignore             # Git exclusions (node_modules, .cache)
├── LICENSE                # MIT
├── CHANGELOG.md           # Keep a Changelog
├── CONTRIBUTING.md        # Contribution guidelines
├── Makefile               # Targets: lint, smoke, skills-update
├── .pre-commit-config.yaml# Pre-commit hooks: JSON, merge conflicts, large files, gitleaks, markdownlint
├── commitlint.config.mjs# Conventional Commits configuration
├── .markdownlint-cli2.jsonc# Markdown lint rules (owned docs only)
├── .gitlab-ci.yml         # CI: gitleaks security job only (precommit job removed)
├── node_modules           # Dependencies (ignored)
├── README.md              # This file
├── CHANGELOG.md           # Keep a Changelog
├── CONTRIBUTING.md        # Contribution guidelines
├── .caveman-*             # Runtime state (ignored)

```

## How it works

### Providers

- **llamacpp-ricinus**: llama.cpp server at `192.168.1.26:9931`

- **ollama-ricinus**: Ollama server at `192.168.1.26:11434`
- **opencode**: OpenCode Zen (cloud)

Model naming convention: `<think|nothink>[, mtp], <role>`

### Skills discovery

- Recursive scan of `skills/` discovers all SKILL.md files

- Explicit `skills.paths` entries only for hidden dirs (`.claude`, `.opencode`) that the recursive scan skips
- 215 skills total: 11 submodules + 7 self-authored + 181 from opencode's built-in registry (trailofbits, symfony, antfu, nuxt, etc.)

### Quality gates

- **Local**: `make lint` runs pre-commit (JSON, merge conflicts, large files, gitleaks, markdownlint), `make smoke` (`opencode run --agent build 'OK'`)

- **Central**: GitLab CI job `gitleaks` scans the repo on every push
- **Conventional Commits**: enforced by `commitlint.config.mjs`
- **Makefile targets**: `lint`, `smoke`, `skills-update` (refresh submodules)

### TUI extensions

- Server plugins registered in `opencode.json` `"plugin"` array

- TUI extensions (slash commands `/tokens_*`, sidebar, toasts, compact line) registered in `~/.config/opencode/tui.json`
- Display settings in `~/.config/opencode/quota-toast.jsonc`

## Skills catalog

| Source | Skills | License |
|--------|--------|---------|
| `pbakaus/impeccable` | 1 | Apache-2.0 |
| `antfu/skills` | 19 | MIT |
| `onmax/nuxt-skills` | 14 | — |
| `mcollina/skills` | 11 | MIT (Matteo Collina, Node TSC) |
| `laravel/agent-skills` | 3 | — (official org) |
| `dev-toolings/superpowers-symfony` | 44 | MIT |
| `Lombiq/Tailwind-Agent-Skills` | 1 | BSD-3-Clause |
| `trailofbits/skills` | 80 | CC-BY-SA-4.0 |
| `wsvincent/django-skills` | 1 | MIT |
| `edgarMeinart/ruby-rails-rspec-skill` | 1 | — |
| `leonardomso/rust-skills` | 1 | MIT |
| **Self-authored** | **7** | MIT/CC0 |

## Usage

```md
bash
opencode run "Your task here"
make lint      # pre-commit + markdownlint + gitleaks check
make smoke     # opencode run --agent build 'OK'
make skills-update  # git submodule update --remote --recursive
opencode --help   # CLI options

```

## License

MIT - see LICENSE

## CHANGELOG

All notable changes to this project are documented in `CHANGELOG.md` (Keep a Changelog format, Semantic Versioning).
