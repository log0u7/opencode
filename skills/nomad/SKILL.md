---
name: nomad
description: Manage HashiCorp Nomad clusters for job scheduling and task orchestration. Use when working with Nomad clients/servers, job definitions, resource pools, and integration with Consul or Vault for service discovery.
license: MIT
compatibility: opencode
metadata:
  domain: infrastructure
  triggers: nomad, job, scheduler, cluster, server, client, consul, vault
  related-skills: terraform, ansible
---
# Nomad

## When to use

- Writing or editing Nomad job specification files (`*.hcl`).
- Managing cluster composition (server vs client roles).
- Integrating Nomad with Consul for service discovery or Vault for secrets.
- Debugging job placement failures or resource contention.

## Core principles

- **Job specs** should be declarative, version-controlled, and reviewed before apply.
- **Resource limits** (mem, cpu) must be specified; unbounded resources can cause starvation.
- **Affinity/anti-affinity** rules should be explicit, not implicit.
- **TLS certificates** for RPC and GUI should be managed centrally (Vault/RA), never hardcoded.

## Workflow

1. `nomad job status <job>` to check health.
2. `nomad job run <job>` to submit, or edit `.hcl` and re-run.
3. Use `nomad alloc status` for debug.
4. Validate job HCL with `nomad job validate <job>` if available.

## Anti-patterns

- Omitting `type` field in job definitions (defaults to `service`, which may not be desired).
- Hardcoding too many resources on a single server node.
- Skipping drift detection between job spec and actual allocations.