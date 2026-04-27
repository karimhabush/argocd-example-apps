# Config Management Plugins Examples

## Concept

ArgoCD natively supports Helm, Kustomize, Jsonnet, and plain YAML for defining Kubernetes manifests. However, many teams use additional or alternative tools for configuration management. ArgoCD's **Config Management Plugins (CMPs)** allow you to extend ArgoCD with any tool that can produce Kubernetes manifests, giving you full flexibility over your deployment pipeline.

This directory contains three plugin examples that demonstrate how to integrate custom config management tools with ArgoCD.

## Available Plugins

| Plugin | Tool | Description |
|--------|------|-------------|
| [kasane/](kasane/) | [Kasane](https://github.com/google/kasane) | Uses Google's Kasane for Jsonnet-based patching layers. Kasane lets you compose Kubernetes manifests by layering Jsonnet patches on top of base YAML, providing a flexible overlay system. |
| [kustomized-helm/](kustomized-helm/) | Helm + Kustomize | Combines Helm templating with Kustomize post-processing. First renders a Helm chart, then applies Kustomize transformations on the output -- useful when you need Kustomize-style patches on top of a Helm release. |
| [nix/](nix/) | [Nix](https://nixos.org/) | Uses the Nix package manager for fully declarative, reproducible configuration. Builds and customizes a Helm chart using Nix expressions, ensuring hermetic and repeatable manifest generation. |

## Prerequisites

Config Management Plugins require additional setup on the **argocd-repo-server**. Depending on the plugin, you will need to:

1. **Install custom binaries** (e.g., `kasane`, `nix`) into the repo-server container or a sidecar.
2. **Register the plugin** by configuring a CMP sidecar container with the appropriate discovery and generate commands.
3. **Provide any required dependencies** (e.g., Python packages for Kasane, Nix store for Nix).

Each subdirectory contains its own README with specific setup instructions for that plugin.

Refer to the [ArgoCD CMP documentation](https://argo-cd.readthedocs.io/en/stable/operator-manual/config-management-plugins/) for full details on configuring plugins.

## When to Use Plugins

Consider using a Config Management Plugin when:

- Your team already uses a config management tool that ArgoCD does not support natively.
- You need to combine multiple tools in a pipeline (e.g., Helm + Kustomize).
- You require fully reproducible builds with tools like Nix.
- You want to add custom preprocessing or postprocessing steps to your manifest generation.
