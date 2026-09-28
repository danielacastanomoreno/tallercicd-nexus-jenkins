# Taller Evaluativo: Automatización CI/CD y Despliegue Contenerizado Multi-Tier
**Ingeniería de Software V (Período 2026-2) · Universidad ICESI**

---

## 🎯 Objetivo de la Práctica (Duración: 2 Horas)

En este taller evaluativo, los estudiantes implementarán y automatizarán un ciclo completo de **Integración Continua (CI)** y **Despliegue Contenerizado (CD)** para una aplicación web multicapa compuesta por:
1. **Backend:** API REST en **Spring Boot (Java 17)** con base de datos H2 en memoria y pruebas unitarias.
2. **Frontend:** Single Page Application (SPA) en **React 18 + Vite + TypeScript**.
3. **Contenedores:** `Dockerfile` Multi-Stage para Backend y Frontend.
4. **Orquestación:** `docker-compose.yml` para levantar el stack con un solo comando.
5. **Pipeline CI/CD:** Workflow automatizado en **GitHub Actions** (`.github/workflows/ci-cd.yml`).

---

## 📂 Estructura del Repositorio

```
.
├── .github/
│   └── workflows/
│       └── ci-cd.yml          # Pipeline de GitHub Actions (4 Jobs)
├── backend/
│   ├── Dockerfile             # Multi-stage build (Maven -> Eclipse Temurin JRE)
│   ├── pom.xml                # Descriptor Maven con dependencias y plugins
│   └── src/
│       ├── main/java/...      # Controlador, Servicio, Repositorio y Modelo
│       └── test/java/...      # Pruebas unitarias y de controlador
├── frontend/
│   ├── Dockerfile             # Multi-stage build (Node.js -> Nginx Alpine)
│   ├── nginx.conf             # Configuración del servidor web de producción
│   ├── package.json           # Dependencias y scripts de construcción
│   └── src/                   # Componentes React, interfaz y llamadas al API
├── docker-compose.yml         # Orquestación del stack local
└── README.md
```

---

## 🚀 Guía Rápida de Ejecución Local

### 1. Ejecutar Backend de Manera Independiente
```bash
cd backend
mvn clean test
mvn spring-boot:run
# El API estará disponible en http://localhost:8080/api/products
```

### 2. Ejecutar Frontend en Modo Desarrollo
```bash
cd frontend
npm install
npm run dev
# La aplicación abrirá en http://localhost:3000
```

### 3. Levantar Todo el Stack con Docker Compose
```bash
docker compose up -d --build
docker compose ps
# Frontend: http://localhost:3000
# Backend:  http://localhost:8080/api/products
```

### 4. Apagar y Limpiar Contenedores
```bash
docker compose down -v
```

---

## 📋 Entregables del Taller

1. Repositorio en GitHub con el pipeline de **GitHub Actions en Verde (Passing)**.
2. Documento formal del taller en PDF siguiendo la plantilla IEEE/Icesi de dos columnas.
3. Capturas de pantalla evidenciando la ejecución de los 4 jobs de CI/CD y el stack corriendo en contenedores.

Documentos de apoyo:

1. [Enunciado](/docs/Taller_Evaluativo_CI_CD.pdf).
2. [Presentación Introducción a Docker](/docs/sesion_06_introduccion_docker.pdf)
3. [Presentación GitHub Actions](/docs/Presentacion_GitHub_Actions_CICD.pdf)


## 💡 Notas de Ayuda y Buenas Prácticas

> **Uso de `.dockerignore`:**  
> Recuerden configurar y utilizar un archivo `.dockerignore` tanto en el directorio `backend/` como en `frontend/` cuando lo consideren necesario. Omitir este archivo provocará que se transfieran al contexto de compilación artefactos innecesarios (como `node_modules`, `dist`, `target/` o `.git`), resultando en builds lentos e **imágenes Docker ultrapesadas**.