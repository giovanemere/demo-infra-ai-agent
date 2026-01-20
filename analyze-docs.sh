#!/bin/bash

# Análisis de archivos .md en root vs docs/

echo "=== ANÁLISIS DE ARCHIVOS .MD ==="
echo ""

# Archivos principales (mantener)
echo "🟢 ARCHIVOS PRINCIPALES (MANTENER):"
echo "  README.md                   - Descripción principal del proyecto"
echo "  SCRIPTS_CLEANUP.md          - Documentación reciente de limpieza"
echo ""

# Archivos de versiones (mantener organizados)
echo "🟡 ARCHIVOS DE VERSIONES (CONSOLIDAR):"
echo "  VERSION_1.0.0.md           - Release notes v1.0.0"
echo "  VERSION_1.1.0.md           - Release notes v1.1.1"
echo "  VERSION_1.2.0.md           - Release notes v1.2.0"
echo ""

# Archivos duplicados/obsoletos
echo "🔴 ARCHIVOS OBSOLETOS/DUPLICADOS:"
echo ""

# Arquitectura y setup (duplicados en docs/ai/)
echo "  📋 DUPLICADOS EN docs/ai/:"
echo "    ARCHITECTURE.md           → docs/ai/architecture.md (más completo)"
echo "    SETUP.md                  → docs/ai/setup.md (más actualizado)"
echo "    TROUBLESHOOTING.md        → docs/ai/troubleshooting.md (más detallado)"
echo "    COMMANDS_GUIDE.md         → docs/ai/comandos.md (más organizado)"

# Status históricos (obsoletos)
echo ""
echo "  📊 STATUS HISTÓRICOS (obsoletos):"
echo "    ALL_SCRIPTS_FIXED.md"
echo "    BACKSTAGE_STRUCTURE.md"
echo "    DEPLOYMENT_STATUS.md"
echo "    FINAL_STATUS.md"
echo "    FRONTEND_FINAL.md"
echo "    REPOSITORY_STATUS.md"
echo "    SCRIPTS_FIXED.md"
echo "    SCRIPTS_UPDATED.md"
echo "    SOLUTION_STATUS.md"
echo "    STARTUP_STATUS.md"
echo "    STRUCTURE_ORGANIZED.md"
echo "    TECHDOCS_FIXED.md"

# Documentación histórica (archivar)
echo ""
echo "  📚 DOCUMENTACIÓN HISTÓRICA:"
echo "    CLI_IMPROVEMENTS.md"
echo "    DOCS_INDEX.md"
echo "    GIT_HISTORY_CLEANED.md"
echo "    QUICK_REFERENCE.md"
echo "    REPOSITORIES.md"
echo "    SECURITY_REVIEW.md"
echo "    SERVICE_ORDER.md"

echo ""
echo "=== COMPARACIÓN CON docs/ai/ ==="
echo ""
echo "📁 Contenido actual en docs/ai/:"
ls -1 docs/ai/*.md | sed 's|docs/ai/||' | sed 's/^/  /'

echo ""
echo "=== RECOMENDACIONES ==="
echo ""
echo "✅ MANTENER EN ROOT (3 archivos):"
echo "   - README.md (principal)"
echo "   - SCRIPTS_CLEANUP.md (reciente)"
echo "   - Crear CHANGELOG.md (consolidar versiones)"
echo ""
echo "📁 MOVER A docs/versions/ (3 archivos):"
echo "   - VERSION_*.md → docs/versions/"
echo ""
echo "📁 MOVER A archived-docs/ (~21 archivos):"
echo "   - Archivos de status históricos"
echo "   - Documentación duplicada"
echo "   - Referencias obsoletas"
echo ""

# Contar archivos
total_md=$(ls -1 *.md 2>/dev/null | wc -l)
keep_md=3
versions_md=3
archive_md=$((total_md - keep_md - versions_md))

echo "📊 RESUMEN:"
echo "   Total archivos .md: $total_md"
echo "   Mantener en root: $keep_md"
echo "   Mover a versions/: $versions_md"
echo "   Archivar: $archive_md"
echo ""
echo "💾 Espacio a liberar: ~$(du -ch *.md 2>/dev/null | tail -1 | cut -f1) → organizado"
