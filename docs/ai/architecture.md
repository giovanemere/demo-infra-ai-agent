# Arquitectura Detallada - Infrastructure AI Platform

## Visión General del Sistema

```
┌─────────────────────────────────────────────────────────────────┐
│                    Infrastructure AI Platform                    │
├─────────────────────────────────────────────────────────────────┤
│  Usuario → AI Agent (:8000) → Gemini AI → GitHub → Backstage   │
│                      ↓                                          │
│              PostgreSQL (:5432) ← Config Sync                  │
└─────────────────────────────────────────────────────────────────┘
```

## Repositorios y Arquitectura

### 1. demos/ (Repositorio Principal)
**GitHub**: `demo-infra-ai-agent`
**Propósito**: Orquestación y scripts de gestión

```
demos/
├── task-runner.sh              # Sistema dinámico de tareas
├── start-platform.sh           # Iniciar servicios
├── stop-platform.sh            # Detener servicios
├── check-prerequisites.sh      # Verificar prerequisitos
├── verify-complete-solution.sh # Estado completo
├── test-github-backstage.sh    # Pruebas conectividad
├── manage-env-configs.sh       # Gestión configuraciones
├── sync-all-repositories.sh    # Sincronización repos
├── docs/ai/                    # Documentación AI Assistant
│   ├── contexto.md
│   ├── setup.md
│   ├── comandos.md
│   ├── decisiones.md
│   └── troubleshooting.md
└── .env-backups/               # Backups configuraciones
```

### 2. infra-ai-agent/ (Servicio AI)
**GitHub**: `demo-infra-ai-agent`
**Propósito**: API FastAPI + Frontend + Lógica AI

```
infra-ai-agent/
├── agent/
│   ├── main.py                 # FastAPI app principal
│   ├── processors/
│   │   ├── text.py            # Procesamiento texto
│   │   └── vision.py          # Procesamiento imágenes
│   ├── validators/
│   │   └── backstage.py       # Validación Backstage
│   ├── static/
│   │   └── index.html         # Frontend único
│   ├── database.py            # Conexión DB
│   └── git_client.py          # Cliente GitHub
├── templates-repo/             # Sub-repo templates
├── requirements.txt            # Dependencias Python
├── .env                       # Variables de entorno
├── start.sh                   # Script inicio
└── docs/                      # Documentación técnica
```

**Arquitectura Interna**:
```
FastAPI App (:8000)
├── /process-text     → text.py → Gemini API
├── /process-image    → vision.py → Gemini API
├── /static/          → Frontend HTML/JS
└── /health           → Health check
```

### 3. backstage-idp/ (Plataforma Backstage)
**GitHub**: `demo-infra-backstage`
**Propósito**: IDP Backstage + Gestión configuraciones

```
backstage-idp/
├── infra-ai-backstage/         # App Backstage
│   ├── app-config.yaml        # Configuración principal
│   ├── package.json           # Dependencias Node.js
│   ├── .env                   # Variables entorno
│   └── packages/              # Plugins Backstage
├── manage-config.sh           # Gestión .env ↔ PostgreSQL
├── config-manager.js          # Script Node.js sync
├── docker-compose.yml         # Servicios Docker
└── scripts/                   # Scripts validación
    ├── system-check.sh
    ├── validate-github-auth.sh
    └── verify-catalog-sync.sh
```

**Arquitectura Backstage**:
```
Backstage Frontend (:3000)
├── Catalog → GitHub repos
├── TechDocs → MkDocs
├── Templates → Scaffolder
└── Auth → GitHub OAuth

Backstage Backend (:7007)
├── Catalog API
├── TechDocs API
├── Scaffolder API
└── PostgreSQL (:5432)
```

### 4. catalog-repo/ (Catálogo Backstage)
**GitHub**: `demo-infra-ai-agent-template-idp`
**Propósito**: Definiciones de componentes y servicios

```
catalog-repo/
├── catalog-info.yaml           # Catálogo principal
├── components/                 # Definiciones componentes
│   ├── ai-agent/
│   ├── backstage-idp/
│   └── ai-agent-api/
├── systems/                    # Sistemas
├── resources/                  # Recursos (DB, APIs)
├── templates/                  # Templates Scaffolder
├── docs/                       # Documentación TechDocs
└── mkdocs.yml                 # Configuración docs
```

### 5. templates-repo/ (Templates Backstage)
**GitHub**: `demo-infra-ai-agent-template-idp`
**Propósito**: Templates para generación de código

```
templates-repo/
├── templates/
│   └── ai-infrastructure-project/
├── components/                 # Componentes ejemplo
├── systems/                   # Sistemas ejemplo
└── docs/                      # Documentación templates
```

## Servicios y Puertos

| Servicio | Puerto | Propósito |
|----------|--------|-----------|
| AI Agent | 8000 | API FastAPI + Frontend |
| Backstage Frontend | 3000 | Interface usuario |
| Backstage Backend | 7007 | API Backstage |
| PostgreSQL | 5432 | Base de datos |

## Archivos de Configuración Clave

### Variables de Entorno (.env)
```bash
# GitHub
GITHUB_TOKEN=ghp_xxxxx
GITHUB_USER=giovanemere
GITHUB_REPO=demo-infra-ai-agent

# Gemini AI
GEMINI_API_KEY=xxxxx

# PostgreSQL
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=backstage
POSTGRES_PASSWORD=backstage123
POSTGRES_DB=backstage
```

### Docker Compose (backstage-idp/docker-compose.yml)
```yaml
services:
  backstage:
    build: ./infra-ai-backstage
    ports:
      - "3000:3000"
      - "7007:7007"
    environment:
      - POSTGRES_HOST=postgres
    depends_on:
      - postgres
```

### App Config (backstage-idp/infra-ai-backstage/app-config.yaml)
```yaml
app:
  title: Infrastructure AI Platform
  baseUrl: http://localhost:3000

backend:
  baseUrl: http://localhost:7007
  database:
    client: pg
    connection:
      host: ${POSTGRES_HOST}
      port: ${POSTGRES_PORT}
      user: ${POSTGRES_USER}
      password: ${POSTGRES_PASSWORD}

catalog:
  locations:
    - type: url
      target: https://github.com/giovanemere/demo-infra-ai-agent/blob/main/catalog-info.yaml
```

## Flujo de Datos

1. **Usuario** → Frontend (AI Agent :8000)
2. **Frontend** → FastAPI endpoints
3. **FastAPI** → Gemini AI (procesamiento)
4. **FastAPI** → GitHub API (crear repos/archivos)
5. **GitHub** → Backstage (auto-discovery)
6. **Backstage** → PostgreSQL (persistencia)
7. **Config Sync** → PostgreSQL ↔ .env files
