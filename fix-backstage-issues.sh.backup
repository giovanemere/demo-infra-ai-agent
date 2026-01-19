#!/bin/bash

echo "🔧 Solucionando problemas de Backstage"
echo "====================================="

# 1. Crear template real de Scaffolder en el repositorio
TEMP_DIR="/tmp/fix-backstage-templates"
rm -rf $TEMP_DIR
git clone git@github.com:giovanemere/demo-infra-ai-agent-template-idp.git $TEMP_DIR

cd $TEMP_DIR

# Crear estructura de templates para Scaffolder
mkdir -p templates/ai-infrastructure-project

# Crear template.yaml para Scaffolder
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
spec:
  owner: group:default/developers
  type: service
  parameters:
    - title: Fill in some steps
      required:
        - name
        - description
      properties:
        name:
          title: Name
          type: string
          description: Unique name of the component
          pattern: '^([a-z0-9]|[.]|[_]|[-])+$'
        description:
          title: Description
          type: string
          description: Help others understand what this component is for.
        owner:
          title: Owner
          type: string
          description: Owner of the component
          default: group:default/developers
          ui:field: OwnerPicker
          ui:options:
            catalogFilter:
              kind: Group
  steps:
    - id: fetch-base
      name: Fetch Base
      action: fetch:template
      input:
        url: ./content
        values:
          name: ${{ parameters.name }}
          description: ${{ parameters.description }}
          owner: ${{ parameters.owner }}

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
  description: ${{ values.description }}
  annotations:
    github.com/project-slug: giovanemere/${{ values.name }}
spec:
  type: service
  lifecycle: experimental
  owner: ${{ values.owner }}
  system: infrastructure-ai-platform
EOF

cat > templates/ai-infrastructure-project/content/README.md << 'EOF'
# ${{ values.name }}

${{ values.description }}

## Getting Started

This project was created using the AI Infrastructure Platform.

## Owner

${{ values.owner }}
EOF

cat > templates/ai-infrastructure-project/content/.gitignore << 'EOF'
# Dependencies
node_modules/
venv/
.env

# Logs
*.log

# OS
.DS_Store
Thumbs.db
EOF

# Actualizar catalog-info.yaml principal para incluir templates
cat > catalog-info.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Location
metadata:
  name: infrastructure-ai-templates
  description: Infrastructure AI Platform Templates
  annotations:
    backstage.io/managed-by-location: url:https://github.com/giovanemere/demo-infra-ai-agent-template-idp/blob/main/catalog-info.yaml
spec:
  targets:
    - ./templates/**/template.yaml
    - ./entities/**/*.yaml
    - ./components/**/*.yaml
    - ./projects/**/catalog-info.yaml
---
apiVersion: backstage.io/v1alpha1
kind: System
metadata:
  name: infrastructure-ai-platform
  description: AI-powered infrastructure analysis and template generation
  tags:
    - ai
    - infrastructure
    - platform
spec:
  owner: group:default/developers
---
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: ai-agent
  description: AI Agent for processing infrastructure descriptions
  annotations:
    github.com/project-slug: giovanemere/demo-infra-ai-agent
    backstage.io/techdocs-ref: dir:.
  tags:
    - ai
    - backend
    - python
spec:
  type: service
  lifecycle: production
  owner: group:default/developers
  system: infrastructure-ai-platform
---
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: backstage-idp
  description: Backstage Internal Developer Platform
  annotations:
    github.com/project-slug: giovanemere/demo-infra-backstage
    backstage.io/techdocs-ref: dir:.
  tags:
    - platform
    - frontend
    - typescript
spec:
  type: website
  lifecycle: production
  owner: group:default/developers
  system: infrastructure-ai-platform
---
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: developers
  description: Development team for Infrastructure AI Platform
spec:
  type: team
  children: []
EOF

# Commit y push
git add .
git commit -m "feat: Add Scaffolder template and fix catalog structure

- Added complete Scaffolder template for AI infrastructure projects
- Fixed catalog-info.yaml to include templates directory
- Added Group definition to resolve missing relations
- Template includes content structure for new projects
- Ready for Backstage template creation workflow"

git push origin main

echo "✅ Template de Scaffolder creado y subido"

# Limpiar
cd /home/giovanemere/demos
rm -rf $TEMP_DIR
