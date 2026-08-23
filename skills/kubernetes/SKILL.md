---
name: kubernetes
description: Container orchestration platform using Deployments, Services, Ingress, and Custom Resources. Use when working with kubectl, Helm charts, Ingress controllers, CSP integration (GCP/AWS/Azure), and pod/cluster lifecycle management.
license: MIT
compatibility: opencode
metadata:
  domain: infrastructure
  triggers: kubernetes, k8s, deployment, service, ingress, helm, crd, cluster
  related-skills: docker-swarm, terraform, ansible
---
# Kubernetes

## When to use

- Managing Deployments, Services, and Ingress resources.
- Writing or extending Helm charts.
- Debugging pod restarts, OOM kills, or scheduler conflicts.
- Integrating with cloud provider load balancers (GKE, EKS, AKS).

## Core principles

- **Stateless services** should use Deployments with `replicas: N`; stateful workloads use StatefulSets.
- **Resource requests/limits** must be specified to avoid scheduler starvation.
- **TLS certificates** for ingress should be managed via cert-manager or Vault, never hand-edited.
- **Never commit** `kubeconfig` files containing cluster secrets.

## Workflow

1. `kubectl get pods,svc,ing -A` to inspect cluster state.
2. `kubectl describe <resource>` for debug.
3. `helm lint <chart>` MUST pass before any chart change.
4. `kubectl apply -f <file>` for declarative apply; prefer `helm upgrade --install` for charts.

## Anti-patterns

- Running `kubectl delete` without a plan; prefer declarative `apply` to reach desired state.
- Mixing imperative and declarative operations in the same pipeline.
- Hardcoding image `:latest` tags in Deployment specs.
- Committing `kubeconfig` or CA certs to git.