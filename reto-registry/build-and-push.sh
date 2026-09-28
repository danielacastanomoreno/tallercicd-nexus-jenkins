#!/usr/bin/env bash
# ==============================================================================
# build-and-push.sh  (RETO)  -  Empaqueta en imagenes OCI los artefactos YA
# publicados en Nexus y las sube al Docker Registry (docker-hosted, puerto 8082).
#
# Uso:  REGISTRY=<IP-PUBLICA-NEXUS>:8082 reto-registry/build-and-push.sh 1.0.0
# Requiere: haber ejecutado antes  deploy/fetch-release.sh 1.0.0  (directorio release/1.0.0)
#           NEXUS_USER / NEXUS_PASS (ci-publisher).
# Opcional: BASE_JRE / BASE_NGINX para tomar las imagenes base desde docker-group (puerto 8083).
# ==============================================================================
set -euo pipefail

VERSION="${1:?Uso: $0 <version>}"
: "${REGISTRY:?Defina REGISTRY, p. ej. 3.90.10.20:8082}" "${NEXUS_USER:?}" "${NEXUS_PASS:?}"
CTX="release/$VERSION"

[ -f "$CTX/SHA256SUMS" ] || { echo "ERROR: ejecute primero deploy/fetch-release.sh $VERSION"; exit 1; }
check() { if command -v sha256sum >/dev/null 2>&1; then sha256sum -c "$@"; else shasum -a 256 -c "$@"; fi; }
( cd "$CTX" && check SHA256SUMS )

API="$REGISTRY/ingesoft/product-api:$VERSION"
WEB="$REGISTRY/ingesoft/product-web:$VERSION"

echo "$NEXUS_PASS" | docker login "$REGISTRY" -u "$NEXUS_USER" --password-stdin

docker build -f reto-registry/backend.runtime.Dockerfile \
  --build-arg JAR_FILE="product-api-$VERSION.jar" --build-arg APP_VERSION="$VERSION" \
  ${BASE_JRE:+--build-arg BASE_IMAGE="$BASE_JRE"} -t "$API" "$CTX"

docker build -f reto-registry/frontend.runtime.Dockerfile \
  --build-arg APP_VERSION="$VERSION" \
  ${BASE_NGINX:+--build-arg BASE_IMAGE="$BASE_NGINX"} -t "$WEB" "$CTX"

docker push "$API"
docker push "$WEB"

echo ">> Digests publicados (identidad inmutable de cada imagen):"
docker inspect --format '{{index .RepoDigests 0}}' "$API" "$WEB"
