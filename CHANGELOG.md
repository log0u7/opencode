# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Formatter enabled (prettier, terraform, ruff, gofmt)
- MCP server context7 for documentation lookups
- `autoupdate: "notify"` for update notifications without automatic installation
- `share: "disabled"` to prevent automatic session sharing
- `enabled_providers` allowlist for provider control
- Pinning `small_model`, `title`, `summary`, `compaction` agents to `qwen3.5-9b-mtp` to avoid model swap overhead with `--models-max 1`
- Conventional commits workflow
- Semver release tags
- `shfmt` 3.8.0 via apt (dépôts distro)
- `gh` 2.98.0 via repo apt officiel cli.github.com (keyring signé)
- `glab` 1.114.0 via .deb officiel, sha256 vérifié

### Changed

- `build` and `explore` agent models renamed to `qwen3.5-9b-mtp`
- `glm-4.7-flash` name updated to include `(think, coder)`
- `qwen3.5-9b` name updated to include `(think, generalist)`
- `qwen3.5-9b-nt` name updated to include `(nothink, generalist)`
- `qwen3-coder-30b` name updated to include `(nothink, coder)`

### Planned

- Sandboxing: Evaluate bubblewrap wrapper or `opencode-sandbox` plugin for command execution containment
- Install `shfmt` for bash script formatting

## [0.1.0] - 2026-08-23

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
