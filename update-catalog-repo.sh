#!/bin/bash

echo "🔄 Actualizando Catalog Repo con estructura completa"
echo "=================================================="

cd /home/giovanemere/demos/catalog-repo

# Crear estructura completa
mkdir -p {components,systems,resources,apis,templates,users,groups}

# Actualizar README
cat > README.md << 'EOF'
# 📊 Infrastructure AI Platform - Catalog Repository

## 📁 Estructura del Catálogo

```
catalog-repo/
├── components/     # Componentes de software
├── systems/        # Sistemas y plataformas
├── resources/      # Recursos de infraestructura
├── apis/          # Definiciones de APIs
├── templates/     # Templates de Scaffolder
├── users/         # Usuarios del sistema
└── groups/        # Grupos y equipos
```

## 🔄 Sincronización

Este repositorio se sincroniza automáticamente con:
- **Backstage IDP**: Catálogo principal
- **GitHub Templates**: Repositorio dinámico
- **AI Agent**: Generación automática

## 📋 Uso

Los archivos YAML en este repositorio siguen el estándar de Backstage:
- `kind: Component` - Servicios y aplicaciones
- `kind: System` - Sistemas completos
- `kind: Resource` - Infraestructura
- `kind: API` - Interfaces de programación
- `kind: Template` - Templates de Scaffolder
- `kind: User` - Usuarios
- `kind: Group` - Grupos y equipos

## 🎯 Estado

- ✅ Estructura organizada
- ✅ Sincronización automática
- ✅ Validación YAML
- ✅ Integración con AI Agent
EOF

# Crear componente del sistema principal
cat > systems/infrastructure-ai-platform.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: System
metadata:
  name: infrastructure-ai-platform
  description: AI-powered infrastructure analysis and template generation platform
  tags:
    - ai
    - infrastructure
    - platform
    - automation
  annotations:
    github.com/project-slug: giovanemere/demo-infra-ai-agent
spec:
  owner: developers
  domain: infrastructure
EOF

# Crear componentes principales
cat > components/ai-agent.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: ai-agent
  description: AI Agent for processing infrastructure descriptions using Gemini API
  tags:
    - ai
    - backend
    - python
    - fastapi
  annotations:
    github.com/project-slug: giovanemere/demo-infra-ai-agent
    backstage.io/techdocs-ref: dir:.
spec:
  type: service
  lifecycle: production
  owner: developers
  system: infrastructure-ai-platform
  providesApis:
    - ai-agent-api
  dependsOn:
    - resource:gemini-api
    - resource:postgresql
EOF

cat > components/backstage-idp.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: backstage-idp
  description: Backstage Internal Developer Platform for catalog management
  tags:
    - platform
    - frontend
    - typescript
    - react
  annotations:
    github.com/project-slug: giovanemere/demo-infra-backstage
    backstage.io/techdocs-ref: dir:.
spec:
  type: website
  lifecycle: production
  owner: developers
  system: infrastructure-ai-platform
  consumesApis:
    - github-api
  dependsOn:
    - resource:postgresql
EOF

# Crear APIs
cat > apis/ai-agent-api.yaml << 'EOF'
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
  owner: developers
  system: infrastructure-ai-platform
  definition: |
    openapi: 3.0.0
    info:
      title: AI Agent API
      version: 1.0.0
      description: API for processing infrastructure descriptions with AI
    paths:
      /process-text:
        post:
          summary: Process text description
          description: Analyze infrastructure description and generate Backstage YAML
      /process-image:
        post:
          summary: Process image
          description: Analyze infrastructure diagram and generate Backstage YAML
EOF

# Crear recursos
cat > resources/postgresql.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: postgresql
  description: PostgreSQL database for Backstage and AI Agent
  tags:
    - database
    - postgresql
spec:
  type: database
  lifecycle: production
  owner: developers
  system: infrastructure-ai-platform
EOF

cat > resources/gemini-api.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: gemini-api
  description: Google Gemini API for AI processing
  tags:
    - ai
    - external-api
    - google
spec:
  type: external-api
  lifecycle: production
  owner: developers
  system: infrastructure-ai-platform
EOF

# Crear grupos
cat > groups/developers.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: developers
  description: Development team for Infrastructure AI Platform
spec:
  type: team
  children: []
EOF

# Crear usuarios
cat > users/system-users.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: User
metadata:
  name: giovanemere
  annotations:
    github.com/user-login: giovanemere
spec:
  profile:
    displayName: Giovane Mere
    email: giovanemere@example.com
  memberOf: [developers]
---
apiVersion: backstage.io/v1alpha1
kind: User
metadata:
  name: ai-agent-system
  description: System user for AI Agent automation
spec:
  profile:
    displayName: AI Agent System
    email: ai-agent@system.local
  memberOf: [developers]
EOF

# Commit cambios
git add .
git commit -m "feat: Complete catalog structure

- Added organized directory structure
- Created system definitions
- Added component definitions for AI Agent and Backstage
- Defined APIs and resources
- Added user and group definitions
- Updated documentation

Structure:
- systems/ - Platform definitions
- components/ - Service definitions  
- apis/ - API specifications
- resources/ - Infrastructure resources
- users/ - User definitions
- groups/ - Team definitions"

echo "✅ Catalog Repo actualizado con estructura completa"
echo "📁 Estructura creada:"
echo "  - systems/infrastructure-ai-platform.yaml"
echo "  - components/ai-agent.yaml"
echo "  - components/backstage-idp.yaml"
echo "  - apis/ai-agent-api.yaml"
echo "  - resources/postgresql.yaml"
echo "  - resources/gemini-api.yaml"
echo "  - users/system-users.yaml"
echo "  - groups/developers.yaml"
