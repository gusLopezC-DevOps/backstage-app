#!/usr/bin/env bash
set -euo pipefail

IMAGE="docker.io/guslopezc/backstage:v3"

echo "=== podman build ==="
echo "--- using --network=host to avoid bridge network timeouts ---"
podman build --network=host . -t "$IMAGE"

echo "=== podman push ==="
podman push "$IMAGE"

echo "=== kubectl rollout ==="
kubectl set image deployment/backstage -n backstage backstage="$IMAGE"
kubectl rollout status deployment/backstage -n backstage --timeout=180s

echo "=== done ==="
