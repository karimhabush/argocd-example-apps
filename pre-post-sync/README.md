# Pre/Post Sync — ArgoCD Sync Hooks Demo

## What This Showcases

This app demonstrates ArgoCD sync hooks — lifecycle hooks that run Jobs before and after the main resource sync. These are ArgoCD-specific annotations, not Helm hooks.

### Execution Order

1. **PreSync** — The `pre-sync-db-migrate` Job runs first (simulates a database migration)
2. **Sync** — The main resources (Deployment, Service, ConfigMap) are applied
3. **PostSync** — The `post-sync-notify` Job runs last (simulates a deployment notification)

## Difference from Helm Hooks

Helm hooks are defined via `helm.sh/hook` annotations and are managed by Helm's lifecycle. ArgoCD sync hooks use `argocd.argoproj.io/hook` annotations and are managed by ArgoCD's sync engine. ArgoCD hooks work with any manifest source (plain YAML, Kustomize, Helm, etc.), not just Helm charts.

## Files

- `kustomization.yaml` — Kustomize configuration with `pre-post-sync-` namePrefix
- `deployment.yaml` — Deployment running nginx with ConfigMap-mounted HTML
- `configmap.yaml` — ConfigMap containing the HTML status page
- `service.yaml` — Service exposing the deployment on port 80
- `pre-sync-job.yaml` — Job with `argocd.argoproj.io/hook: PreSync` annotation
- `post-sync-job.yaml` — Job with `argocd.argoproj.io/hook: PostSync` annotation

## How to Use

### Create the ArgoCD Application

```bash
argocd app create pre-post-sync \
  --repo <repo-url> \
  --path pre-post-sync \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace pre-post-sync
```

### Sync the Application

```bash
argocd app sync pre-post-sync
```

### Verify the Deployment

```bash
kubectl port-forward svc/pre-post-sync-app -n pre-post-sync 8080:80
```

Then open http://localhost:8080 in your browser. You should see a gold status page titled "Pre/Post Sync".

## What to Observe in the ArgoCD UI

- When you sync, the PreSync job appears first and runs to completion.
- Once the PreSync job succeeds, the main resources (Deployment, Service, ConfigMap) are synced.
- After all main resources are healthy, the PostSync job runs.
- Both hook jobs are automatically deleted after they succeed, thanks to the `HookSucceeded` delete policy.

## Hook Delete Policies

The `argocd.argoproj.io/hook-delete-policy` annotation controls when hook resources are cleaned up:

- **HookSucceeded** — Delete the resource after it has succeeded (used in this demo)
- **HookFailed** — Delete the resource after it has failed
- **BeforeHookCreation** — Delete the existing resource before a new one is created (on re-sync)

## How to Test

1. Run `argocd app sync pre-post-sync` and watch the ArgoCD UI.
2. Observe the jobs appearing in order: PreSync, then main sync, then PostSync.
3. After sync completes, verify that the hook jobs have been cleaned up (`kubectl get jobs -n pre-post-sync` should show no jobs).
4. Modify the sleep durations or add additional hook jobs to experiment.
