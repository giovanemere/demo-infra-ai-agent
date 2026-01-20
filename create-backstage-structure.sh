#!/bin/bash

echo "🔧 CREANDO ESTRUCTURA VÁLIDA BACKSTAGE - Múltiples Proyectos"
echo "============================================================"

# Auto-load environment variables
if [ -f ".env" ]; then
    set -a; source .env; set +a
elif [ -f "../backstage-idp/infra-ai-backstage/.env" ]; then
    cd ../backstage-idp/infra-ai-backstage; set -a; source .env; set +a; cd - > /dev/null
elif [ -f "backstage-idp/infra-ai-backstage/.env" ]; then
    cd backstage-idp/infra-ai-backstage; set -a; source .env; set +a; cd - > /dev/null
fi

TEMP_DIR=$(mktemp -d)
cd $TEMP_DIR

echo "1️⃣ Clonando y limpiando repositorio..."
git clone https://github.com/giovanemere/demo-infra-ai-agent-template-idp.git
cd demo-infra-ai-agent-template-idp

# Limpiar todo excepto .git
find . -maxdepth 1 ! -name '.git' ! -name '.' -exec rm -rf {} \;

echo ""
echo "2️⃣ Creando estructura Backstage válida..."

# Crear catalog-info.yaml principal (Location)
cat > catalog-info.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Location
metadata:
  name: infrastructure-ai-templates
  description: Infrastructure AI Platform Templates and Components
  annotations:
    backstage.io/managed-by-location: url:https://github.com/giovanemere/demo-infra-ai-agent-template-idp/blob/main/catalog-info.yaml
spec:
  targets:
    - ./templates/**/template.yaml
    - ./components/**/catalog-info.yaml
    - ./systems/**/catalog-info.yaml
    - ./resources/**/catalog-info.yaml
EOF

# Crear estructura de directorios
mkdir -p {templates,components,systems,resources,docs}

echo ""
echo "3️⃣ Creando System (Infrastructure AI Platform)..."
mkdir -p systems/infrastructure-ai-platform
cat > systems/infrastructure-ai-platform/catalog-info.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: System
metadata:
  name: infrastructure-ai-platform
  description: AI-powered infrastructure analysis and template generation platform
  tags:
    - ai
    - infrastructure
    - platform
  annotations:
    github.com/project-slug: giovanemere/demo-infra-ai-agent-template-idp
    backstage.io/techdocs-ref: dir:../../docs
spec:
  owner: group:default/developers
  domain: platform
EOF

echo ""
echo "4️⃣ Creando Components..."

# AI Agent Component
mkdir -p components/ai-agent
cat > components/ai-agent/catalog-info.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: ai-agent
  title: Infrastructure AI Agent
  description: AI Agent for processing infrastructure descriptions using Gemini API
  tags:
    - ai
    - backend
    - python
    - fastapi
    - gemini
  annotations:
    github.com/project-slug: giovanemere/demo-infra-ai-agent
    backstage.io/techdocs-ref: dir:../../docs/ai-agent
spec:
  type: service
  lifecycle: production
  owner: group:default/developers
  system: infrastructure-ai-platform
  providesApis:
    - ai-agent-api
  dependsOn:
    - resource:default/gemini-api
    - resource:default/postgresql
EOF

# Backstage IDP Component
mkdir -p components/backstage-idp
cat > components/backstage-idp/catalog-info.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: backstage-idp
  title: Backstage Internal Developer Platform
  description: Internal Developer Platform for catalog management and templates
  tags:
    - platform
    - frontend
    - typescript
    - backstage
  annotations:
    github.com/project-slug: giovanemere/demo-infra-backstage
    backstage.io/techdocs-ref: dir:../../docs/backstage-idp
spec:
  type: website
  lifecycle: production
  owner: group:default/developers
  system: infrastructure-ai-platform
  consumesApis:
    - ai-agent-api
  dependsOn:
    - resource:default/postgresql
EOF

echo ""
echo "5️⃣ Creando APIs..."
mkdir -p components/ai-agent-api
cat > components/ai-agent-api/catalog-info.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: API
metadata:
  name: ai-agent-api
  description: REST API for AI-powered infrastructure analysis
  tags:
    - rest
    - ai
    - infrastructure
