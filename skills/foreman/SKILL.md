---
name: foreman
description: Foreman 3.16 bare-metal and VM provisioning with Smart Proxy (DHCP, DNS, TFTP, iPXE), hostgroup classification, ERB provisioning templates, and hostgroup-driven Ansible model. Use when working with Foreman hostgroups, the foreman stack, Smart Proxy, PXE provisioning, provisioning templates, or host classification.
license: MIT
compatibility: opencode
metadata:
  domain: infrastructure
  triggers: foreman, smartproxy, pxe, ipxe, tftp, dhcp, dns, hostgroup, bare metal, provisioning, ansible
  related-skills: ansible, docker-swarm, traefik
---
# Foreman

## When to use

- Working on the `foreman` or `net` stacks (Foreman, Smart Proxy, DNS, DHCP, TFTP).
- Creating or editing provisioning templates (ERB).
- Changing host classification or hostgroups that drive Ansible provisioning.
- Debugging PXE boot, DHCP/DNS/TFTP failures, or host provisioning.

## Workspace context (Virtuos)

Foreman 3.16 runs as a Docker Swarm stack (`infra/docker/poc/docker/foreman/`) with PostgreSQL, Redis, Sidekiq, plus a Smart Proxy container (DHCP, PowerDNS, TFTP, Ansible, Remote Execution, Discovery). The image is RPM-based, built from `infra/docker/images/foreman/`, and self-bootstraps (`db:migrate && db:seed`).

## Hostgroup model (MUST)

- Hostgroups map to Ansible groups: `foreman_` prefix, lowercase, non-alphanumeric chars replaced by `_`, one group per path level.
- Two orthogonal axes: location/studio (`foreman_location_*`) and OS/role (`foreman_windows*`).
- **Verify normalized names** with `ansible-inventory -i inventories/foreman.yml --graph` before targeting a group. A `-GUI` suffix (e.g. `Windows/Client/11/BM-GUI`) becomes `foreman_windows_client_11_bm_gui`, which does NOT match `foreman_windows_client_11_bm`. BM-GUI hostgroups are aliased to canonical `*_bm` groups via the `groups:` block in `inventories/foreman.yml`.
- Windows provisioning is a 3-phase flow (SSH bootstrap, AD join + hardening, WinRM/Kerberos for build machines). Write templates and tasks with the WinRM-only future in mind.

## Provisioning templates

- ERB templates live in `infra/misc/foreman-templates/` (deprecated, being absorbed into devopslab `feature/foreman-iac`).
- New Foreman work should follow the `feature/foreman-iac` direction: declarative YAML state, idempotent reconciliation.
- Templates cover: `windows_wiman_ipxe`, `windows_wiman_provision`, `windows_wiman_finish`, `windows_wiman_psSetup.cmd`, `windows_wiman_user-data`.

## Smart Proxy conventions

- HTTPS + Kerberos for Windows hosts; do not bypass auth.
- SSH keypair generated at first boot for Remote Execution; keep private keys out of the repo.
- DHCP/DNS/TFTP configs are templated (`*.tpl`) in the `net` stack. Edit the `.tpl` source, never the rendered file.

## Workflow

1. Check Foreman stack health: `make status STACK=foreman` / `STACK=net`.
2. For hostgroup work, verify the normalized group name first (see above).
3. For template work, edit the ERB template source and validate via the provisioned host result.
4. Provisioning runs happen through GitLab CI (`prod::provision`), triggered by Foreman webhooks. Never run provisioning manually against production.

## Anti-patterns

- Modifying the Foreman database directly instead of templates/API.
- Assuming hostgroup names match without verifying the normalized form.
- Hardcoding task includes in playbooks instead of using the `<group>_<action>.yml` convention.
- Writing templates that assume a local SSH account always exists.
- Committing Smart Proxy private keys or DHCP credentials.