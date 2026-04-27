function(
  name="jsonnet-guestbook-tla-ui",
  image="nginx:1.27-alpine",
  replicas=1,
  containerPort=80,
  servicePort=80,
  type="ClusterIP",
  color="#27ae60",
  title="Jsonnet TLA",
)
[
  {
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
      name: name,
    },
    data: {
      "index.html": |||
        <!DOCTYPE html>
        <html>
        <head>
          <title>%(title)s</title>
          <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body {
              font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
              background: %(color)s;
              color: #fff;
              display: flex;
              justify-content: center;
              align-items: center;
              min-height: 100vh;
            }
            .card {
              background: rgba(255,255,255,0.15);
              backdrop-filter: blur(10px);
              border-radius: 16px;
              padding: 40px;
              max-width: 520px;
              width: 90%%;
              text-align: center;
            }
            h1 { font-size: 2rem; margin-bottom: 8px; }
            .badge {
              display: inline-block;
              background: rgba(255,255,255,0.25);
              padding: 4px 16px;
              border-radius: 20px;
              font-size: 0.9rem;
              margin-bottom: 24px;
            }
            p { font-size: 1rem; line-height: 1.6; opacity: 0.9; }
          </style>
        </head>
        <body>
          <div class="card">
            <h1>%(title)s</h1>
            <span class="badge">Top-Level Arguments</span>
            <p>This app uses Jsonnet top-level arguments (TLAs). Parameters are passed at render time via ArgoCD, not imported from a file. This allows the same Jsonnet to be reused across environments.</p>
          </div>
        </body>
        </html>
      ||| % { title: title, color: color },
    },
  },
  {
    apiVersion: "v1",
    kind: "Service",
    metadata: {
      name: name,
    },
    spec: {
      type: type,
      ports: [{
        port: servicePort,
        targetPort: containerPort,
      }],
      selector: {
        app: name,
      },
    },
  },
  {
    apiVersion: "apps/v1",
    kind: "Deployment",
    metadata: {
      name: name,
    },
    spec: {
      replicas: replicas,
      selector: {
        matchLabels: {
          app: name,
        },
      },
      template: {
        metadata: {
          labels: {
            app: name,
          },
        },
        spec: {
          containers: [{
            name: name,
            image: image,
            ports: [{
              containerPort: containerPort,
            }],
            volumeMounts: [{
              name: "html",
              mountPath: "/usr/share/nginx/html",
            }],
            readinessProbe: {
              httpGet: {
                path: "/",
                port: containerPort,
              },
            },
          }],
          volumes: [{
            name: "html",
            configMap: {
              name: name,
            },
          }],
        },
      },
    },
  },
]
