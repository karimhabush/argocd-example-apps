# Guestbook — Plain YAML Manifests

## What This Showcases

This is the simplest ArgoCD deployment pattern: raw Kubernetes YAML manifests with no templating engine. There is no Helm, no Kustomize — just plain YAML files that ArgoCD watches in Git and applies directly to the cluster.

This is the recommended starting point for understanding how ArgoCD works.

## Files

- `guestbook-ui-deployment.yaml` — Deployment running nginx with a ConfigMap-mounted HTML page
- `guestbook-ui-configmap.yaml` — ConfigMap containing the HTML status page
- `guestbook-ui-svc.yaml` — Service exposing the deployment on port 80

## How to Use

### Create the ArgoCD Application

```bash
argocd app create guestbook \
  --repo <repo-url> \
  --path guestbook \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace guestbook
```

### Sync the Application

```bash
argocd app sync guestbook
```

### Verify the Deployment

```bash
kubectl port-forward svc/guestbook-ui -n guestbook 8080:80
```

Then open http://localhost:8080 in your browser. You should see a red status page titled "Guestbook".

## What to Observe

- ArgoCD detects YAML changes in Git and applies them to the cluster.
- The ArgoCD UI shows each manifest as a separate resource in the application tree.
- There is no build step or template rendering — what you see in Git is exactly what gets applied.

## How to Test

1. Edit `guestbook-ui-configmap.yaml` — change the background color or description text.
2. Commit and push the change.
3. Run `argocd app sync guestbook` (or enable auto-sync).
4. Refresh the browser to see the updated page.
