---
name: puppet
description: Configuration management using Puppet Enterprise or Open Source Puppet. Use when declaring desired system state via manifests (.pp), managing resources with Puppet Agent, and integrating with PuppetDB for reporting and external facts.
license: Apache-2.0
compatibility: opencode
metadata:
  domain: infrastructure
  triggers: puppet, manifest, agent, catalog, reporting, external_facts
  related-skills: ansible, salt
---
# Puppet

## When to use

- Declaring system state via Puppet manifests (.pp) for packages, services, and files.
- Managing nodes via Puppet Agent with centralized PuppetMaster.
- Generating reports from PuppetDB for compliance and audit.
- Integrating with external facts (DynamoDB, Hiera) for data-driven configurations.

## Core principles

- **MUST** keep Puppet Agent version aligned with PuppetMaster; mismatched versions cause catalog compilation failures.
- **Manifests** should be idempotent; `exec` resources must have `onlyif/unless` that are side-effect-free.
- **External facts** (Hiera, hiera-eyaml) should encrypt sensitive data; never store plaintext secrets in manifests.
- **Catalog compilation** should be tested locally with `puppet parser validate <manifest>.pp` before pushing.

## Workflow

1. `puppet parser validate <manifest>.pp` — MUST pass before any commit.
2. `puppet agent -t` to apply the catalog and reconcile state.
3. `puppet task show` to list available task modules.
4. `puppet module install <modname>` — pin versions in `.modulerc` or `Puppetfile`.

## Anti-patterns

- Writing manifests that are not idempotent (`creates`/`onlyif` with side effects).
- Hardcoding passwords or API keys in manifest body.
- Skipping `puppet parser validate` and claiming the task is done.
- Committing Hiera YAML with unencrypted sensitive data.