spec:
  type: openapi
  lifecycle: production
  owner: group:default/developers
  system: infrastructure-ai-platform
  definition: |
    openapi: 3.0.0
    info:
      title: AI Agent API
      version: 1.0.0
      description: API for processing infrastructure descriptions with AI
    servers:
      - url: http://localhost:8000
        description: Development server
    paths:
      /process-text:
        post:
          summary: Process text description
          description: Analyze infrastructure description and generate Backstage YAML
          requestBody:
            required: true
            content:
              application/json:
                schema:
                  type: object
                  properties:
                    description:
                      type: string
                      description: Infrastructure description text
          responses:
            '200':
              description: Successful processing
              content:
                application/json:
                  schema:
                    type: object
                    properties:
                      status:
                        type: string
                      yaml_content:
                        type: string
                      project_id:
                        type: string
      /process-image:
        post:
          summary: Process image
          description: Analyze infrastructure diagram and generate Backstage YAML
          requestBody:
            required: true
            content:
              multipart/form-data:
                schema:
                  type: object
                  properties:
                    image:
                      type: string
                      format: binary
          responses:
            '200':
              description: Successful processing
EOF

echo ""
echo "6️⃣ Creando Resources..."
mkdir -p resources/gemini-api
cat > resources/gemini-api/catalog-info.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: gemini-api
  description: Google Gemini AI API for text and vision processing
  tags:
    - ai
    - external-api
    - google
spec:
  type: api
  owner: group:default/developers
  system: infrastructure-ai-platform
EOF

mkdir -p resources/postgresql
cat > resources/postgresql/catalog-info.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: postgresql
  description: PostgreSQL database for platform persistence
  tags:
    - database
    - postgresql
spec:
  type: database
  owner: group:default/developers
  system: infrastructure-ai-platform
EOF

echo ""
echo "7️⃣ Creando Template de Scaffolder..."
mkdir -p templates/ai-infrastructure-project
cat > templates/ai-infrastructure-project/template.yaml << 'EOF'
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: ai-infrastructure-project
  title: AI Infrastructure Project
  description: Create a new infrastructure project analyzed by AI
  tags:
    - recommended
    - ai
    - infrastructure
    - aws
spec:
  owner: group:default/developers
  type: service
  parameters:
    - title: Project Information
      required:
        - name
        - description
      properties:
        name:
          title: Name
          type: string
          description: Unique name for the project
          pattern: '^[a-zA-Z0-9-]+$'
        description:
          title: Description
          type: string
          description: Description of the infrastructure
        owner:
          title: Owner
          type: string
          description: Owner of the component
          default: group:default/developers
        technology:
          title: Technology
          type: string
          description: Primary technology
          default: aws
          enum:
            - aws
            - azure
            - gcp
            - kubernetes
  steps:
    - id: template
      name: Fetch Skeleton
      action: fetch:template
      input:
        url: ./content
        values:
          name: ${{ parameters.name }}
          description: ${{ parameters.description }}
          owner: ${{ parameters.owner }}
          technology: ${{ parameters.technology }}
    - id: publish
      name: Publish
      action: publish:github
      input:
        allowedHosts: ['github.com']
        description: This is ${{ parameters.name }}
        repoUrl: github.com?owner=giovanemere&repo=${{ parameters.name }}
    - id: register
      name: Register
      action: catalog:register
      input:
        repoContentsUrl: ${{ steps.publish.output.repoContentsUrl }}
        catalogInfoPath: '/catalog-info.yaml'
  output:
    links:
      - title: Repository
        url: ${{ steps.publish.output.remoteUrl }}
      - title: Open in catalog
        icon: catalog
        entityRef: ${{ steps.register.output.entityRef }}
EOF

# Crear contenido del template
mkdir -p templates/ai-infrastructure-project/content
cat > templates/ai-infrastructure-project/content/catalog-info.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: ${{ values.name }}
  title: ${{ values.name }}
  description: ${{ values.description }}
  annotations:
    github.com/project-slug: giovanemere/${{ values.name }}
    backstage.io/techdocs-ref: dir:.
  tags:
    - ai-generated
    - infrastructure
    - ${{ values.technology }}
