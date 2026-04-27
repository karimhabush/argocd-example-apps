# Helm Hooks Demo

This example demonstrates **Helm lifecycle hooks** -- a mechanism for running
Jobs (or other resources) at specific points during an install or upgrade.

## Concept

Helm hooks let you intervene in the release lifecycle. A resource annotated with
`helm.sh/hook` is not deployed with the main release; instead Helm executes it
at the phase indicated by the annotation value.

### Hook types used here

| Annotation value | When it runs |
|---|---|
| `pre-install` / `pre-upgrade` | Before any main release resources are created/updated |
| `post-install` / `post-upgrade` | After all main release resources are created/updated |

Other hook types exist (`pre-delete`, `post-delete`, `pre-rollback`,
`post-rollback`, `test`) but are not shown in this demo.

### Hook weights

When multiple hooks target the same phase, **hook weight** determines execution
order. Weights are integers given via `helm.sh/hook-weight`. Lower numbers run
first.

- `db-migrate` has weight **-2** -- runs first
- `maint-page-up` has weight **-1** -- runs second

### Hook delete policies

The annotation `helm.sh/hook-delete-policy` controls when the hook resource is
cleaned up:

| Policy | Behavior |
|---|---|
| `before-hook-creation` | Delete any previous instance of this hook before creating a new one |
| `hook-succeeded` | Delete the hook after it succeeds |
| `hook-failed` | Delete the hook after it fails |

This demo uses `before-hook-creation` so that repeated syncs do not leave
stale Job resources behind.

## Execution order

```
1. db-migrate        (pre-install, weight -2)
2. maint-page-up     (pre-install, weight -1)
3. Main resources    (Deployment, Service, ConfigMap)
4. maint-page-down   (post-install)
```

## Deploying with ArgoCD

```bash
argocd app create helm-hooks \
  --repo https://github.com/<your-org>/argocd-example-apps.git \
  --path helm-hooks \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default
```

Then sync:

```bash
argocd app sync helm-hooks
```

## What to observe in the ArgoCD UI

- Hook Jobs appear as **separate resources** in the application tree.
- During a sync, watch the hooks execute in weight order before the main
  Deployment becomes healthy.
- The post-install hook fires after the Deployment reports ready.

## Helm hooks vs ArgoCD sync hooks

These two mechanisms are independent:

| Feature | Helm hooks | ArgoCD sync hooks |
|---|---|---|
| Annotation | `helm.sh/hook` | `argocd.argoproj.io/hook` |
| Phases | pre-install, post-install, pre-upgrade, post-upgrade, etc. | PreSync, Sync, PostSync, SyncFail, Skip |
| Ordering | `helm.sh/hook-weight` (integer) | `argocd.argoproj.io/sync-wave` (integer) |
| Cleanup | `helm.sh/hook-delete-policy` | `argocd.argoproj.io/hook-delete-policy` |

If you deploy a Helm chart through ArgoCD, both annotation families are
recognized. For plain-manifest directories (like this one), only ArgoCD sync
hooks apply -- the `helm.sh/hook` annotations shown here are for demonstration
purposes and would take effect when the manifests are rendered through a Helm
chart.
