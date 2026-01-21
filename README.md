# 🤖 Infrastructure AI Platform

**Análisis automático de arquitecturas AWS con IA → Catálogo Backstage**

## 🚀 Inicio Rápido

### Prerrequisitos
📋 **[Ver Guía Completa de Prerrequisitos](docs/ai/prerequisites.md)**

**Instalación rápida de MkDocs (REQUERIDO):**
```bash
sudo apt install -y pipx
pipx install mkdocs
pipx inject mkdocs mkdocs-material mkdocs-techdocs-core
sudo ln -sf ~/.local/bin/mkdocs /usr/local/bin/mkdocs
```

### Inicio de la Plataforma
```bash
# 1. Verificar prerequisitos
./task-runner.sh check

# 2. Iniciar plataforma completa
./task-runner.sh start

# 3. Verificar estado
./task-runner.sh status
```

**URLs**: http://localhost:8000 (API) | http://localhost:8000/docs (Docs) | http://localhost:3000 (Backstage)

## 🏗️ Arquitectura

```
Usuario → AI Agent (:8000) → Gemini AI → GitHub → Backstage (:3000)
                ↓
        PostgreSQL (:5432) ← Config Sync
```

## 🔧 Comandos Principales

```bash
# Sistema de tareas dinámico (NUEVO)
./task-runner.sh                    # Ver todas las tareas disponibles
./task-runner.sh start              # Iniciar plataforma
./task-runner.sh stop               # Detener servicios
./task-runner.sh test               # Probar conectividad
./task-runner.sh commit             # Commit interactivo
./task-runner.sh deploy v1.3.0      # Deploy con versión

# Scripts tradicionales (compatibilidad)
./start-platform.sh                 # Iniciar todo
./stop-platform.sh                  # Detener todo
./check-prerequisites.sh            # Verificar sistema
```

## 🧪 Uso

```bash
# Procesar texto
curl -X POST "http://localhost:8000/process-text" \
  -F "description=App web con S3, CloudFront y Lambda"

# Procesar imagen de arquitectura
curl -X POST "http://localhost:8000/process-image" \
  -F "file=@architecture-diagram.png"

# Ver resultado en Backstage
# http://localhost:3000/catalog
```

## 📚 Documentación

### Documentación Principal
- **[CHANGELOG.md](CHANGELOG.md)** - Historial de versiones y cambios
- **[SCRIPTS_CLEANUP.md](SCRIPTS_CLEANUP.md)** - Organización de scripts

### Documentación Técnica (`docs/ai/`)
- **[Contexto](docs/ai/contexto.md)** - Estado actual del proyecto
- **[Setup](docs/ai/setup.md)** - Instalación y configuración
- **[Comandos](docs/ai/comandos.md)** - Lista completa de comandos
- **[Arquitectura](docs/ai/architecture.md)** - Arquitectura detallada
- **[Workflows](docs/ai/workflows.md)** - Flujos de trabajo
- **[Componentes](docs/ai/components.md)** - Documentación técnica
- **[Troubleshooting](docs/ai/troubleshooting.md)** - Resolución de problemas
- **[Templates Analysis](docs/ai/backstage-templates-analysis.md)** - Análisis y corrección de templates

### Release Notes (`docs/versions/`)
- **[v1.2.0](docs/versions/VERSION_1.2.0.md)** - Versión actual
- **[v1.1.0](docs/versions/VERSION_1.1.0.md)** - Versión anterior
- **[v1.0.0](docs/versions/VERSION_1.0.0.md)** - Versión inicial

## 🏛️ Arquitectura Multi-Repositorio

```
/home/giovanemere/demos/ (workspace principal)
├── demos/ (repo principal - scripts de orquestación)
├── backstage-idp/ (repo Backstage IDP)
├── infra-ai-agent/ (repo AI Agent + FastAPI)
├── catalog-repo/ (repo catálogo Backstage)
└── templates-repo/ (repo templates Backstage)
```

## 🔄 Versión Actual: v1.2.0

### Características Principales
- ✅ Sistema dinámico de tareas (`task-runner.sh`)
- ✅ Integración GitHub-Backstage completa
- ✅ Procesamiento AI con Gemini (texto + imágenes)
- ✅ Gestión de configuraciones .env ↔ PostgreSQL
- ✅ TechDocs y documentación automatizada
- ✅ Seguridad mejorada (sin tokens hardcodeados)

### Próximas Características
- 🔄 Templates avanzados de Backstage
- 🔄 Análisis de costos AWS
- 🔄 Integración con más proveedores cloud
