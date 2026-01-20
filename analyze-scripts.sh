#!/bin/bash

# Análisis de scripts .sh en uso vs obsoletos

echo "=== ANÁLISIS DE SCRIPTS .SH ==="
echo ""

# Scripts principales (en uso activo)
echo "🟢 SCRIPTS PRINCIPALES (EN USO):"
echo "  task-runner.sh              - Sistema dinámico de tareas (NUEVO)"
echo "  start-platform.sh           - Iniciar plataforma"
echo "  stop-platform.sh            - Detener servicios"
echo "  check-prerequisites.sh      - Verificar prerequisitos"
echo "  verify-complete-solution.sh - Estado completo"
echo "  test-github-backstage.sh    - Pruebas conectividad"
echo "  manage-env-configs.sh       - Gestión configuraciones"
echo "  sync-all-repositories.sh    - Sincronizar repos"
echo "  diagnose-backstage.sh       - Diagnóstico Backstage"
echo ""

# Scripts de mantenimiento (uso ocasional)
echo "🟡 SCRIPTS DE MANTENIMIENTO (USO OCASIONAL):"
echo "  restart-all-services.sh     - Reiniciar todos los servicios"
echo "  restart-backstage.sh        - Reiniciar solo Backstage"
echo "  restart-ai-agent.sh         - Reiniciar solo AI Agent"
echo "  restart-postgres.sh         - Reiniciar PostgreSQL"
echo "  fix-backstage-env.sh        - Reparar variables entorno"
echo "  fix-techdocs.sh             - Reparar TechDocs"
echo "  clean-templates-repo.sh     - Limpiar templates"
echo ""

# Scripts obsoletos/duplicados
echo "🔴 SCRIPTS OBSOLETOS/DUPLICADOS (CANDIDATOS A ELIMINAR):"

# Backups de scripts
echo ""
echo "  📁 BACKUPS (.backup):"
ls -1 *.backup 2>/dev/null | sed 's/^/    /'

# Scripts de análisis/generación (ya no necesarios)
echo ""
echo "  📊 ANÁLISIS/GENERACIÓN (obsoletos):"
echo "    analyze-repositories.sh"
echo "    generate-dynamic-catalog.sh"
echo "    generate-release.sh"
echo "    repository-status-final.sh"
echo "    solution-summary.sh"
echo "    solution-complete.sh"
echo "    update-catalog-repo.sh"

# Scripts de fix específicos (ya aplicados)
echo ""
echo "  🔧 FIXES ESPECÍFICOS (ya aplicados):"
echo "    fix-all-scripts.sh"
echo "    fix-all-env-loading.sh"
echo "    fix-backstage-issues.sh"
echo "    fix-complete-solution.sh"
echo "    fix-critical-issues.sh"
echo "    verify-backstage-fixes.sh"

# Scripts de setup/deploy específicos
echo ""
echo "  🚀 SETUP/DEPLOY ESPECÍFICOS (reemplazados por task-runner):"
echo "    deploy-to-github.sh"
echo "    update-repos-and-tag.sh"
echo "    create-backstage-structure.sh"
echo "    start-backstage-with-env.sh"
echo "    start-backstage-fixed.sh"
echo "    start-platform-simple.sh"

# Scripts de monitoreo (funcionalidad integrada)
echo ""
echo "  📊 MONITOREO (funcionalidad integrada):"
echo "    monitor-platform.sh"
echo "    platform-cli"

# Scripts de Docker (externos)
echo ""
echo "  🐳 DOCKER (externos):"
echo "    get-docker.sh"

echo ""
echo "=== RECOMENDACIONES ==="
echo ""
echo "✅ MANTENER (9 scripts principales):"
echo "   - task-runner.sh"
echo "   - start-platform.sh"
echo "   - stop-platform.sh"
echo "   - check-prerequisites.sh"
echo "   - verify-complete-solution.sh"
echo "   - test-github-backstage.sh"
echo "   - manage-env-configs.sh"
echo "   - sync-all-repositories.sh"
echo "   - diagnose-backstage.sh"
echo ""
echo "🟡 REVISAR (7 scripts de mantenimiento):"
echo "   - restart-*.sh (consolidar en task-runner?)"
echo "   - fix-*.sh (mantener solo los necesarios)"
echo ""
echo "❌ ELIMINAR (~21 scripts obsoletos):"
echo "   - Todos los .backup"
echo "   - Scripts de análisis/generación"
echo "   - Scripts de fix ya aplicados"
echo "   - Scripts de setup reemplazados"
echo ""

# Contar archivos
total_scripts=$(ls -1 *.sh 2>/dev/null | wc -l)
backup_scripts=$(ls -1 *.backup 2>/dev/null | wc -l)
active_scripts=9
maintenance_scripts=7
obsolete_scripts=$((total_scripts - active_scripts - maintenance_scripts))

echo "📊 RESUMEN:"
echo "   Total scripts: $total_scripts"
echo "   Activos: $active_scripts"
echo "   Mantenimiento: $maintenance_scripts"
echo "   Obsoletos: $obsolete_scripts"
echo "   Backups: $backup_scripts"
echo ""
echo "💾 Espacio a liberar: ~$(du -ch *.backup 2>/dev/null | tail -1 | cut -f1) en backups"
