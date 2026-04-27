# Jsonnet Guestbook (Parameter Library)

## Concept

Jsonnet is a data templating language that generates JSON (and by extension YAML). It provides variables, conditionals, loops, functions, and imports, making it far more powerful than plain YAML for producing Kubernetes manifests.

This example demonstrates **Jsonnet with an imported parameter library**. Configuration values live in `params.libsonnet`, and the main template `guestbook-ui.jsonnet` imports them to generate three Kubernetes resources: a ConfigMap (serving an HTML page), a Service, and a Deployment.

## How It Works

- `params.libsonnet` holds all configurable values (image, replicas, colors, text, ports).
- `guestbook-ui.jsonnet` imports the parameter file and uses those values to produce a JSON array of Kubernetes manifests.
- ArgoCD has **native Jsonnet support** -- it evaluates `.jsonnet` files automatically and applies the resulting manifests to the cluster.

## Deploy with ArgoCD

```bash
argocd app create jsonnet-guestbook \
  --repo <repo> \
  --path jsonnet-guestbook \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace jsonnet-guestbook
```

## Customization

Edit `params.libsonnet` to change any parameter:

- `color` -- background color of the landing page
- `title` / `subtitle` / `description` -- text shown on the page
- `replicas` -- number of pod replicas
- `image` -- container image to use
- `type` -- Kubernetes Service type (`ClusterIP`, `NodePort`, `LoadBalancer`)

After editing, commit and push. ArgoCD will detect the change, re-evaluate the Jsonnet, and sync the new manifests.

## What to Observe

When ArgoCD syncs this application it evaluates the Jsonnet files and renders standard Kubernetes manifests (ConfigMap, Service, Deployment). You can inspect the rendered output in the ArgoCD UI under the application's "Desired Manifest" tab.

## When to Use Jsonnet

Jsonnet is a good fit when you need **programmatic manifest generation** -- loops to create many similar resources, conditionals for environment-specific configuration, functions for reusable patterns, or imports to share parameters across files.
