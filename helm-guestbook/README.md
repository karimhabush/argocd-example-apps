# Helm Guestbook

This example demonstrates how ArgoCD deploys and manages a **Helm chart**. It showcases Helm value files, environment-specific overrides, and parameter changes through the ArgoCD UI or CLI.

## What This Showcases

- A complete Helm chart with templates, values, and helpers
- Environment-specific value overrides (e.g., `values-production.yaml`)
- ArgoCD rendering and tracking Helm charts for drift detection
- ConfigMap-driven content that updates visually when values change

## How Helm Values Work with ArgoCD

ArgoCD natively supports Helm charts. When you point ArgoCD at a directory containing a `Chart.yaml`, it will:

1. Render the chart templates using the specified values
2. Deploy the rendered manifests to the target cluster
3. Continuously compare the live state against the rendered templates
4. Detect and optionally auto-correct any drift

## How to Deploy

```bash
argocd app create helm-guestbook \
  --repo <repo> \
  --path helm-guestbook \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace helm-guestbook
```

### Using Production Values

```bash
argocd app create helm-guestbook-prod \
  --repo <repo> \
  --path helm-guestbook \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace helm-guestbook-prod \
  --values values-production.yaml
```

### Overriding Values from the ArgoCD CLI

```bash
argocd app set helm-guestbook -p app.color="#e74c3c"
argocd app set helm-guestbook -p app.subtitle="Custom Override"
argocd app set helm-guestbook -p replicaCount=5
```

## What to Observe

- Changing `values.yaml` or using overrides triggers a new sync
- The configmap checksum annotation forces pod rollouts when content changes
- Production values change the color, subtitle, replica count, and service type
- ArgoCD shows the diff between the current and desired state

## How to Test

1. Deploy the app with ArgoCD
2. Port-forward and view the blue page in your browser
3. Change a value (e.g., `app.color` to `#e74c3c`) in `values.yaml`
4. Push the change and sync in ArgoCD
5. Observe the page now shows a different color
6. Try deploying with `--values values-production.yaml` and compare
