#!/usr/bin/env bash
# ==============================================================================
# fetch-release.sh  -  "Deploy to Many": descarga UN release desde Nexus y
# VERIFICA su integridad (SHA-256) antes de que cualquier servicio lo use.
# El host destino NUNCA clona Git ni compila.
#
# Uso:  ./fetch-release.sh 1.0.0 [directorio_destino]     (por defecto release/<version>)
# Requiere: NEXUS_URL, NEXUS_USER, NEXUS_PASS  (en ec2-deploy: usuario deploy-reader
#           y NEXUS_URL con la IP PRIVADA de ec2-nexus)
# ==============================================================================
set -euo pipefail

VERSION="${1:?Uso: $0 <version> [directorio_destino]}"
DEST="${2:-release/$VERSION}"
: "${NEXUS_URL:?Defina NEXUS_URL}"  "${NEXUS_USER:?Defina NEXUS_USER}"  "${NEXUS_PASS:?Defina NEXUS_PASS}"

GAV_PATH="com/icesi/ingesoftv/product-api"     # groupId (como ruta) + artifactId
JAR="product-api-$VERSION.jar"
TGZ="product-frontend-$VERSION.tgz"
RAW="$NEXUS_URL/repository/raw-releases/product/$VERSION"

check() { if command -v sha256sum >/dev/null 2>&1; then sha256sum -c "$@"; else shasum -a 256 -c "$@"; fi; }
get()   { curl --fail-with-body -sS -u "$NEXUS_USER:$NEXUS_PASS" -o "$2" "$1" && echo "   descargado: $2"; }

mkdir -p "$DEST"
cd "$DEST"

echo ">> Descargando release $VERSION desde $NEXUS_URL"
get "$NEXUS_URL/repository/maven-releases/$GAV_PATH/$VERSION/$JAR" "$JAR"
get "$RAW/$TGZ"        "$TGZ"
get "$RAW/nginx.conf"  nginx.conf
get "$RAW/SHA256SUMS"  SHA256SUMS

echo ">> Verificando integridad (SHA-256)"
check SHA256SUMS

rm -rf web && mkdir web
tar -xzf "$TGZ" -C web
echo ">> Release $VERSION verificado y listo en: $(pwd)"
