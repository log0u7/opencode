---
name: traefik
description: "Configure and debug Traefik 3 as the edge reverse proxy for Docker Swarm: TLS termination across four modes (none/le/ss/ca), Docker label auto-discovery, middleware chains, and HTTP routing. Use when editing edge stack configs, adding routing labels to a service, managing certificates, or troubleshooting 502s/redirects/TLS issues."
license: MIT
compatibility: opencode
metadata:
  domain: infrastructure
  triggers: traefik, reverse proxy, tls, letsencrypt, middleware, load balancer, docker labels, edge stack, ingress, certificate, http routing
  related-skills: docker-swarm
---
# Traefik

## When to use

- Adding or changing routing for an HTTP service in the platform.
- Managing TLS modes and certificates on the edge stack.
- Configuring middleware (rate limiting, auth, security headers, IP whitelisting).
- Debugging reverse proxy issues (502, redirect loops, TLS failures).

## Core principles

- Traefik auto-discovers services from Docker labels, not manual config edits.
- A new service is exposed by adding labels, not by editing Traefik config.
- TLS is handled centrally at the edge; services stay plain HTTP internally.
- Never mount the Docker socket read-write; always `:ro`.

## Workspace conventions (Virtuos)

The edge stack lives in `infra/docker/poc/docker/edge/`. Four TLS modes are selected via `TLS_PROVIDER` in `.env`:

- `none`: no TLS, plain HTTP.
- `le`: Let's Encrypt, automatic certs (TLS challenge on port 443 preferred).
- `ss`: self-signed cert auto-generated via `make ssl`.
- `ca`: authoritative CA, certs placed manually in `docker/edge/certs/`, fails loudly if absent.

Additional rules:

- Config is templated from `*.tpl` files; **MUST NOT** edit rendered configs.
- HTTP services MUST expose at `https://<service>.${DOMAIN}` with Traefik labels (`traefik.enable=true`, router, service, port).
- Use `exposedByDefault=false` so internal services are not accidentally routed.
- Store `acme.json` on a persistent volume; never commit it.
- Label taxonomy from `docker-compose.template.yml`: `service.*`, `stack.*`, `monitoring.*`, `security.*`. Reuse anchors, do not copy-paste.
- Add health checks to every routed service; Traefik uses them for load balancing.
- Middleware examples: HTTP to HTTPS redirect, security headers (HSTS, nosniff, frame-deny), basic auth for admin panels, rate limiting, compression.

## Workflow

1. Read the current `TLS_PROVIDER` and edge config in `docker/edge/`.
2. Edit the `.tpl` source or compose labels.
3. `make validate STACK=edge` MUST pass.
4. `make up STACK=edge`, then confirm `https://<service>.${DOMAIN}` responds.

## Anti-patterns

- Mounting the Docker socket without `:ro`.
- Exposing services without labels or with `exposedByDefault` enabled.
- Using the HTTP challenge when TLS challenge (443) is possible.
- Committing `acme.json` or private keys.
- Editing rendered Traefik configs instead of `.tpl` sources.
- Skipping middleware for admin endpoints (basic auth, IP whitelist).