# Kit del taller - Alternativa 1: IaaS en AWS
Descomprima en la RAIZ de codigo_base/ (agrega maven/, scripts/, nexus/, deploy/, reto-registry/).
Agregue a .gitignore:  scripts/env.sh  build-release/  release/  .env  .env.registry
- scripts/install-docker.sh : Docker + Compose + swap en las EC2 (Fase 2)
- nexus/                    : Nexus con Docker Compose (Fase 3)
- maven/                    : settings.xml (sin credenciales) y fragmento de pom.xml (Fase 4)
- scripts/publish-release.sh: build + publicacion de un release (Fases 4 y 6)
- deploy/                   : fetch-release.sh, compose por artefactos y .env.example (Fase 5)
- reto-registry/            : Dockerfiles de runtime, build-and-push.sh y compose por pull (Reto)
Las credenciales NUNCA se guardan en archivos: se cargan con 'source scripts/env.sh'.