spec:
  type: service
  lifecycle: experimental
  owner: ${{ values.owner }}
  system: infrastructure-ai-platform
EOF

cat > templates/ai-infrastructure-project/content/README.md << 'EOF'
# ${{ values.name }}

${{ values.description }}

## Technology Stack
- Primary: ${{ values.technology }}
- Generated by: Infrastructure AI Platform

## Owner
${{ values.owner }}
EOF

echo ""
echo "8️⃣ Creando documentación TechDocs..."

# mkdocs.yml principal
cat > mkdocs.yml << 'EOF'
site_name: Infrastructure AI Platform
site_description: AI-powered infrastructure analysis and template generation

nav:
  - Home: index.md
  - Architecture: architecture.md
  - Components:
    - AI Agent: ai-agent/index.md
    - Backstage IDP: backstage-idp/index.md
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

# Documentación principal
cat > docs/index.md << 'EOF'
# Infrastructure AI Platform

## Overview
The Infrastructure AI Platform automatically analyzes AWS architecture descriptions and generates Backstage catalog entries.

## Components
- **AI Agent**: FastAPI backend with Gemini AI integration
- **Backstage IDP**: Internal Developer Platform
- **PostgreSQL**: Database for persistence

## Quick Start
1. Access AI Agent at http://localhost:8000
2. Configure GitHub repository
3. Process architecture description
4. View in Backstage catalog
EOF

cat > docs/architecture.md << 'EOF'
# Architecture

## System Overview
```
User → AI Agent (:8000) → Gemini AI → GitHub → Backstage (:3000)
```

## Components
- **AI Agent**: Process inputs, generate YAML
- **Backstage**: Catalog management, templates
- **PostgreSQL**: Data persistence
EOF

# Documentación por componente
mkdir -p docs/ai-agent docs/backstage-idp

cat > docs/ai-agent/index.md << 'EOF'
# AI Agent

FastAPI backend that processes infrastructure descriptions using Gemini AI.

## Features
- Text analysis
- Image analysis
- GitHub integration
- YAML generation
EOF

cat > docs/backstage-idp/index.md << 'EOF'
# Backstage IDP

Internal Developer Platform for catalog management.

## Features
- Component catalog
- Template system
- Documentation (TechDocs)
- GitHub integration
EOF

cat > docs/api.md << 'EOF'
# API Reference

## Endpoints
- `POST /process-text` - Process text description
- `POST /process-image` - Process architecture diagram
- `GET /health` - Health check
EOF

cat > docs/configuration.md << 'EOF'
# Configuration

## Environment Variables
- `GEMINI_API_KEY` - Google Gemini API key
- `GITHUB_TOKEN` - GitHub personal access token
- `POSTGRES_HOST` - PostgreSQL host
EOF

echo ""
echo "9️⃣ Subiendo estructura a GitHub..."
git add .
git commit -m "feat: Complete Backstage multi-project structure

✅ Location with auto-discovery patterns
✅ System: infrastructure-ai-platform
✅ Components: ai-agent, backstage-idp, ai-agent-api
✅ Resources: gemini-api, postgresql
✅ Template: ai-infrastructure-project with Scaffolder
✅ Complete TechDocs documentation structure
✅ Proper entity relationships and dependencies"

git push

echo ""
echo "🔟 Limpiando archivos temporales..."
cd /home/giovanemere/demos
rm -rf $TEMP_DIR

echo ""
echo "✅ ESTRUCTURA BACKSTAGE VÁLIDA CREADA"
echo "===================================="
echo "📁 Estructura creada:"
echo "  ├── catalog-info.yaml (Location principal)"
echo "  ├── systems/infrastructure-ai-platform/"
echo "  ├── components/ai-agent/"
echo "  ├── components/backstage-idp/"
echo "  ├── components/ai-agent-api/"
echo "  ├── resources/gemini-api/"
echo "  ├── resources/postgresql/"
echo "  ├── templates/ai-infrastructure-project/"
echo "  ├── docs/ (TechDocs completa)"
echo "  └── mkdocs.yml"
echo ""
echo "🔄 Backstage sincronizará automáticamente en ~5 minutos"
echo "🌐 Verifica en: http://localhost:3000/catalog"
