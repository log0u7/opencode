---
name: vault
description: HashiCorp Vault for secrets management, encryption, and token renewal. Use when managing dynamic secrets, database credential rotation, and TLS certificate generation for infrastructure and applications. Prefer Vault over OpenBao when enterprise features (integrator, performance stand-ins, leak prevention) are required.
license: MPL-2.0
compatibility: opencode
metadata:
  domain: security
  triggers: vault, secret, engine, cubbyhole, transit, token, rotation, kms
  related-skills: ansible, aws, gcp
---
# Vault

## When to use

- Managing dynamic secrets (database credentials, API tokens) with short TTL and automatic rotation.
- Providing encryption-as-a-service via the Transit engine for data at rest and in transit.
- Issuing short-lived TLS certificates via PKI engine for service-to-service mTLS.
- Integrating with CI/CD pipelines for secret injection without hardcoded credentials.

## Core principles

- **MUST** enable seal split operation for HA; a single-seal configuration is a SPOF.
- **MUST** rotate root tokens regularly and limit `token_policies` to least privilege.
- **MUST** enable `audit` devices writing to immutable storage (S3, GCS, syslog).
- **TLS certificates** for the Vault API gateway must be externally managed (Cert-Manager, ACME) or auto-generated with documented risk acceptance.

## Workflow

1. `vault server -config=/etc/vault.hcl` to start the server.
2. `vault secrets enable secret/` to enable a secrets engine.
3. `vault write secret/foo bar=baz` to store a secret (with proper auth).
4. `vault read secret/foo` to retrieve.
5. `vault token create -policy=dev -ttl=1h` to generate a short-lived token.
6. Integrate with Ansible via `hashi_vault` module or `vault` CLI in exec modules.

## Anti-patterns

- Running Vault without `cluster_ha` and `seal_config` for production HA.
- Storing root tokens in version control or CI/CD pipeline logs.
- Skipping `vault audit enable` and relying on silent success.
- Using the dev server (`vault server -dev`) in production environments.