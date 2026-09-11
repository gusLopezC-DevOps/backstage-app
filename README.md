# backstage-app

Contexto de construcción de la imagen de Backstage (frontend + backend) del
laboratorio. La imagen resultante se publica en Docker Hub como
`docker.io/guslopezc/backstage`.

## Contenido

- `packages/` — app (frontend React) y backend (bundle con la SPA embebida).
- `catalog/entities/` — `users.yaml` y `groups.yaml` que la imagen hornea en
  `/app/entities` (el catálogo los referencia desde `override.yaml`).
- `app-config*.yaml` — configuración base y de producción (entidades, k8s,
  techdocs local, integrations de GitHub).
- `Dockerfile` — multi-stage `node:22-bookworm-slim` con python3 +
  `mkdocs-techdocs-core` para el builder de TechDocs local.

No se hornea ningún template de scaffolder: las plantillas y la action custom
(`gitops:push-to-repo`) las inyecta el ConfigMap `backstage-templates` en
runtime (montado en `/app/templates` y `/app/plugins`).

## CI

`.github/workflows/build-push.yaml` construye y publica la imagen en cada push
a `main` (y manual). requiere los secrets `DOCKERHUB_USERNAME` y
`DOCKERHUB_TOKEN` en GitHub.

## Build local

```bash
docker build -t guslopezc/backstage:v13 .
docker push guslopezc/backstage:v13
```

Versiones ancladas: `backstage.json` = 1.53.0, `react`/`react-dom` = 18.3.1
exactos, lockfile `yarn.lock` versionado.