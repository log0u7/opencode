---
name: nginx
description: Nginx web server and reverse proxy management. Use when editing nginx.conf, configuring server blocks, managing SSL certificates via certbot/mod_ssl, load balancing, and deploying as both origin and edge proxy alongside Traefik.
license: BSD-2-Clause
compatibility: opencode
metadata:
  domain: infrastructure
  triggers: nginx, web server, server block, ssl, certbot, load balancer, proxy
  related-skills: traefik, apache
---
# Nginx

## When to use

- Editing `nginx.conf` or site configs under `/etc/nginx/sites-enabled/`.
- Managing SSL/TLS certificates with `certbot` or `certbot-nginx`.
- Configuring upstream blocks for backend service load balancing.
- Deploying as an edge proxy or internal reverse proxy alongside Traefik.

## Core principles

- **MUST** test configuration with `nginx -t` before reloading `systemctl reload nginx`.
- **MUST** use `ssl_certificate` and `ssl_certificate_key` paths managed by certbot; never hardcode cert paths.
- **SHOULD** use `return 301 https://$host$request_uri;` in the `server { }` block for HTTP-to-HTTPS redirect.
- **MUST** log rotation via `logrotate`; never let access/error logs grow unbounded.

## Workflow

1. `nginx -t` — MUST pass before `systemctl reload nginx` or `nginx -s reload`.
2. Edit config files; deploy via configuration management (Ansible/Terraform).
3. `systemctl reload nginx` to apply changes.
4. Verify with `curl -I https://<host>/` that the new server block responds.

## Anti-patterns

- Reloading Nginx without running `nginx -t` first.
- Using `location / { proxy_pass }` without `proxy_set_header Host $host;` (causes redirect loops).
- Committing SSL private keys or Let's Encrypt paths in plaintext in git.
- Using `limit_conn`/`limit_req` without monitoring; can cause silent request drops.