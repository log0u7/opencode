---
name: ovh
description: OVHcloud resource management and networking. Use when provisioning VPS, dedicated servers, OpenStack-based instances, domain DNS, and SIP trunking via the OVH API. Integrate with Terraform and Ansible for automated deployment of workloads on OVH infrastructure.
license: Apache-2.0
compatibility: opencode
metadata:
  domain: cloud
  triggers: ovh, so-baremetal, cloud, dedicated, dns, sip, api
  related-skills: terraform, ansible, gcp
---
# OVH

## When to use

- Provisioning VPS (`so/baremetal`) and dedicated servers via the OVH API.
- Managing DNS zones and domain records for domains hosted on OVH.
- Configuring SIP trunking for VoIP integrations.
- Automating deployment of workloads on OVH Cloud with Terraform or Ansible.

## Core principles

- **MUST** use the OVH `endpoint` (manager, gw, or rac) appropriate to the service region.
- **MUST** rotate `consumer-key`/`consumer-secret`/`app-key` triad regularly; never hardcode in Terraform/Ansible.
- **MUST** validate DNS changes via `ovh` CLI before applying via automation.
- **MUST** respect OVH SLA terms; bare-metal redeployments may require manual intervention.

## Workflow

1. `ovh-cli login` to obtain the three-key credential triad.
2. `ovh-cli domain list` to view managed domains.
3. `terraform init` with `provider "ovh"` to configure the provider.
4. `terraform plan` — review IP changes and SLA implications.
5. `terraform apply` through CI pipeline.

## Anti-patterns

- Hardcoding `consumer-key` in plaintext within Terraform or Ansible code.
- Applying DNS changes without reviewing the `ovh` CLI diff output first.
- Using `so/baremetal` for latency-sensitive workloads without testing the physical network path.
- Skipping `make validate`-equivalent checks before `terraform apply`.