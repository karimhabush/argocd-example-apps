# Kustomize Guestbook — Kustomize Demo

## What This Showcases

This app demonstrates Kustomize, Kubernetes' built-in configuration management tool. Kustomize lets you customize YAML manifests declaratively using name prefixes, common labels, patches, and overlays — all without any templating language.

ArgoCD has native Kustomize support: it detects the `kustomization.yaml` file and runs `kustomize build` automatically.

## Key Kustomize Features Demonstrated

- **namePrefix** — All resource names are automatically prefixed with `kustomize-`
- **commonLabels** — The label `app.kubernetes.io/managed-by: kustomize` is added to every resource and selector

## Files

- `kustomization.yaml` — Kustomize configuration (namePrefix, commonLabels, resource list)
- `deployment.yaml` — Base Deployment for nginx with ConfigMap-mounted HTML
- `configmap.yaml` — ConfigMap containing the HTML status page
- `service.yaml` — Service exposing the deployment on port 80

## How to Use

### Create the ArgoCD Application

```bash
argocd app create kustomize-guestbook \
  --repo <repo-url> \
  --path kustomize-guestbook \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace kustomize-guestbook
```

### Sync the Application

```bash
argocd app sync kustomize-guestbook
```

### Verify the Deployment

```bash
kubectl port-forward svc/kustomize-guestbook-ui -n kustomize-guestbook 8080:80
```

Then open http://localhost:8080 in your browser. You should see a purple status page titled "Kustomize Guestbook".

Note the service name is `kustomize-guestbook-ui` — Kustomize automatically applied the `kustomize-` prefix.

## What to Observe

- In the ArgoCD UI, all resources have the `kustomize-` name prefix applied.
- Every resource carries the `app.kubernetes.io/managed-by: kustomize` label.
- ArgoCD shows the rendered (post-Kustomize) manifests, not the raw base files.

## How to Test

1. Change the `namePrefix` in `kustomization.yaml` (e.g., to `demo-`).
2. Add additional `commonLabels`.
3. Create an overlay directory with environment-specific patches.
4. Commit, push, and sync to see the changes reflected in the cluster.
