# 📋 Prerrequisitos y Configuración - Infrastructure AI Platform

## 🔧 Prerrequisitos del Sistema

### 1. Software Base Requerido
```bash
# Node.js (versión 22 o 24)
node --version  # >= 22.0.0

# Yarn (gestor de paquetes)
yarn --version  # >= 4.4.1

# Python 3.12+
python3 --version  # >= 3.12.0

# Git
git --version

# Docker y Docker Compose (para PostgreSQL)
docker --version
docker-compose --version
```

### 2. MkDocs para TechDocs (NUEVO - REQUERIDO)
```bash
# Instalar pipx si no está disponible
sudo apt install -y pipx

# Instalar MkDocs y plugins necesarios
pipx install mkdocs
pipx inject mkdocs mkdocs-material
pipx inject mkdocs mkdocs-techdocs-core

# Crear enlace simbólico global (CRÍTICO para Backstage)
sudo ln -sf ~/.local/bin/mkdocs /usr/local/bin/mkdocs

# Verificar instalación
mkdocs --version
```

### 3. PostgreSQL
```bash
# Opción 1: Docker (Recomendado)
docker run -d \
  --name backstage-postgres \
  -e POSTGRES_USER=backstage \
  -e POSTGRES_PASSWORD=backstage123 \
  -e POSTGRES_DB=backstage \
  -p 5432:5432 \
  postgres:15

# Opción 2: Instalación local
sudo apt install postgresql postgresql-contrib
```

## 🔐 Configuración de Tokens y Credenciales

### 1. GitHub Personal Access Token
```bash
# Crear token en: https://github.com/settings/tokens
# Permisos requeridos:
# - repo (acceso completo a repositorios)
# - read:org (leer información de organización)
# - user:email (acceso a email del usuario)
```

### 2. Google Gemini API Key
```bash
# Obtener en: https://makersuite.google.com/app/apikey
# Habilitar Gemini API en Google Cloud Console
```

### 3. GitHub OAuth App (Opcional)
```bash
# Crear en: https://github.com/settings/applications/new
# Authorization callback URL: http://localhost:7007/api/auth/github/handler/frame
```

## 📁 Estructura de Repositorios Requerida

### Repositorios GitHub Necesarios:
```
giovanemere/
├── demo-infra-ai-agent/              # Repositorio principal del AI Agent
├── demo-infra-backstage/             # Repositorio de Backstage IDP  
├── demo-infra-ai-agent-template-idp/ # Catálogo y templates de Backstage
└── demos/                            # Workspace local (este repositorio)
```

### Estructura Local del Workspace:
```
/home/giovanemere/demos/
├── backstage-idp/                    # Clon de demo-infra-backstage
│   └── infra-ai-backstage/          # Aplicación Backstage
├── infra-ai-agent/                  # Clon de demo-infra-ai-agent
├── catalog-repo/                    # Clon de demo-infra-ai-agent-template-idp
├── task-runner.sh                   # Script principal de gestión
├── start-platform.sh               # Script de inicio (legacy)
└── stop-platform.sh                # Script de parada (legacy)
```

## ⚙️ Configuración de Variables de Entorno

### 1. AI Agent (.env en infra-ai-agent/)
```bash
# API Keys
GEMINI_API_KEY=your_gemini_api_key_here
GITHUB_TOKEN=ghp_your_github_token_here

# GitHub Configuration
GITHUB_ORG=giovanemere
GITHUB_REPO=demo-infra-ai-agent-template-idp
GITHUB_BRANCH=main

# Database
DATABASE_URL=postgresql://backstage:backstage123@localhost:5432/backstage

# Server Configuration
HOST=0.0.0.0
PORT=8000
```

