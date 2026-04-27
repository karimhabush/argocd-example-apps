# App of Apps Pattern

## Concept

This example demonstrates the **"App of Apps" pattern** -- a single ArgoCD Application that bootstraps and manages all other applications. Instead of creating each ArgoCD Application individually, you define a parent Application backed by a Helm chart that templates ArgoCD `Application` custom resources. When ArgoCD syncs the parent, it creates all the child Applications automatically.

This pattern is commonly used in production for managing multiple microservices, environments, or tenant configurations from a single source of truth.

## How It Works

The directory is structured as a Helm chart:

```
apps/
  Chart.yaml              # Helm chart metadata (name: "applications", version: 0.1.0)
  values.yaml             # List of applications and shared configuration
  templates/
    applications.yaml     # Template that generates ArgoCD Application CRDs
```

1. **`values.yaml`** defines shared configuration (destination server, source repo, target revision) and a list of applications. Each entry specifies a name and optionally a path, namespace, and tool-specific settings (Helm release name, plugin name, etc.).

2. **`templates/applications.yaml`** iterates over the applications list and generates one ArgoCD `Application` resource per entry. Each generated Application:
   - Points to a subdirectory in this repository (defaulting to the app name if no explicit path is given)
   - Targets the configured destination cluster
   - Has automated sync with pruning and self-heal enabled
   - Creates its namespace automatically via `CreateNamespace=true`

3. When ArgoCD syncs the parent app, it renders the Helm chart and applies the resulting `Application` resources to the cluster. ArgoCD then picks up each child Application and syncs them independently.

## Applications Included

The default `values.yaml` bootstraps the following applications:

| Application | Path | Tool |
|-------------|------|------|
| blue-green | `blue-green/` | Helm |
| guestbook | `guestbook/` | Auto-detected |
| helm-dependency | `helm-dependency/` | Helm |
| helm-guestbook | `helm-guestbook/` | Helm |
| helm-hooks | `helm-hooks/` | Auto-detected |
| jsonnet-guestbook | `jsonnet-guestbook/` | Auto-detected |
| jsonnet-guestbook-tla | `jsonnet-guestbook-tla/` | Auto-detected |
| kustomize-guestbook | `kustomize-guestbook/` | Auto-detected |
| plugin-kasane | `plugins/kasane/` | Plugin (kasane) |
| plugin-kustomized-helm | `plugins/kustomized-helm/` | Plugin (kustomized-helm) |
| plugin-nix | `plugins/nix/` | Plugin (nix) |
| pre-post-sync | `pre-post-sync/` | Auto-detected |
| sock-shop | `sock-shop/` | Auto-detected |
| sync-waves | `sync-waves/` | Auto-detected |

## How to Deploy

```bash
argocd app create apps \
  --repo https://github.com/argoproj/argocd-example-apps.git \
  --path apps \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace argocd \
  --sync-policy automated \
  --self-heal
```

Once synced, the parent app will create all 14 child Applications in the `argocd` namespace.

## What to Observe in ArgoCD

- **Parent-child relationship**: The ArgoCD UI shows the parent "apps" Application and all the child Applications it created. You can see how one app spawns all others.
- **Cascading sync**: When you sync the parent, it ensures all child Application resources exist and are up to date. Each child then syncs its own resources independently.
- **Automated reconciliation**: Because the template enables `automated` sync with `selfHeal` and `prune`, any manual changes to child Application definitions will be reverted automatically.

## How to Customize

To add or remove applications, edit the `applications` list in `values.yaml`:

```yaml
applications:
  - name: my-new-app          # Required: application name
    path: path/to/manifests   # Optional: defaults to the app name
    namespace: custom-ns      # Optional: defaults to the app name
    tool:                      # Optional: tool-specific config
      helm:
        releaseName: my-release
```

To change the target repository or cluster, update the `config` section in `values.yaml`.

## Warning

Deploying this app will create and sync **all** demo applications in the repository. This includes resource-heavy apps like Sock Shop and apps that require plugin configuration. Make sure your cluster has enough resources and that any required Config Management Plugins are configured before deploying.
