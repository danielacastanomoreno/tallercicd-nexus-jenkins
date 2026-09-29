# ===============
# STAGE 1: BUILD
# ===============
FROM maven:3.9.6-eclipse-temurin-17-alpine AS builder

WORKDIR /app

# Copiar primero el archivo de dependencias
COPY pom.xml .

# Descargar dependencias para aprovechar la cache de Docker
RUN mvn dependency:go-offline

# Copiar el código fuente
COPY src ./src

# Compilar y generar el JAR
RUN mvn package -DskipTests


# ===============
# STAGE 2: RUNTIME
# ===============
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Crear usuario no root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copiar únicamente el JAR generado
COPY --from=builder /app/target/*.jar app.jar

# El contenedor escuchará en el puerto 8080
EXPOSE 8080

# Ejecutar como usuario no root
USER appuser

# Iniciar la aplicación
ENTRYPOINT ["java", "-jar", "app.jar"]