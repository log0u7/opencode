# opencode configuration

Personal global configuration for [OpenCode](https://opencode.ai), versioned on GitLab. It defines providers and models, subagents, custom commands, plugins, skill discovery, quality gates, and TUI extensions.

## Layout

```text
.
├── opencode.json          # server config: providers, models, agents, plugins, permissions
├── tui.json               # TUI config: theme and TUI plugins
├── AGENTS.md              # global agent instructions
├── agents/                # 8 subagents
├── commands/              # 20 custom commands
├── plugins/               # local plugins (caveman)
├── skills/                # 120 local skills + 13 vendored submodules
├── themes/                # TUI themes (transparent)
├── opencode-quota/        # local quota plugin configuration
├── Makefile               # lint, smoke, skills-update
├── .pre-commit-config.yaml
├── commitlint.config.mjs
├── .markdownlint-cli2.jsonc
├── .gitlab-ci.yml
├── CONTRIBUTING.md
└── CHANGELOG.md
```

## Configuration

### Providers and models

| Provider | Description |
|---|---|
| `llamacpp-ricinus` | llama.cpp server at `192.168.1.26:9931` |
| `opencode` | OpenCode Zen |
| `opencode-go` | OpenCode Go |
| `openrouter` | OpenRouter |

`anthropic` and `openai` are disabled. The default and small model are both `openrouter/z-ai/glm-5.3-flash`; `build`, `plan`, and `general` use the same model. `mr-reviewer` uses `opencode-go/step-5-preview` because OpenRouter credits were exhausted.

### Agents

| Agent | Role |
|---|---|
| `cavecrew-builder` | surgical edits, 1 to 2 files |
| `cavecrew-investigator` | read-only code locator, returns `file:line` tables |
| `cavecrew-reviewer` | diff, branch, or file review, one finding per line |
| `mr-reviewer` | pre-merge gate: trace, run tests, list missing tests, verdict |
| `seo-technical-analyst` | crawlability, indexability, rendering, Core Web Vitals |
| `seo-content-analyst` | metadata, headings, depth, E-E-A-T, readability |
| `seo-competitive-analyst` | SERP landscape, keyword gaps, backlinks |
| `seo-ai-search-analyst` | AI Overview and LLM citation readiness |

`cavecrew-investigator`, `cavecrew-reviewer`, and `mr-reviewer` deny edits.

### Commands

20 commands:

- Caveman: `/caveman`, `/caveman-help`, `/caveman-review`, `/caveman-commit`, `/caveman-compress`, `/caveman-stats`
- Flow: `/mr-review`, `/go`
- SEO: `/site-audit`, `/citation-check`, `/compare`, `/content-refresh`, `/cro`, `/keyword-gap`, `/keyword-research`, `/new-post`, `/schema`, `/serp-analysis`, `/sxo`, `/briefing`

### Plugins

| Plugin | What it does |
|---|---|
| `plugins/caveman` | caveman mode, system prompt transform |
| `opencode-quota` (local fork) | quota status tool, sidebar panel, toasts |
| `opencode-pty` | `pty_*` interactive terminal tools |
| `openrtk` | routes allowlisted commands through `rtk` for output compression |
| `@dietrichgebert/ponytail` | lazy-senior-dev build ruleset |
| `@log0u7/opencode-memory@0.5.0` | shared SQLite working memory |
| `@log0u7/opencode-mesh@0.4.0` | multi-session and LAN or Tailscale coordination |
| `@log0u7/opencode-watt@0.3.0` | local inference power and cost sampling |

`opencode-worktree-guard` and `opencode-workflow-guard` are present but commented out.

- Memory exposes `memory_save`, `memory_search`, `memory_list`, `memory_forget`, `memory_stats`, and `memory_restore`, scoped per worktree plus `global`. The store is `~/.local/share/opencode-memory/memory.db`; reflection is off by default.
- Mesh exposes `mesh_*` tools: mDNS discovery, explicit pairing with per-peer bearer tokens (deny by default), messages, workers, and local file locks. Bind is loopback by default; state lives in `~/.local/share/opencode-mesh/`. Locks apply to sessions on the same host only.
- Watt exposes `power_cost` and samples local or SSH meters (`nvidia-smi`, `rocm-smi`, RAPL, hwmon) or Prometheus. The electricity tariff is auto-detected from the timezone, with a French fallback.

### Skills

423 `SKILL.md` files: 123 local, 300 from 14 vendored submodules (13 skill submodules plus `vendor/reverse-skill`).

| Submodule | `SKILL.md` files |
|---|---|
| `vendor/reverse-skill` | 89 |
| `trailofbits` | 80 |
| `symfony` | 44 |
| `nuxt-skills` | 20 |
| `antfu-skills` | 19 |
| `impeccable` | 17 |
| `ui-ux-pro-max` | 13 |
| `node-skills` | 11 |
| `laravel` | 3 |
| `django` | 1 |
| `gitlab-ci-skill` | 1 |
| `rust` | 1 |
| `tailwind` | 1 |
| `ruby-rails` | 0 (wrapped by the local `ruby` skill) |

`vendor/reverse-skill` is not a skills submodule: it is deliberately kept out of `skills.paths` and routed through the single local `reverse-skill` wrapper, so its 89 sub-skills stay hidden behind one router skill.

`impeccable` ships the same skill in 17 provider layouts (`.opencode`, `.claude`, `.cursor`, and others), so the number of unique skills is lower than the file count.

The 123 local skills cover the caveman and cavecrew helpers, the anti-slop pair (`antislop`, `antislop-code`), the SEO suite (audits, keywords, content, schema, AI search), and language or stack notes (C++, PHP, Ruby, Flask and FastAPI, jQuery, web fundamentals, x86 and ARM assembly).

### MCP servers

Pinned in `opencode.json` (`mcp` block), all enabled:

- `context7` (remote): up-to-date library documentation
- `serena` 2.1.0 (local, `uv tool`): semantic code tools via LSP, `--context ide --project-from-cwd`
- `rea` 6.7.0 (local, npm `rea-agents`): reverse engineering
- `playwright` 0.0.83 (local, npm `@playwright/mcp`): browser automation, `--headless --isolated`

### Quality gates

- `make lint` runs pre-commit on all files: JSON check (`opencode.json` excluded because it is JSONC), merge conflict markers, large files, gitleaks, and markdownlint on first-party docs.
- `make skills-update` runs `git submodule update --remote --recursive`.
- `make smoke` runs `opencode models > /dev/null && opencode run --agent build 'Reply with exactly: OK'`.
- `commitlint.config.mjs` enforces Conventional Commits on `commit-msg`.
- GitLab CI runs a `gitleaks` job on every push.

### TUI extensions

`tui.json` sets the `transparent` theme and loads the quota TUI plugin. Quota display settings live in `opencode-quota/quota-toast.jsonc`; the only enabled quota provider is `openrouter`.

## Usage

```bash
make lint           # pre-commit over all files
make smoke          # provider and agent smoke test
make skills-update  # refresh skill submodules

opencode run "Summarize this repository"
```

Plugins are pinned in `opencode.json` and installed at startup into `~/.cache/opencode/packages/`; bump a pin to upgrade.

## License

MIT, see `LICENSE`.

## CHANGELOG

All notable changes are documented in `CHANGELOG.md` (Keep a Changelog, Semantic Versioning).
