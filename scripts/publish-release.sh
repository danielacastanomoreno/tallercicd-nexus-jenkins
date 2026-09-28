#!/usr/bin/env bash
# ==============================================================================
# publish-release.sh  -  "Build Once": construye y publica UN release en Nexus
#   * Backend  -> maven-releases  (mvn deploy: JAR + POM + checksums)
#   * Frontend -> raw-releases    (bundle .tgz reproducible)
#   * nginx.conf + SHA256SUMS -> raw-releases  (manifiesto de integridad)
#
# Uso:  scripts/publish-release.sh 1.0.0
# Requiere: NEXUS_URL, NEXUS_USER, NEXUS_PASS (ver scripts/env.sh.example),
#           ~/.m2/settings.xml del taller, y backend/pom.xml con la MISMA version.
# ==============================================================================
set -euo pipefail

VERSION="${1:?Uso: $0 <version-semver>   (p. ej. 1.0.0)}"
: "${NEXUS_URL:?Defina NEXUS_URL}"  "${NEXUS_USER:?Defina NEXUS_USER}"  "${NEXUS_PASS:?Defina NEXUS_PASS}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STAGE="$ROOT/build-release/$VERSION"

# --- utilidades portables (Linux / macOS / Git Bash) --------------------------
TAR=tar; command -v gtar >/dev/null 2>&1 && TAR=gtar
case "$("$TAR" --version 2>&1 || true)" in
  *"GNU tar"*) ;;
  *) echo "ERROR: se requiere GNU tar (macOS: brew install gnu-tar)"; exit 1 ;;
esac
sha256() { if command -v sha256sum >/dev/null 2>&1; then sha256sum "$@"; else shasum -a 256 "$@"; fi; }

# --- 0. Reglas de versionamiento ----------------------------------------------
case "$VERSION" in
  *-SNAPSHOT) echo "ERROR: un SNAPSHOT no es un release inmutable."; exit 1 ;;
esac
POM_VERSION="$(mvn -B -q -f "$ROOT/backend/pom.xml" help:evaluate -Dexpression=project.version -DforceStdout)"
[ "$POM_VERSION" = "$VERSION" ] || { echo "ERROR: backend/pom.xml declara $POM_VERSION, no $VERSION"; exit 1; }

rm -rf "$STAGE"; mkdir -p "$STAGE"

# --- 1. Backend: pruebas + empaquetado + publicacion en Maven hosted ----------
echo ">> [1/4] Backend: mvn clean deploy (ejecuta las pruebas unitarias)"
mvn -B -f "$ROOT/backend/pom.xml" clean deploy -Dnexus.url="$NEXUS_URL"
cp "$ROOT/backend/target/product-api-$VERSION.jar" "$STAGE/"

# --- 2. Frontend: build determinista (una sola vez, API relativa /api) --------
echo ">> [2/4] Frontend: npm ci + lint + build"
( cd "$ROOT/frontend" && npm ci && npm run lint && VITE_API_URL=/api npm run build )
"$TAR" --sort=name --mtime='UTC 2026-01-01' --owner=0 --group=0 --numeric-owner \
  -cf - -C "$ROOT/frontend/dist" . | gzip -n > "$STAGE/product-frontend-$VERSION.tgz"
cp "$ROOT/frontend/nginx.conf" "$STAGE/nginx.conf"

# --- 3. Manifiesto de integridad ----------------------------------------------
echo ">> [3/4] Manifiesto SHA256SUMS"
( cd "$STAGE" && sha256 "product-api-$VERSION.jar" "product-frontend-$VERSION.tgz" nginx.conf > SHA256SUMS && cat SHA256SUMS )

# --- 4. Publicacion en Raw hosted ---------------------------------------------
echo ">> [4/4] Publicando en raw-releases/product/$VERSION/"
BASE="$NEXUS_URL/repository/raw-releases/product/$VERSION"
for f in "product-frontend-$VERSION.tgz" nginx.conf SHA256SUMS; do
  curl --fail-with-body -sS -u "$NEXUS_USER:$NEXUS_PASS" --upload-file "$STAGE/$f" "$BASE/$f"
  echo "   subido: $BASE/$f"
done
echo ">> Release $VERSION publicado."
