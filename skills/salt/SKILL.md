---
name: salt
description: Configuration management and remote execution using SaltStack. Use when managing Salt masters/minions, writing Salt states (.sls), orchestrating Salt SSH, and integrating with Salt Cloud for dynamic node provisioning.
license: Apache-2.0
compatibility: opencode
metadata:
  domain: infrastructure
  triggers: salt, master, minion, sls, state, ssh, cloud, orchestration
  related-skills: ansible, terraform
---
# Salt

## When to use

- Managing Salt masters and minion clusters for configuration orchestration.
- Writing Salt state files (.sls) for package, service, and file management.
- Using Salt SSH for agentless orchestration of heterogeneous fleets.
- Integrating with Salt Cloud for dynamic provisioning on AWS, GCP, OVH, and other clouds.

## Core principles

- **MUST** keep the Salt master API secured; bind to localhost or internal network only.
- **Minion configs** should reference the master via hostname, not IP, for dynamic environments.
- **SLS files** must be idempotent; re-running state.highstate must converge without drift.
- **Pillar data** must be encrypted and never committed to git.

## Workflow

1. `salt-key -L` to list accepted minions.
2. `salt '*' test.ping` to verify connectivity.
3. `salt '*' state.highstate` to apply all states.
4. `salt-cloud -p <profile> <node>` to provision on cloud.

## Anti-patterns

- Opening port 4505/4506 (Salt master) to the internet.
- Hardcoding credentials in SLS files or pillar data.
- Skipping `state.highstate --dry-run` equivalent before large runs.
- Mixing Salt and Ansible roles for the same resource without clear ownership.