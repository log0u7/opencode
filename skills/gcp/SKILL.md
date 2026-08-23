---
name: gcp
description: Google Cloud Platform resources and services management. Use when provisioning GKE clusters, Cloud Storage buckets, IAM policies, Cloud Functions, and Terraform provider configuration for GCP infrastructure. Integrate with OpenCode skills for multi-cloud Terraform workflows.
license: Apache-2.0
compatibility: opencode
metadata:
  domain: cloud
  triggers: gcp, google, gke, cloudfunctions, cloudstorage, iam, terraform gcp
  related-skills: terraform, aws, ansible
---
# Google Cloud Platform (GCP)

## When to use

- Provisioning GKE (Google Kubernetes Engine) clusters and node pools.
- Managing Cloud Storage buckets, IAM policies, and service accounts.
- Deploying Cloud Functions or Cloud Run services.
- Writing Terraform `provider "google"` configurations with pinned API versions.

## Core principles

- **MUST** use `gcloud auth application-default login` for ADC (Application Default Credentials) in CI pipelines.
- **MUST** pin `google` provider version in Terraform `required_providers`; pin `api_version` for stability.
- **MUST** restrict IAM using the principle of least privilege; avoid `roles/compute.admin` on production.
- **MUST** encrypt Cloud Storage buckets with Customer-Managed Encryption Keys (CMEK) for compliance.

## Workflow

1. `gcloud config set project <project-id>` to set the current project.
2. `gcloud services enable <service>` to enable required APIs (e.g., `gke`, `compute`).
3. `terraform init` to download the `google` provider.
4. `terraform plan` — review destroys and resource changes carefully.
5. `terraform apply` through CI, never ad-hoc on shared environments.

## Anti-patterns

- Committing `gcloud` auth credentials or key files to git.
- Using `roles/compute.admin` for routine operations (least privilege violation).
- Leaving `network::default` or `autoscaling::max` at default values in production.
- Skipping `terraform validate` before `terraform plan`.