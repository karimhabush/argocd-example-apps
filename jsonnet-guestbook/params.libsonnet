{
  containerPort: 80,
  image: "nginx:1.27-alpine",
  name: "jsonnet-guestbook-ui",
  replicas: 1,
  servicePort: 80,
  type: "ClusterIP",
  color: "#2ecc71",
  title: "Jsonnet Guestbook",
  subtitle: "Jsonnet + Parameter Library",
  description: "This app is deployed using Jsonnet with an imported parameter library. Jsonnet generates Kubernetes manifests programmatically.",
}
