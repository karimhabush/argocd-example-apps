# Sock Shop - Microservices Demo with ArgoCD

## Concept

This example demonstrates managing a real-world microservices application with ArgoCD. The [Weaveworks Sock Shop](https://microservices-demo.github.io/) is a full e-commerce platform composed of many independently deployed services, making it an excellent showcase for ArgoCD's ability to manage complex, multi-service deployments.

## What It Deploys

The Sock Shop deploys a complete e-commerce platform with the following services:

| Service | Description |
|---------|-------------|
| **front-end** | Web UI for the shop |
| **carts** | Shopping cart service |
| **catalogue** | Product catalogue service |
| **orders** | Order processing service |
| **payment** | Payment processing service |
| **shipping** | Shipping service |
| **user** | User account service |
| **queue-master** | Order queue consumer |
| **carts-db** | MongoDB for carts |
| **catalogue-db** | MySQL for catalogue |
| **orders-db** | MongoDB for orders |
| **user-db** | MongoDB for users |
| **session-db** | Redis for session data |
| **rabbitmq** | Message queue for order processing |

In total, the `kustomization.yaml` references 29 Kubernetes resources (Deployments, Services, and an Ingress), resulting in 30+ managed objects once deployed.

## Configuration

This example uses **Kustomize** for resource management. The `kustomization.yaml` at the root of this directory lists all resources from the `base/` folder. No overlays or patches are applied by default -- it serves as a straightforward aggregation of all the manifests.

## How to Deploy

```bash
argocd app create sock-shop \
  --repo https://github.com/argoproj/argocd-example-apps.git \
  --path sock-shop \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace sock-shop
```

Then sync the application:

```bash
argocd app sync sock-shop
```

## Accessing the Shop UI

Once deployed, port-forward the front-end service to access the shop in your browser:

```bash
kubectl port-forward -n sock-shop svc/front-end 8080:80
```

Then open [http://localhost:8080](http://localhost:8080) in your browser.

## What to Observe in ArgoCD

- **Resource tree view**: ArgoCD displays all 30+ resources in a dependency tree, giving a clear picture of the entire microservices architecture at a glance.
- **Health aggregation**: Each service reports its own health status (Healthy, Progressing, Degraded), and ArgoCD aggregates these into an overall application health.
- **Multi-service drift detection**: If any single resource drifts from its desired state, ArgoCD detects and reports it, making it easy to identify which service has diverged.

## Resource Requirements

This is a heavy application. The Sock Shop deploys many services with their backing databases, so it requires a cluster with decent resources. A minimum of 4 GB of memory and 2 CPUs is recommended for the cluster nodes. Running this on a minimal local cluster (e.g., Minikube with default settings) may result in pods being evicted or stuck in Pending state.

## Good For Demoing

- ArgoCD's **resource tree view** for visualizing complex microservices architectures
- **Health aggregation** across many interdependent services
- **Multi-service drift detection** and reconciliation
- How ArgoCD handles a realistic, production-style workload with databases, message queues, and multiple application tiers
