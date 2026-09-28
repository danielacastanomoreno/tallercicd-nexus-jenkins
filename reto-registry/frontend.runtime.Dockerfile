# ==============================================================================
# Imagen de RUNTIME del frontend: Nginx + bundle web YA PUBLICADO en Nexus.
# El contexto de build es release/<version>/ (contiene web/ y nginx.conf verificados).
#   docker build -f reto-registry/frontend.runtime.Dockerfile --build-arg APP_VERSION=1.0.0 \
#     -t <registro>/ingesoft/product-web:1.0.0 release/1.0.0
# ==============================================================================
ARG BASE_IMAGE=nginx:1.27-alpine
FROM ${BASE_IMAGE}

ARG APP_VERSION=unknown
LABEL org.opencontainers.image.title="product-web" \
      org.opencontainers.image.version="${APP_VERSION}"

COPY web/ /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
