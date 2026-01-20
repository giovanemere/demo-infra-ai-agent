#!/bin/bash

# Organización de archivos .md

set -e

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}📁 $1${NC}"; }

# Crear directorios
mkdir -p docs/versions
mkdir -p archived-docs

log_info "Organizando archivos .md..."
echo ""

# 1. Crear CHANGELOG.md consolidando versiones
log_info "Creando CHANGELOG.md..."
cat > CHANGELOG.md << 'EOF'
# Changelog - Infrastructure AI Platform

Todas las versiones y cambios notables del proyecto.

## [v1.2.0] - 2026-01-20

### Añadido
- Sistema dinámico de tareas (task-runner.sh)
- Documentación técnica completa en docs/ai/
- Scripts de limpieza y organización
- Integración mejorada GitHub-Backstage

### Mejorado
- Seguridad: eliminación de tokens hardcodeados
- Gestión de configuraciones .env ↔ PostgreSQL
- Flujos de trabajo simplificados
- Estructura de repositorios optimizada

### Corregido
- Problemas de autenticación GitHub
- Sincronización de catálogo Backstage
- Variables de entorno en todos los servicios
- TechDocs y documentación

## [v1.1.0] - 2026-01-19

### Añadido
- Integración completa Backstage
- Sistema de templates y catálogo
- Autenticación GitHub OAuth
- TechDocs funcional

### Mejorado
- Arquitectura multi-repositorio
- Scripts de gestión automatizados
- Configuración de servicios

## [v1.0.0] - 2026-01-16

### Añadido
- Versión inicial del Infrastructure AI Platform
- AI Agent con FastAPI
- Procesamiento de texto e imágenes con Gemini
- Integración básica con GitHub
- Backstage IDP inicial
- PostgreSQL como base de datos

### Características Principales
- Análisis automático de arquitecturas AWS
- Generación de componentes Backstage
- Interface web para interacción
- API REST documentada

---

Para detalles completos de cada versión, ver archivos en `docs/versions/`
EOF

# 2. Mover archivos de versiones
log_warning "Moviendo archivos de versiones a docs/versions/..."
mv VERSION_*.md docs/versions/ 2>/dev/null || true

# 3. Archivar documentación obsoleta
log_warning "Archivando documentación obsoleta..."

# Status históricos
mv ALL_SCRIPTS_FIXED.md BACKSTAGE_STRUCTURE.md DEPLOYMENT_STATUS.md FINAL_STATUS.md archived-docs/ 2>/dev/null || true
mv FRONTEND_FINAL.md REPOSITORY_STATUS.md SCRIPTS_FIXED.md SCRIPTS_UPDATED.md archived-docs/ 2>/dev/null || true
mv SOLUTION_STATUS.md STARTUP_STATUS.md STRUCTURE_ORGANIZED.md TECHDOCS_FIXED.md archived-docs/ 2>/dev/null || true

# Documentación duplicada
mv ARCHITECTURE.md SETUP.md TROUBLESHOOTING.md COMMANDS_GUIDE.md archived-docs/ 2>/dev/null || true

# Documentación histórica
mv CLI_IMPROVEMENTS.md DOCS_INDEX.md GIT_HISTORY_CLEANED.md QUICK_REFERENCE.md archived-docs/ 2>/dev/null || true
mv REPOSITORIES.md SECURITY_REVIEW.md SERVICE_ORDER.md archived-docs/ 2>/dev/null || true

echo ""
log_success "Organización completada!"
echo ""

# Mostrar resultado
echo "📁 Estructura final:"
echo "  Root:"
ls -1 *.md 2>/dev/null | sed 's/^/    /' || echo "    (sin archivos .md adicionales)"
echo ""
echo "  docs/versions/:"
ls -1 docs/versions/*.md 2>/dev/null | sed 's|docs/versions/||' | sed 's/^/    /' || echo "    (vacío)"
echo ""
echo "  archived-docs/:"
ls -1 archived-docs/*.md 2>/dev/null | sed 's|archived-docs/||' | sed 's/^/    /' || echo "    (vacío)"
echo ""

# Contar archivos
root_md=$(ls -1 *.md 2>/dev/null | wc -l)
versions_md=$(ls -1 docs/versions/*.md 2>/dev/null | wc -l)
archived_md=$(ls -1 archived-docs/*.md 2>/dev/null | wc -l)

echo "📊 Resumen:"
echo "  Root: $root_md archivos"
echo "  Versions: $versions_md archivos"
echo "  Archived: $archived_md archivos"
echo ""
echo "💾 Espacio organizado: $(du -sh archived-docs/ 2>/dev/null | cut -f1 || echo '0K')"
