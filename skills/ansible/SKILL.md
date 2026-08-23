---
name: ansible
description: Write and maintain Ansible playbooks, roles, and inventories for configuration management and orchestration. Use when managing Unix/Linux/Windows hosts, dynamic Foreman inventory, and idempotent resource modeling.
license: MIT
compatibility: opencode
metadata:
  domain: infrastructure
  triggers: ansible, playbook, role, inventory, foreman, dynamic, ad-hoc
  related-skills: terraform, docker-swarm, foreman
---
# Ansible

## When to use

- Managing Unix/Linux/Windows hosts for package, service, or file configuration.
- Using dynamic inventory from Foreman or AWS EC2.
- Writing idempotent playbooks that can be re-run without side effects.
- Orchestrating multi-step deployment flows (Terraform → Ansible → Register).

## Core principles

- **MUST** use FQCN for all modules (`ansible.builtin`, `community.general`, `ansible.windows.*`, `chocolatey.chocolatey.*`, `theforeman.foreman.*`).
- **MUST** check idempotency with `ansible-playbook --check` before any run against production.
- **MUST NOT** use `when: .*` expressions that depend on fact values not guaranteed to exist.
- **MUST** use `ansible-galaxy collection install -r requirements.yml` to lock collections.

## Workspace conventions (Virtuos)

- Foreman-driven inventory: `inventories/foreman.yml` is the dynamic inventory source.
- Dev uses `inventories/dev.ini`; never target prod inventory directly.
- ARA callback is enabled by default; do not remove it.
- Windows provisioning uses WinRM; keep SSH as fallback only.

## Workflow

1. `ansible-galaxy collection install -r requirements.yml`.
2. `ansible-playbook --syntax-check <playbook>`. MUST pass.
3. `ansible-playbook --check <playbook>` — review dry-run before any apply.
4. `ansible-playbook <playbook> -i <inventory>`.

## Anti-patterns

- Writing playbooks that are not idempotent (`win_package` without `product_id`/`creates_path`).
- Hardcoding host IPs instead of using dynamic inventory.
- Skipping `--check` on production inventory.
- Committing vault passwords or secrets in plaintext.