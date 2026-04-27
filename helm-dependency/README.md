# Helm Dependency Demo

This example demonstrates how ArgoCD handles **Helm chart dependencies** -- consuming and deploying upstream (off-the-shelf) charts with version pinning and custom value overrides.

## What This Showcases

- Using `Chart.yaml` dependencies to pull an external Helm chart (Bitnami nginx)
- Version pinning to a specific chart release
- Overriding upstream chart values through the parent chart's `values.yaml`
- ArgoCD automatically resolving and building Helm dependencies

## How Chart.yaml Dependencies Work

The `Chart.yaml` declares a dependency on the Bitnami nginx chart:

```yaml
dependencies:
  - name: nginx
    version: "18.3.1"
    repository: "https://charts.bitnami.com/bitnami"
```

- **name**: The chart name in the upstream repository
- **version**: Pinned semantic version (ensures reproducible deployments)
- **repository**: The Helm repository URL where the chart is hosted

## How ArgoCD Resolves Dependencies

When ArgoCD detects a `Chart.yaml` with dependencies, it automatically runs `helm dependency build` before rendering templates. This means:

1. ArgoCD downloads the pinned chart version from the specified repository
2. The dependency is stored in the `charts/` directory (managed automatically)
3. ArgoCD renders the parent chart along with all dependencies
4. Values from the parent `values.yaml` are passed down to the dependency using the chart name as a key prefix (e.g., `nginx.replicaCount`)

## How to Deploy

```bash
argocd app create helm-dependency \
  --repo <repo> \
  --path helm-dependency \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace helm-dependency
```

## What to Observe

- ArgoCD pulls the Bitnami nginx chart and deploys it with your overrides
- The custom ConfigMap provides a styled HTML page served by nginx
- Changing `nginx.replicaCount` in `values.yaml` scales the deployment
- The dependency version is locked, ensuring consistent deployments

## How to Test

1. Deploy the app with ArgoCD
2. Port-forward to the nginx service and see the orange-themed page
3. Change `nginx.replicaCount` to `3` in `values.yaml`
4. Push the change and sync in ArgoCD
5. Observe the pods scale from 1 to 3
6. Try overriding values via the ArgoCD CLI: `argocd app set helm-dependency -p nginx.replicaCount=5`
