---
name: docker-swarm
description: Deploy and manage Docker Swarm stacks with Makefile-driven lifecycle, overlay networks, and Traefik edge proxy. Use when working with docker stack make targets, service labels, TLS modes (none/le/ss/ca), and `make validate`/`make up` workflows.
license: MIT
compatibility: opencode
metadata:
  domain: infrastructure
  triggers: docker, swarm, make, compose, traefik, overlay, edge
  related-skills: traefik, foreman, ansible
---
# Docker Swarm

## When to use

- Adding or changing services in a Docker Swarm stack.
- Configuring TLS termination via the edge stack (Traefik).
- Running `make validate` or `make up` targets.
- Managing overlay networks and service discovery.

## Core principles

- **MUST** use `make validate [STACK=<name>]` before any `docker compose` or `make up` change.
- **MUST** keep `exposedByDefault: false` so internal services are not accidentally routed.
- **MUST NOT** edit rendered configs; edit `*.tpl` template sources instead.
- **MUST** use label taxonomy `service.*`, `stack.*`, `monitoring.*`, `security.*`.
- **MUST** pin image versions via `.env.versions`, never hardcode tags.
- Services MUST attach only to networks they use (Interface Segregation).

## Workspace conventions (Virtuos)

The edge stack lives in `infra/docker/poc/docker/edge/`. Four TLS modes are selected via `TLS_PROVIDER` in `.env`:

- `none`: no TLS, plain HTTP.
- `le`: Let's Encrypt, automatic certs.
- `ss`: self-signed cert auto-generated via `make ssl`.
- `ca`: authoritative CA, certs placed manually in `docker/edge/certs/`.

## Workflow

1. `make help` to list targets and current configuration.
2. Edit `*.tpl` sources, never rendered files.
3. `make validate STACK=<name>` MUST pass.
4. `make up STACK=<name>`, then confirm endpoints respond.

## Anti-patterns

- Editing rendered Traefik configs instead of `.tpl` sources.
- Exposing services without labels or with `exposedByDefault` enabled.
- Using the HTTP challenge when TLS challenge (443) is possible.
- Skipping `make validate` and claiming the task is done.