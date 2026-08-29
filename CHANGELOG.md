# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `@slkiser/opencode-quota`: quota monitoring + `/tokens_*` reports via opencode.db local; runtime points at the local fork `/home/logout/opencode-quota` (403 EntitlementError fix, upstream issue slkiser/opencode-quota#247, PR #248 open) - switch back to the npm package once a release above 4.8.2 ships it
- Submodule `nextlevelbuilder/ui-ux-pro-max-skill` (MIT, 120k stars): 7 UI/UX design skills via dual path `skills/` and `skills/ui-ux-pro-max/.claude/skills/`
- AGENTS.md rule: always verify subagent findings (reviewer/investigator) before acting
- AGENTS.md rule: all committed artifacts English-only
- AGENTS.md rule: new projects start versioning at `0.0.0` (SemVer initial development), not `1.0.0`
- AGENTS.md rule: present the full plan in the chat reply before calling the plan exit tool (plan file stays background)
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
- `venomous2/opencode-seo` (MIT, v0.20.2, commit 6fa3a45): SEO suite installed via official `install.sh`, no DataForSEO credentials configured (deterministic layer only): 88 skills, 4 agents, 12 slash commands, data layer + 54 YAML rules under `seo-suite/`; offline lint verified (`seo_lint.py --file`)
- Self-authored skills: `web-fundamentals` (HTML/CSS/vanilla JS), `jquery`, `php-lang`, `flask-fastapi`, `cpp`, `asm-x86-arm`, `ruby` (wrapper over ruby-rails-rspec-skill)
- Patched `opencode-damage-control` 1.5.0 locally (dist in `~/.cache/opencode/packages/`): directory patterns (`out/`, `dist/`, ...) now match on path-segment boundaries instead of raw substring (`/home/logout/...` no longer trips `out/`); `paths.override "out/": "none"` removed, the guard is active again with correct matching. Upstream: issue whjvenyl/opencode-damage-control#1, fix branch `fix/path-protection-segment-matching` on fork `log0u7/opencode-damage-control` (PR creation blocked server-side by GitHub at this time). Re-apply the patch if the opencode plugin cache is refreshed before an upstream release ships the fix.

### Planned

- Sandboxing: Evaluate bubblewrap wrapper or `opencode-sandbox` plugin for command execution containment
- `nigel-dev/opencode-mission-control`: parallel AI sessions in git worktrees + tmux (heavy)
- `@devtheops/opencode-plugin-otel`: OTLP telemetry (waiting for OTEL stack)
- `apisec-inc/mcp-audit`: scan configs (on first local stdio MCP)

### Changed

- `damage-control.json`: unprotect `node_modules/` and `/etc/` (substring matching flagged benign diagnostics like `ls node_modules 2>/dev/null` as writes); replace over-broad `Recursive delete from root` (`rm\s+-rf\s+/` matched any absolute path) and `Pipe curl to shell` (`\|\s*sh` matched `| sha256sum`) with anchored patterns; reorder rm patterns so anchored root/home blocks precede the re-added generic rm ask (first match wins, added patterns run last). Validated 24/24 simulated cases against the installed 1.5.0 plugin (`/tmp/opencode/dc-audit-test.mjs`); audit evidence: 23 path blocks in the log, 100% false positives except 1 legitimate ask (`out/` matched every `/home/l-out-/...` absolute path)
- `quota-toast.jsonc`: explicit `enabledProviders` `["openrouter"]` - OpenCode Go source disabled until subscription (the `opencode` auth.json key made the plugin poll the Go usage API, answering 403 EntitlementError toasts on every idle/interrupt); anthropic/openai disabled as quota sources; reason documented as JSONC comment in the file. **Moved** from `~/.config/opencode/quota-toast.jsonc` to `~/.config/opencode/opencode-quota/quota-toast.jsonc` - the path the plugin actually reads (config.ts:206); the file at the old path was never loaded, which is why the 403 persisted across restarts
- `opencode.json`: `disabled_providers` `["anthropic", "openai"]` (authed but unused; models route via openrouter/llamacpp-ricinus)
- Run opencode-quota from the local fork (`/home/logout/opencode-quota/dist`) in `opencode.json` + `tui.json` with `opencode-go` re-enabled: the fork patches the repeated 403 EntitlementError toasts (silent not-subscribed skip, upstream issue #247 / PR #248); revert both entries to `@slkiser/opencode-quota` once a release carries the fix. PR #245 also updated with a corrected free-tier test
- `quota-toast.jsonc`: `showOnIdle: false` - the interrupt pop is the `session.idle` event, so this disables idle + interrupt toasts while keeping the sidebar panel; `enableToast: false` would silence every toast
- `damage-control.json`: added `Recursive delete of a home directory` block pattern (`rm -rf /home/<user>` as complete arg) to back the narrowed opencode.json bash globs
- `opencode.json`: removed JSONC comments (strict-JSON consumers logged `WARN Failed to add detected providers... Cannot parse JSON config`); `permission.edit` `ask` -> `allow` (dangerous edits still guarded by damage-control path tiers); anchored over-broad bash deny globs (`rm -rf /*`, `rm -rf ~*`, `rm -rf ..*`, `chmod -R 777 /*` matched every absolute path because the glob `*` crosses `/`) down to exact catastrophic forms (`rm -rf /`, `rm -rf ~`, `rm -rf ~/`, `rm -rf ..`); `external_directory` now allows `/tmp/opencode/**` permanently (scratch dir) with `*` still `ask`
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