### 2. Backstage (.env en backstage-idp/infra-ai-backstage/)
```bash
# GitHub Integration
GITHUB_TOKEN=ghp_your_github_token_here
GITHUB_ORG=giovanemere
GITHUB_REPO=demo-infra-ai-agent
GITHUB_BRANCH=main
CATALOG_PATH=/catalog-info.yaml

# Backstage URLs
APP_BASE_URL=http://localhost:3000
BACKEND_BASE_URL=http://localhost:7007

# Database PostgreSQL
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=backstage
POSTGRES_PASSWORD=backstage123
POSTGRES_DB=backstage

# GitHub OAuth (opcional)
GITHUB_CLIENT_ID=your_github_client_id
GITHUB_CLIENT_SECRET=your_github_client_secret

# Backstage Auth Secret (generar con: openssl rand -base64 32)
BACKEND_SECRET=your_generated_secret_here
```

## 🚀 Configuración Inicial

### 1. Clonar Repositorios
```bash
cd /home/giovanemere/demos

# Clonar repositorio principal
git clone https://github.com/giovanemere/demo-infra-ai-agent.git infra-ai-agent

# Clonar repositorio de Backstage
git clone https://github.com/giovanemere/demo-infra-backstage.git backstage-idp

# Clonar repositorio de catálogo
git clone https://github.com/giovanemere/demo-infra-ai-agent-template-idp.git catalog-repo
```

### 2. Configurar AI Agent
```bash
cd infra-ai-agent
cp .env.example .env
# Editar .env con tus credenciales

# Instalar dependencias
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 3. Configurar Backstage
```bash
cd ../backstage-idp/infra-ai-backstage
cp .env.example .env
# Editar .env con tus credenciales

# Instalar dependencias
yarn install
```

### 4. Configurar Base de Datos
```bash
# Iniciar PostgreSQL (si usas Docker)
docker start backstage-postgres

# Verificar conexión
psql -h localhost -U backstage -d backstage -c "SELECT version();"
```

## ✅ Verificación de Instalación

### 1. Verificar Prerrequisitos
```bash
cd /home/giovanemere/demos
./task-runner.sh check
```

### 2. Iniciar Plataforma
```bash
./task-runner.sh start
```

### 3. Verificar Servicios
```bash
# AI Agent
curl http://localhost:8000/health

# Backstage
curl http://localhost:3000

# Verificar TechDocs
curl http://localhost:3000/docs/default/component/ai-agent/
```

## 🔧 Solución de Problemas Comunes

### Error: "spawn mkdocs ENOENT"
```bash
# Verificar que MkDocs esté instalado globalmente
which mkdocs
mkdocs --version

# Si no está disponible, crear enlace simbólico
sudo ln -sf ~/.local/bin/mkdocs /usr/local/bin/mkdocs
```

### Error: "Missing required config value at 'backend.baseUrl'"
```bash
# Verificar que existe app-config.local.yaml con valores hardcodeados
ls -la backstage-idp/infra-ai-backstage/app-config.local.yaml

# Si no existe, el sistema lo creará automáticamente
```

### Error de Conexión a PostgreSQL
```bash
# Verificar que PostgreSQL está corriendo
docker ps | grep postgres
# o
sudo systemctl status postgresql

# Verificar conectividad
nc -zv localhost 5432
```

## 📚 Documentación Adicional

- **[Arquitectura](../docs/ai/architecture.md)** - Arquitectura detallada del sistema
- **[Comandos](../docs/ai/comandos.md)** - Lista completa de comandos disponibles
- **[Troubleshooting](../docs/ai/troubleshooting.md)** - Guía de resolución de problemas
- **[GitHub Auth Setup](../backstage-idp/GITHUB_AUTH_SETUP.md)** - Configuración de autenticación GitHub

## 🎯 Próximos Pasos

1. **Configurar GitHub OAuth** para autenticación completa
2. **Personalizar templates** en el repositorio de catálogo
3. **Configurar CI/CD** para despliegue automático
4. **Añadir más proveedores** de infraestructura (AWS, Azure, GCP)
