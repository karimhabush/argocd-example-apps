local params = import 'params.libsonnet';

[
  {
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
      name: params.name,
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
            <span class="badge">%(subtitle)s</span>
            <p>%(description)s</p>
          </div>
        </body>
        </html>
      ||| % { title: params.title, subtitle: params.subtitle, description: params.description, color: params.color },
    },
  },
  {
    apiVersion: "v1",
    kind: "Service",
    metadata: {
      name: params.name,
    },
    spec: {
      type: params.type,
      ports: [{
        port: params.servicePort,
        targetPort: params.containerPort,
      }],
      selector: {
        app: params.name,
      },
    },
  },
  {
    apiVersion: "apps/v1",
    kind: "Deployment",
    metadata: {
      name: params.name,
    },
    spec: {
      replicas: params.replicas,
      selector: {
        matchLabels: {
          app: params.name,
        },
      },
      template: {
        metadata: {
          labels: {
            app: params.name,
          },
        },
        spec: {
          containers: [{
            name: params.name,
            image: params.image,
            ports: [{
              containerPort: params.containerPort,
            }],
            volumeMounts: [{
              name: "html",
              mountPath: "/usr/share/nginx/html",
            }],
            readinessProbe: {
              httpGet: {
                path: "/",
                port: params.containerPort,
              },
            },
          }],
          volumes: [{
            name: "html",
            configMap: {
              name: params.name,
            },
          }],
        },
      },
    },
  },
]
