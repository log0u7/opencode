.PHONY: lint smoke skills-update

lint:
	pre-commit run --all-files

smoke:
	opencode models > /dev/null && opencode run --agent build 'Reply with exactly: OK'

skills-update:
	git submodule update --remote --recursive
