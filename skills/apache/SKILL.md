---
name: apache
description: Apache HTTP Server administration, configuration, and module management. Use when editing httpd.conf, configuring VirtualHosts, managing .htaccess, and deploying mod_wsgi, mod_proxy, or mod_ssl modules for HTTP/HTTPS service deployment.
license: Apache-2.0
compatibility: opencode
metadata:
  domain: infrastructure
  triggers: apache, httpd, virtualhost, mod wsgi, mod proxy, mod ssl, .htaccess
  related-skills: nginx, traefik
---
# Apache HTTP Server

## When to use

- Editing `httpd.conf` or `apache2.conf` for new VirtualHosts.
- Configuring SSL/TLS via `mod_ssl` and managing certificate paths.
- Enabling/disabling modules with `a2enmod`, `a2dismod`.
- Deploying WSGI applications via `mod_wsgi` for Python integration.

## Core principles

- **MUST** test configuration syntax with `apachectl configtest` before reloading.
- **MUST** redirect HTTP to HTTPS via VirtualHost configuration, not `.htaccess` in production when avoidable.
- **MUST** manage certificate paths in `apache2.conf` or `httpd.conf`, never in `.htaccess` unless absolutely required.
- **SHOULD** use `ServerAlias` for vanity domains, not `ServerName` alone when multiple domains map.

## Workflow

1. `apachectl configtest` — MUST pass before any `apachectl graceful` or service restart.
2. Edit config files (`httpd.conf`, `ports.conf`); use configuration management (Ansible/Terraform) to deploy.
3. `systemctl reload apache2` / `httpd -k graceful` to apply changes.
4. Verify with `curl -I https://<host>/` that the new VirtualHost responds.

## Anti-patterns

- Reloading Apache without running `configtest` first (`apachectl graceful` without prior `configtest`).
- Using `.htaccess` for server-wide configuration when it should be in `httpd.conf` (performance, security).
- Committing SSL private keys or certificates in plaintext in repo.
- Mixing `mod_rewrite` rules that conflict with existing VirtualHost directives.