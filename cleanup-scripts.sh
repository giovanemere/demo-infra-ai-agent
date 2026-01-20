#!/bin/bash

# Script para limpiar archivos .sh obsoletos de forma segura

set -e

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# Crear directorio de archivo
ARCHIVE_DIR="archived-scripts"
mkdir -p "$ARCHIVE_DIR"

# Scripts a mantener (NUNCA eliminar)
KEEP_SCRIPTS=(
    "task-runner.sh"
    "start-platform.sh"
    "stop-platform.sh"
    "check-prerequisites.sh"
    "verify-complete-solution.sh"
    "test-github-backstage.sh"
    "manage-env-configs.sh"
    "sync-all-repositories.sh"
    "diagnose-backstage.sh"
    "analyze-scripts.sh"
    "cleanup-scripts.sh"
)

# Scripts de mantenimiento (revisar antes de eliminar)
MAINTENANCE_SCRIPTS=(
    "restart-all-services.sh"
    "restart-backstage.sh"
    "restart-ai-agent.sh"
    "restart-postgres.sh"
    "fix-backstage-env.sh"
    "fix-techdocs.sh"
    "clean-templates-repo.sh"
)

# Función para verificar si un script debe mantenerse
should_keep() {
    local script="$1"
    for keep in "${KEEP_SCRIPTS[@]}"; do
        if [[ "$script" == "$keep" ]]; then
            return 0
        fi
    done
    return 1
}

# Función para verificar si es script de mantenimiento
is_maintenance() {
    local script="$1"
    for maint in "${MAINTENANCE_SCRIPTS[@]}"; do
        if [[ "$script" == "$maint" ]]; then
            return 0
        fi
    done
    return 1
}

# Función principal de limpieza
cleanup_scripts() {
    local mode="$1"
    
    log_info "Iniciando limpieza de scripts obsoletos..."
    log_info "Modo: $mode"
    echo ""
    
    # Contar archivos
    local moved=0
    local kept=0
    local maintenance=0
    
    # Procesar archivos .sh
    for file in *.sh; do
        # Saltar si no existe
        [[ ! -f "$file" ]] && continue
        
        # Saltar el script actual
        [[ "$file" == "cleanup-scripts.sh" ]] && continue
        [[ "$file" == "analyze-scripts.sh" ]] && continue
        
        if should_keep "$file"; then
            log_success "MANTENER: $file"
            ((kept++))
        elif is_maintenance "$file"; then
            if [[ "$mode" == "aggressive" ]]; then
                log_warning "ARCHIVAR (mantenimiento): $file"
                mv "$file" "$ARCHIVE_DIR/"
                ((moved++))
            else
                log_warning "REVISAR (mantenimiento): $file"
                ((maintenance++))
            fi
        else
            # Archivar script obsoleto
            log_info "ARCHIVAR (obsoleto): $file"
            mv "$file" "$ARCHIVE_DIR/"
            ((moved++))
        fi
    done
    
    # Procesar archivos .backup
    for file in *.backup; do
        # Saltar si no existe (glob no expandido)
        [[ ! -f "$file" ]] && continue
        
        # Todos los .backup son obsoletos
        log_info "ARCHIVAR (backup): $file"
        mv "$file" "$ARCHIVE_DIR/"
        ((moved++))
    done
    
    echo ""
    log_success "Limpieza completada:"
    echo "  📁 Archivados: $moved"
    echo "  ✅ Mantenidos: $kept"
    echo "  🟡 Mantenimiento: $maintenance"
    echo ""
    
    if [[ $maintenance -gt 0 && "$mode" != "aggressive" ]]; then
        log_warning "Scripts de mantenimiento encontrados."
        log_info "Usa 'cleanup-scripts.sh aggressive' para archivarlos también."
    fi
    
    # Mostrar contenido del archivo
    if [[ $moved -gt 0 ]]; then
        echo ""
        log_info "Archivos movidos a $ARCHIVE_DIR/:"
        ls -la "$ARCHIVE_DIR/" | tail -n +2
    fi
}

# Función para restaurar archivos
restore_scripts() {
    log_info "Restaurando scripts desde $ARCHIVE_DIR/..."
    
    if [[ ! -d "$ARCHIVE_DIR" ]]; then
        log_error "Directorio de archivo no encontrado"
        exit 1
    fi
    
    local restored=0
    for file in "$ARCHIVE_DIR"/*; do
        [[ ! -f "$file" ]] && continue
        
        local basename=$(basename "$file")
        log_info "Restaurando: $basename"
        mv "$file" "./$(basename "$file")"
        ((restored++))
    done
    
    log_success "Restaurados $restored archivos"
    
    # Eliminar directorio si está vacío
    rmdir "$ARCHIVE_DIR" 2>/dev/null && log_info "Directorio de archivo eliminado"
}

# Función para mostrar ayuda
show_help() {
    echo "Limpieza de Scripts Obsoletos - Infrastructure AI Platform"
    echo ""
    echo "Uso: $0 [comando]"
    echo ""
    echo "Comandos:"
    echo "  clean      - Limpiar scripts obsoletos (mantener scripts de mantenimiento)"
    echo "  aggressive - Limpiar todo incluyendo scripts de mantenimiento"
    echo "  restore    - Restaurar todos los scripts archivados"
    echo "  list       - Mostrar qué se haría sin ejecutar"
    echo "  help       - Mostrar esta ayuda"
    echo ""
    echo "Los scripts se mueven a '$ARCHIVE_DIR/' en lugar de eliminarse."
}

# Función para listar sin ejecutar
list_actions() {
    log_info "Vista previa de acciones (sin ejecutar):"
    echo ""
    
    # Procesar archivos .sh
    for file in *.sh; do
        [[ ! -f "$file" ]] && continue
        [[ "$file" == "cleanup-scripts.sh" ]] && continue
        [[ "$file" == "analyze-scripts.sh" ]] && continue
        
        if should_keep "$file"; then
            echo "  ✅ MANTENER: $file"
        elif is_maintenance "$file"; then
            echo "  🟡 MANTENIMIENTO: $file"
        else
            echo "  📁 ARCHIVAR: $file"
        fi
    done
    
    # Procesar archivos .backup
    for file in *.backup; do
        [[ ! -f "$file" ]] && continue
        echo "  📁 ARCHIVAR: $file"
    done
}

# Función principal
main() {
    case "${1:-help}" in
        "clean")
            cleanup_scripts "normal"
            ;;
        "aggressive")
            cleanup_scripts "aggressive"
            ;;
        "restore")
            restore_scripts
            ;;
        "list")
            list_actions
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

main "$@"
