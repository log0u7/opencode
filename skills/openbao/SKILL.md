---
name: openbao
description: Open-source secrets management and zero-trust gateway, fork of HashiCorp Vault. Use when managing dynamic secrets, encryption-as-a-service, and token renewal for infrastructure and applications without Vault licensing restrictions.
license: MPL-2.0
compatibility: opencode
metadata:
  domain: security
  triggers: openbao, vault, secret, engine, cubbyhole, transit, token, rotation
  related-skills: ansible, gcp, aws
---
# OpenBao

## When to use

- Managing dynamic secrets (database credentials, API tokens) without Vault commercial features.
- Providing encryption-as-a-service via the Transit engine for data at rest.
- Issuing short-lived tokens with TTL and renewable policy for CI/CD pipelines.
- Integrating with Ansible via `hashi_vault` or `openbao` modules for secret injection.

## Core principles

- **MUST** enable `seal` redundancy; a single-seal configuration is a SPOF.
- **MUST** rotate root tokens every 90 days as a security best practice.
- **MUST** enable `audit` logging to an external destination (syslog, file, or external system).
- **TLS certificates** for the API gateway must be managed via ACME or auto-generated; never self-signed in production without a documented risk acceptance.

## Workflow

1. `openbao server -config=/etc/openbao.hcl` to start the server.
2. `openbao secrets enable secret/` to enable a secrets engine.
3. `openbao write secret/foo bar=baz` to store a secret.
4. `openbao read secret/foo` to retrieve (with proper auth).
5. Integrate with Ansible: `ansible.builtin.command` using `openbao exec` or `hashi_vault` module.

## Anti-patterns

- Running openbao without `ha_shards` and `ha_shards_progress` for production HA.
- Storing encryption keys in plaintext config files.
- Skipping `openbao audit enable` and relying on silent success.
- Using the dev server (`openbao server -dev`) in production environments.