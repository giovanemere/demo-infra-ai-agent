#!/bin/bash

# sync-github-structure.sh - Sincronizar estructura local con repositorios GitHub

set -e

echo "🔄 SINCRONIZACIÓN DE ESTRUCTURA CON GITHUB"
echo "=========================================="

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar mensajes
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 1. Sincronizar repositorio principal (demos)
log_info "Sincronizando repositorio principal..."
git add .
git commit -m "docs: actualizar prerrequisitos y configuración de MkDocs

- Añadir guía completa de prerrequisitos con MkDocs
- Actualizar README con referencia a prerrequisitos
- Incluir configuración para TechDocs de Backstage" || log_warning "No hay cambios para commitear en repositorio principal"

git push origin master
log_success "Repositorio principal sincronizado"

# 2. Verificar estructura del catálogo
log_info "Verificando estructura del catálogo..."
cd catalog-repo

# Verificar que la estructura esté completa
REQUIRED_DIRS=("components" "systems" "resources" "apis" "users" "groups" "templates" "docs")
MISSING_DIRS=()

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        MISSING_DIRS+=("$dir")
    fi
done

if [ ${#MISSING_DIRS[@]} -gt 0 ]; then
    log_warning "Directorios faltantes en catálogo: ${MISSING_DIRS[*]}"
    
    # Crear directorios faltantes
    for dir in "${MISSING_DIRS[@]}"; do
        mkdir -p "$dir"
        echo "# $dir" > "$dir/README.md"
        log_info "Creado directorio: $dir"
    done
fi

# 3. Verificar archivos de configuración críticos
log_info "Verificando archivos de configuración..."

# Verificar mkdocs.yml
if [ ! -f "mkdocs.yml" ]; then
    log_warning "Creando mkdocs.yml para el catálogo..."
    cat > mkdocs.yml << 'EOF'
site_name: 'Infrastructure AI Platform Catalog'
site_description: 'Catálogo de componentes y templates para Infrastructure AI Platform'

nav:
  - Home: index.md
  - Components: components/
  - Systems: systems/
  - Resources: resources/
  - APIs: apis/
  - Templates: templates/

plugins:
  - techdocs-core

theme:
  name: material
  palette:
    primary: blue
    accent: blue
EOF
fi

# Verificar catalog-info.yaml principal
if [ ! -f "catalog-info.yaml" ]; then
    log_warning "Creando catalog-info.yaml principal..."
    cat > catalog-info.yaml << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Location
metadata:
  name: infrastructure-ai-platform-catalog
  title: Infrastructure AI Platform Catalog
  description: Catálogo principal de componentes, sistemas y templates
spec:
  targets:
    - ./components/**/*.yaml
    - ./systems/**/*.yaml
    - ./resources/**/*.yaml
    - ./apis/**/*.yaml
    - ./users/**/*.yaml
    - ./groups/**/*.yaml
    - ./templates/**/*.yaml
EOF
fi

# 4. Sincronizar catálogo con GitHub
log_info "Sincronizando catálogo con GitHub..."
git add .
git commit -m "feat: completar estructura del catálogo Backstage

- Añadir directorios faltantes si los hay
- Crear mkdocs.yml para TechDocs
- Actualizar catalog-info.yaml principal
- Sincronizar con estructura local funcional" || log_warning "No hay cambios para commitear en catálogo"

git push origin main
log_success "Catálogo sincronizado con GitHub"

# 5. Verificar repositorio de Backstage
cd ../backstage-idp
log_info "Verificando repositorio de Backstage..."

# Verificar que app-config.local.yaml no se suba a GitHub (contiene secrets)
if [ ! -f ".gitignore" ] || ! grep -q "app-config.local.yaml" .gitignore; then
    log_warning "Añadiendo app-config.local.yaml a .gitignore..."
    echo "app-config.local.yaml" >> .gitignore
fi

git add .gitignore
git commit -m "security: añadir app-config.local.yaml a .gitignore

- Evitar subir configuración con secrets hardcodeados
- Mantener app-config.yaml con variables de entorno" || log_warning "No hay cambios para commitear en Backstage"

git push origin main || log_warning "No se pudo hacer push al repositorio de Backstage (puede no existir)"

# 6. Verificar repositorio del AI Agent
cd ../infra-ai-agent
log_info "Verificando repositorio del AI Agent..."

# Verificar que el catalog-info.yaml tenga la referencia correcta a TechDocs
if [ -f "catalog-info.yaml" ]; then
    if ! grep -q "backstage.io/techdocs-ref" catalog-info.yaml; then
        log_warning "Añadiendo referencia a TechDocs en catalog-info.yaml..."
        # Backup del archivo original
        cp catalog-info.yaml catalog-info.yaml.backup
        
        # Añadir anotación de TechDocs
        sed -i '/annotations:/a\    backstage.io/techdocs-ref: dir:.' catalog-info.yaml
    fi
fi

git add .
git commit -m "docs: actualizar configuración de TechDocs

- Añadir referencia a TechDocs en catalog-info.yaml
- Asegurar compatibilidad con MkDocs instalado" || log_warning "No hay cambios para commitear en AI Agent"

git push origin main
log_success "AI Agent sincronizado con GitHub"

# 7. Resumen final
cd ..
echo ""
echo "🎉 SINCRONIZACIÓN COMPLETADA"
echo "============================"
log_success "Repositorio principal: actualizado con prerrequisitos"
log_success "Catálogo: estructura completa y sincronizada"
log_success "Backstage: configuración de seguridad actualizada"
log_success "AI Agent: TechDocs configurado correctamente"

echo ""
echo "🔗 URLs de verificación:"
echo "  - Catálogo: https://github.com/giovanemere/demo-infra-ai-agent-template-idp"
echo "  - AI Agent: https://github.com/giovanemere/demo-infra-ai-agent"
echo "  - Backstage: https://github.com/giovanemere/demo-infra-backstage"
echo ""
echo "✅ La estructura local ahora está sincronizada con GitHub"
