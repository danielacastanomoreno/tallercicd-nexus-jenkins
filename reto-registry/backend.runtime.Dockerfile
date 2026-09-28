# ==============================================================================
# Imagen de RUNTIME del backend: empaqueta el JAR YA PUBLICADO en Nexus.
# No compila nada: el contexto de build es release/<version>/ (artefactos verificados).
#   docker build -f reto-registry/backend.runtime.Dockerfile \
#     --build-arg JAR_FILE=product-api-1.0.0.jar --build-arg APP_VERSION=1.0.0 \
#     -t <registro>/ingesoft/product-api:1.0.0 release/1.0.0
# ==============================================================================
ARG BASE_IMAGE=eclipse-temurin:17-jre-alpine
FROM ${BASE_IMAGE}

ARG JAR_FILE
ARG APP_VERSION=unknown
LABEL org.opencontainers.image.title="product-api" \
      org.opencontainers.image.version="${APP_VERSION}"

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
COPY ${JAR_FILE} app.jar

USER appuser
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
