# Contributing

## Conventional Commits

All commits must follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` New feature
- `fix:` Bug fix
- `chore:` Maintenance, config, tooling
- `docs:` Documentation
- `refactor:` Code changes that neither fix bugs nor add features
- `test:` Test-related changes

## Semver

- **MAJOR** (v1.x.x): Breaking API changes
- **MINOR** (vx.y.x): New features, backwards compatible
- **PATCH** (vxy.z): Bug fixes, backwards compatible

## Changelog

Follow [Keep a Changelog](https://keepachangelog.com/).

- `[Unreleased]`: Pending changes
- `[v0.1.0]`: Previous releases with date

## Submodule Workflow

1. Clone with submodules:

   ```bash
   git clone --recursive https://<your-remote>/opencode
   ```

2. Update submodules:

   ```bash
   git submodule update --init --recursive
   ```

3. Commit changes:

   ```bash
   git add .
   git commit -m "chore: ..."
   git push
   ```

## Code Style

- JSON/JSONC for config files
- Markdown for agents/commands/skills
- JavaScript (CJS) for plugins

## Security

- No secrets in commits
- API keys in environment variables only
- Review all bash commands in agent prompts
