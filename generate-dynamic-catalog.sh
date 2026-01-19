#!/bin/bash

echo "🔄 Generando catalog-info.yaml dinámico para proyectos"
echo "===================================================="

# Clonar repositorio temporalmente
TEMP_DIR="/tmp/template-repo-dynamic"
rm -rf $TEMP_DIR
git clone git@github.com:giovanemere/demo-infra-ai-agent-template-idp.git $TEMP_DIR

cd $TEMP_DIR

# Crear carpeta templates si no existe
mkdir -p templates/ai-project

# Crear template base para proyectos
cat > templates/ai-project/catalog-info.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: ${{ values.name }}
  description: ${{ values.description }}
  annotations:
    github.com/project-slug: giovanemere/${{ values.name }}
    backstage.io/techdocs-ref: dir:.
  tags:
    - ai-generated
    - infrastructure
spec:
  type: service
  lifecycle: experimental
  owner: ${{ values.owner }}
  system: infrastructure-ai-platform
EOF

# Crear template.yaml para el scaffolder
cat > templates/ai-project/template.yaml << 'EOF'
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: ai-infrastructure-project
  title: AI Infrastructure Project
  description: Generate infrastructure projects using AI analysis
  tags:
    - ai
    - infrastructure
    - recommended
spec:
  owner: developers
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
          pattern: '^[a-z0-9-]+$'
        description:
          title: Description
          type: string
          description: Description of the infrastructure project
        owner:
          title: Owner
          type: string
          description: Owner of the project
          default: developers
  steps:
    - id: fetch
      name: Fetch Template
      action: fetch:template
      input:
        url: ./
        values:
          name: ${{ parameters.name }}
          description: ${{ parameters.description }}
          owner: ${{ parameters.owner }}
    - id: publish
      name: Publish to GitHub
      action: publish:github
      input:
        allowedHosts: ['github.com']
        description: ${{ parameters.description }}
        repoUrl: github.com?owner=giovanemere&repo=${{ parameters.name }}
    - id: register
      name: Register in Catalog
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

# Generar catalog-info.yaml para cada proyecto existente
echo "📁 Generando catalog-info.yaml para proyectos existentes..."

for project_dir in projects/*/; do
    if [ -d "$project_dir" ]; then
        project_name=$(basename "$project_dir")
        echo "  - Procesando: $project_name"
        
        # Leer descripción del README si existe
        description="AI-generated infrastructure project"
        if [ -f "$project_dir/README.md" ]; then
            # Extraer primera línea que no sea título
            description=$(grep -v "^#" "$project_dir/README.md" | head -1 | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
            if [ -z "$description" ]; then
                description="AI-generated infrastructure project: $project_name"
            fi
        fi
        
        # Crear catalog-info.yaml para el proyecto
        cat > "$project_dir/catalog-info.yaml" << EOF
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: $project_name
  description: "$description"
  annotations:
    github.com/project-slug: giovanemere/demo-infra-ai-agent-template-idp
    backstage.io/source-location: url:https://github.com/giovanemere/demo-infra-ai-agent-template-idp/tree/main/projects/$project_name
  tags:
    - ai-generated
    - infrastructure
    - project
spec:
  type: service
  lifecycle: experimental
  owner: developers
  system: infrastructure-ai-platform
EOF
    fi
done

# Actualizar catalog-info.yaml principal
cp /home/giovanemere/demos/catalog-info-dynamic.yaml ./catalog-info.yaml

# Commit y push cambios
git add .
git commit -m "feat: Add dynamic catalog discovery

- Added templates/ directory with scaffolder template
- Generated catalog-info.yaml for each project in projects/
- Updated main catalog-info.yaml with dynamic discovery
- Added Template for creating new AI infrastructure projects
- Enabled automatic project detection in Backstage"

git push origin main

echo "✅ Catalog dinámico generado y subido"
echo "📊 Proyectos procesados: $(ls -1d projects/*/ | wc -l)"
echo "🔗 Repositorio: https://github.com/giovanemere/demo-infra-ai-agent-template-idp"

# Limpiar
cd /home/giovanemere/demos
rm -rf $TEMP_DIR
