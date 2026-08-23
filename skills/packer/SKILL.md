---
name: packer
description: Build identical machine images from a single source configuration. Use when authoring Packer templates (HCL or JSON) for VM/ISO builds, integrating with AWS, VMware, Proxmox, or Docker output, and validating post-processor steps.
license: MIT
compatibility: opencode
metadata:
  domain: infrastructure
  triggers: packer, build, image, vm, iso, qemu, hyperv, vsphere, aws, gcp
  related-skills: terraform, ansible
---
# Packer

## When to use

- Creating or updating base images for hypervisors (KVM/libvirt, Hyper-V, Proxmox, VMware, AWS, GCP).
- Building Docker images as Packer post-processors.
- Automating reproducible OS image creation for CI/CD pipelines.

## Core principles

- **Never commit** Packer cache or intermediate build artifacts.
- **Templates** must pin the exact OS version and packer version.
- **Post-processors** should be idempotent; avoid destructive actions without explicit confirmation.
- **Build variables** (for example, `vm_image_size`) belong in `.env` or CLI flags, never hardcoded.

## Workflow

1. `packer validate <template>` MUST pass before any build.
2. `packer build <template>` to build images.
3. For iterative development, use `packer build -on-error` to stop on first failure.
4. Verify the output image with `qemu-img info` (for QEMU/VirtualBox) or equivalent.

## Anti-patterns

- Building without validating first (`packer validate`).
- Committing `.packer_cache/` or build artifacts.
- Using the same template for both VM and Docker outputs without clear separation.
- Skipping post-processor validation steps.