# Sync Waves Demo

This example demonstrates **ArgoCD sync waves** and **sync hooks** -- the
native ArgoCD mechanism for controlling the order in which resources are created
during a sync operation.

## Concept

### Sync waves

Every resource can carry the annotation
`argocd.argoproj.io/sync-wave: "N"` where **N** is an integer. During a sync,
ArgoCD processes resources wave by wave, starting from the lowest number.
Resources in the same wave are applied together; ArgoCD waits for them to
become healthy before moving to the next wave.

- If no annotation is present, the resource defaults to **wave 0**.
- Negative wave numbers are valid and run before wave 0.

### Sync hooks

Sync hooks are resources annotated with `argocd.argoproj.io/hook`. They run at
specific phases of the sync:

| Hook phase | When it runs |
|---|---|
| `PreSync` | Before any wave is applied |
| `Sync` | During normal wave processing (respects sync-wave annotation) |
| `PostSync` | After all waves have been applied successfully |
| `SyncFail` | If the sync fails at any point |
| `Skip` | Resource is never applied |

Hooks can also carry a `sync-wave` annotation to control ordering among
resources in the same phase.

### Hook delete policies

The annotation `argocd.argoproj.io/hook-delete-policy` determines when hook
resources are cleaned up:

| Policy | Behavior |
|---|---|
| `HookSucceeded` | Delete the resource after it succeeds |
| `HookFailed` | Delete the resource after it fails |
| `BeforeHookCreation` | Delete any previous instance before creating a new one |

## Execution order

```
PreSync:  schema-migrate         (before all waves)
Wave 0:   Backend Deployment + Service
Wave 1:   warmup-cache           (Sync hook)
Wave 2:   Frontend Deployment + Service
PostSync: post-deploy-cleanup    (after all waves)
```

ArgoCD waits for each wave's resources to be healthy before proceeding to the
next wave. This guarantees that the backend is fully running before the cache
warmup job starts, and the cache is warm before the frontend is deployed.

## Deploying with ArgoCD

```bash
argocd app create sync-waves \
  --repo https://github.com/<your-org>/argocd-example-apps.git \
  --path sync-waves \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default
```

Then sync:

```bash
argocd app sync sync-waves
```

## What to observe in the ArgoCD UI

- Open the application and click **Sync**. Watch resources appear in wave
  order -- the backend comes up first, then the cache warmup job runs, and
  finally the frontend deploys.
- Hook Jobs (PreSync, Sync, PostSync) are displayed with a hook icon in the
  resource tree.
- After a successful sync, hooks with `HookSucceeded` delete policy are
  automatically removed.

## Use cases

Sync waves are useful whenever resources have ordering dependencies:

- **Databases before applications** -- deploy a database in wave 0, the app
  that depends on it in wave 1.
- **Migrations before deployments** -- run a schema migration as a PreSync
  hook, then deploy the new code.
- **Config before workloads** -- create ConfigMaps and Secrets in an early
  wave, reference them in Deployments in a later wave.
- **Health checks between tiers** -- ensure a backend is healthy before
  starting a frontend that calls it.
