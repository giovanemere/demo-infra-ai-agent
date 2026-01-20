#!/bin/bash

echo "🔧 CORRIGIENDO TECHDOCS - Repositorio Templates"
echo "==============================================="

# Auto-load environment variables
if [ -f ".env" ]; then
    set -a; source .env; set +a
elif [ -f "../backstage-idp/infra-ai-backstage/.env" ]; then
    cd ../backstage-idp/infra-ai-backstage; set -a; source .env; set +a; cd - > /dev/null
elif [ -f "backstage-idp/infra-ai-backstage/.env" ]; then
    cd backstage-idp/infra-ai-backstage; set -a; source .env; set +a; cd - > /dev/null
fi

echo "1️⃣ Clonando repositorio de templates..."
TEMP_DIR=$(mktemp -d)
cd $TEMP_DIR
git clone https://github.com/giovanemere/demo-infra-ai-agent-template-idp.git
cd demo-infra-ai-agent-template-idp

echo ""
echo "2️⃣ Creando estructura de documentación..."

# Crear directorio docs
mkdir -p docs

# Crear mkdocs.yml
cat > mkdocs.yml << 'EOF'
site_name: Infrastructure AI Platform
site_description: AI-powered infrastructure analysis and template generation

nav:
  - Home: index.md
  - Architecture: architecture.md
  - API Reference: api.md
  - Configuration: configuration.md

theme:
  name: material
  palette:
    primary: blue
    accent: blue

plugins:
  - techdocs-core

markdown_extensions:
  - admonition
  - codehilite
  - pymdownx.superfences
EOF

# Crear documentación principal
cat > docs/index.md << 'EOF'
# Infrastructure AI Platform

## Overview

The Infrastructure AI Platform is an intelligent system that automatically analyzes AWS architecture descriptions and generates Backstage catalog entries.

## Features

- **Text Analysis**: Process natural language descriptions of AWS architectures
- **Image Analysis**: Analyze architecture diagrams using AI vision
- **Backstage Integration**: Automatic catalog entry generation
- **GitHub Integration**: Save projects directly to repositories
- **Template System**: Generate complete project structures

## Quick Start

1. Access the AI Agent at http://localhost:8000
2. Configure your GitHub repository in the settings
3. Process your architecture description or diagram
4. View the generated project in Backstage

## Architecture

The platform consists of three main components:

- **AI Agent**: FastAPI backend with Gemini AI integration
- **Backstage**: Internal Developer Platform for catalog management
- **PostgreSQL**: Database for persistence and configuration
EOF

# Crear documentación de arquitectura
cat > docs/architecture.md << 'EOF'
# Architecture

## System Overview

```
User → AI Agent (:8000) → Gemini AI → GitHub → Backstage (:3000)
```

## Components

### AI Agent
- **Technology**: FastAPI + Python
- **Port**: 8000
- **Function**: Process text/image inputs, generate YAML, save to GitHub

### Backstage
- **Technology**: Node.js + TypeScript
- **Ports**: 3000 (UI), 7007 (API)
- **Function**: Catalog management, templates, documentation

### Database
- **Technology**: PostgreSQL
- **Port**: 5432
- **Function**: Store analysis history, GitHub configurations

## Data Flow

1. User submits architecture description
2. AI Agent processes with Gemini API
3. Generated YAML is validated
4. Project structure is created in GitHub
5. Backstage auto-discovers the new component
EOF

# Crear documentación de API
cat > docs/api.md << 'EOF'
# API Reference

## Endpoints

### POST /process-text
Process text description of AWS architecture.

**Request:**
```bash
curl -X POST "http://localhost:8000/process-text" \
  -F "description=Web app with S3, CloudFront and Lambda"
```

**Response:**
```json
{
  "status": "success",
  "yaml_content": "...",
  "github_url": "...",
  "project_name": "ai-project-1234"
}
```

### POST /process-image
Process architecture diagram image.

**Request:**
```bash
curl -X POST "http://localhost:8000/process-image" \
  -F "image=@diagram.png"
```

### POST /configure-github
Configure GitHub repository settings.

### GET /history
Get analysis history.

### GET /health
Health check endpoint.
EOF

# Crear documentación de configuración
cat > docs/configuration.md << 'EOF'
# Configuration

## Environment Variables

### AI Agent (.env)
```bash
GEMINI_API_KEY=your_gemini_api_key
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
GITHUB_TOKEN=your_github_token
```

### Backstage (.env)
```bash
BACKEND_BASE_URL=http://localhost:7007
APP_BASE_URL=http://localhost:3000
GITHUB_ORG=your_github_org
GITHUB_REPO=your_template_repo
POSTGRES_HOST=localhost
```

## GitHub Setup

1. Create a GitHub Personal Access Token
2. Configure repository permissions
3. Set up OAuth app for Backstage authentication

## Database Setup

PostgreSQL is required for:
- Analysis history storage
- GitHub configuration persistence
- Backstage catalog data
EOF

echo ""
echo "3️⃣ Actualizando catalog-info.yaml..."

# Actualizar catalog-info.yaml para que apunte correctamente a docs
sed -i 's/backstage.io\/techdocs-ref: dir:\./backstage.io\/techdocs-ref: dir:./' catalog-info.yaml

echo ""
echo "4️⃣ Subiendo cambios a GitHub..."

git add .
git commit -m "docs: Add complete TechDocs documentation

✅ Created mkdocs.yml configuration
✅ Added comprehensive documentation:
  - index.md - Platform overview
  - architecture.md - System architecture
  - api.md - API reference
  - configuration.md - Setup guide
✅ Fixed TechDocs integration with Backstage"

git push

echo ""
echo "5️⃣ Limpiando archivos temporales..."
cd /home/giovanemere/demos
rm -rf $TEMP_DIR

echo ""
echo "✅ TECHDOCS CORREGIDO"
echo "===================="
echo "📚 Documentación creada en repositorio de templates"
echo "🔧 mkdocs.yml configurado correctamente"
echo "📖 Páginas creadas: index, architecture, api, configuration"
echo "🔄 Backstage sincronizará automáticamente"
echo ""
echo "🌐 Para ver la documentación:"
echo "  1. Ve a http://localhost:3000/catalog"
echo "  2. Busca el componente 'ai-agent'"
echo "  3. Haz clic en la pestaña 'Docs'"
