# Jsonnet Guestbook (Top-Level Arguments)

## Concept

This example demonstrates **Jsonnet Top-Level Arguments (TLAs)** -- function parameters that are passed at evaluation time rather than imported from a library file.

The entire `guestbook-ui.jsonnet` file is a Jsonnet function. When ArgoCD evaluates it, it supplies argument values defined in the Application spec. This makes a single Jsonnet file reusable across multiple environments or applications without any file changes.

## Difference from jsonnet-guestbook

| | jsonnet-guestbook | jsonnet-guestbook-tla |
|---|---|---|
| Parameter source | Imported from `params.libsonnet` | Passed as function arguments at render time |
| Customization | Edit the `.libsonnet` file and commit | Override values in the ArgoCD Application spec |
| Reusability | Tied to one parameter file per repo path | Same file, different args per environment |

## How ArgoCD Passes TLAs

ArgoCD passes TLAs through the Application spec under `spec.source.directory.jsonnet.tlas`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: jsonnet-tla
spec:
  source:
    repoURL: <repo>
    path: jsonnet-guestbook-tla
    directory:
      jsonnet:
        tlas:
          - name: name
            value: "my-custom-app"
          - name: color
            value: "#e74c3c"
          - name: title
            value: "Production App"
          - name: replicas
            value: "3"
  destination:
    server: https://kubernetes.default.svc
    namespace: jsonnet-tla
```

## Deploy with ArgoCD

```bash
argocd app create jsonnet-tla \
  --repo <repo> \
  --path jsonnet-guestbook-tla \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace jsonnet-tla
```

To override TLAs from the CLI:

```bash
argocd app set jsonnet-tla --jsonnet-tla-str name=my-app --jsonnet-tla-str color="#e74c3c"
```

You can also configure TLAs directly in the ArgoCD UI under the application's "Parameters" tab.

## What to Observe

The same Jsonnet file produces different Kubernetes manifests depending on the TLA values provided. Change a TLA in the Application spec (or via the UI) and ArgoCD will re-render the manifests and show the diff before syncing.

## When to Use TLAs

Use top-level arguments when you want **one Jsonnet file reusable across multiple environments or applications**. Instead of maintaining separate parameter files or branches, each ArgoCD Application simply passes its own set of argument values. This is especially useful in multi-tenant or multi-environment setups.
