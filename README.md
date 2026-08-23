# opencode configuration

Personal OpenCode configuration directory.

## Layout

```
.
├── AGENTS.md              # Agent instructions
├── opencode.json          # Main config
├── agents/                # Custom agents (markdown)
├── commands/              # Custom commands (markdown)
├── plugins/               # Plugins (node.js)
├── skills/                # Agent skills (markdown)
├── package.json           # Plugin dependencies
├── package-lock.json      # Reproducible builds
├── .gitignore             # Git exclusions
├── LICENSE                # MIT
├── CHANGELOG.md           # Keep a Changelog
├── CONTRIBUTING.md        # Contribution guidelines
└── .caveman-*             # Runtime state (ignored)
```

## Providers

- **llamacpp-ricinus** : llama.cpp server (192.168.1.26:9931)
- **ollama-ricinus** : Ollama server (192.168.1.26:11434)
- **opencode** : OpenCode Zen (cloud)

## Submodules

- `skills/gitlab-ci-skill` : Official GitLab CI skill (submodule)

## Security

- API keys are factices (LAN only)
- No secrets in git (auth in `~/.local/share/opencode`)

## Usage

```bash
opencode run "Your task here"
```

## License

MIT - see LICENSE
