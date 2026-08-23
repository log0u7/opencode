---
name: aws
description: Amazon Web Services resources and management patterns. Use when provisioning EC2, VPC, IAM, S3, RDS, and Lambda via Terraform, managing IAM policies with least privilege, and integrating with OpenCode global skills for multi-cloud infrastructure. Follow remote state with locking and tagging conventions.
license: Apache-2.0
compatibility: opencode
metadata:
  domain: cloud
  triggers: aws, ec2, s3, iam, vpc, rds, lambda, terraform aws
  related-skills: terraform, gcp, ansible
---
# Amazon Web Services (AWS)

## When to use

- Provisioning EC2 instances, VPCs, security groups, and IAM roles.
- Managing S3 buckets with block-public-access settings and CMEK.
- Deploying RDS PostgreSQL/MySQL instances with backup retention policies.
- Running Lambda functions or Fargate tasks for serverless workloads.

## Core principles

- **MUST** apply least privilege to IAM policies; never use wildcard actions on sensitive resources.
- **MUST** tag every resource with `Environment`, `Project`, `ManagedBy`, `Repository` for cost attribution.
- **MUST** use remote state backend (S3 + DynamoDB locking) with encryption; never local state on shared environments.
- **MUST** pin provider and module versions in `versions.tf`; never mix unconstrained versions.

## Workflow

1. `terraform init` to download the `aws` provider.
2. `terraform fmt` then `terraform validate` — MUST pass before any plan.
3. `terraform plan -out=tfplan` — review destroys and diffs; never apply unread plans.
4. `terraform apply tfplan` through CI pipeline only; never ad-hoc on shared environments.

## Anti-patterns

- Hardcoding AWS access keys or secret keys in Terraform or Ansible code.
- Applying plans without review (`terraform apply` without `-out` flag).
- Leaving `0.0.0.0/0` on ports 22/3389 or database ports in security groups.
- Committing `.tfstate` or `*.tfvars` with sensitive values to git.