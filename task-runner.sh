#!/bin/bash

# =============================================================================
# Sistema Dinámico de Tareas - Infrastructure AI Platform
# =============================================================================

set -e

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }
log_task() { echo -e "${CYAN}🔧 $1${NC}"; }

# Auto-load environment variables
load_env() {
    if [ -f ".env" ]; then
        source .env
    elif [ -f "backstage-idp/infra-ai-backstage/.env" ]; then
        source backstage-idp/infra-ai-backstage/.env
    fi
}

# Tareas disponibles
declare -A TASKS=(
    ["check"]="Verificar prerequisitos del sistema"
    ["status"]="Estado completo del proyecto"
    ["start"]="Iniciar toda la plataforma"
    ["stop"]="Detener todos los servicios"
    ["test"]="Probar conectividad GitHub-Backstage"
    ["backup"]="Backup de configuraciones"
    ["sync"]="Sincronizar repositorios"
    ["diagnose"]="Diagnosticar problemas"
    ["env"]="Gestionar variables de entorno"
    ["commit"]="Commit cambios en repositorio actual"
    ["push"]="Push cambios a repositorio remoto"
    ["tag"]="Crear y subir nuevo tag de versión"
    ["deploy"]="Deploy completo (commit + tag + push)"
    ["pull"]="Pull cambios de todos los repositorios"
)

# Ejecutar tarea
run_task() {
    local task=$1
    log_task "Ejecutando tarea: $task"
    
    case $task in
        "check")
            ./check-prerequisites.sh
            ;;
        "status")
            ./verify-complete-solution.sh
            ;;
        "start")
            ./start-platform.sh
            ;;
        "stop")
            ./stop-platform.sh
            ;;
        "test")
            ./test-github-backstage.sh
            ;;
        "backup")
            ./manage-env-configs.sh backup
            cd backstage-idp && ./manage-config.sh backup
            ;;
        "sync")
            ./sync-all-repositories.sh
            ;;
        "diagnose")
            ./diagnose-backstage.sh
            cd backstage-idp && ./scripts/system-check.sh
            ;;
        "env")
            ./manage-env-configs.sh validate
            ;;
        "commit")
            git_commit
            ;;
        "push")
            git_push
            ;;
        "tag")
            git_tag "$2"
            ;;
        "deploy")
            git_deploy "$2"
            ;;
        "pull")
            git_pull_all
            ;;
        *)
            log_error "Tarea no reconocida: $task"
            show_help
            exit 1
            ;;
    esac
}

# Funciones Git
git_commit() {
    log_task "Preparando commit..."
    
    # Mostrar estado
    git status --short
    
    # Pedir mensaje de commit
    echo ""
    read -p "Mensaje del commit: " commit_msg
    
    if [ -z "$commit_msg" ]; then
        log_error "Mensaje de commit requerido"
        exit 1
    fi
    
    git add .
    git commit -m "$commit_msg"
    log_success "Commit creado: $commit_msg"
}

git_push() {
    log_task "Subiendo cambios..."
    
    git push origin $(git branch --show-current)
    log_success "Cambios subidos a GitHub"
}

git_tag() {
    local version=$1
    
    if [ -z "$version" ]; then
        echo ""
        read -p "Versión del tag (ej: v1.3.0): " version
    fi
    
    if [ -z "$version" ]; then
        log_error "Versión requerida"
        exit 1
    fi
    
    log_task "Creando tag $version..."
    
    git tag -a "$version" -m "Infrastructure AI Platform $version"
    git push origin "$version"
    log_success "Tag $version creado y subido"
}

git_deploy() {
    local version=$1
    
    log_task "Deploy completo..."
    
    # Commit
    git_commit
    
    # Tag si se especifica versión
    if [ -n "$version" ]; then
        git_tag "$version"
    fi
    
    # Push
    git_push
    
    log_success "Deploy completo finalizado"
}

git_pull_all() {
    log_task "Actualizando todos los repositorios..."
    
    # Repo principal
    log_info "Actualizando demos..."
    git pull origin $(git branch --show-current)
    
    # Backstage IDP
    if [ -d "backstage-idp" ]; then
        log_info "Actualizando backstage-idp..."
        cd backstage-idp
        git pull origin $(git branch --show-current) 2>/dev/null || log_warning "No se pudo actualizar backstage-idp"
        cd ..
    fi
    
    # Infra AI Agent
    if [ -d "infra-ai-agent" ]; then
        log_info "Actualizando infra-ai-agent..."
        cd infra-ai-agent
        git pull origin $(git branch --show-current) 2>/dev/null || log_warning "No se pudo actualizar infra-ai-agent"
        cd ..
    fi
    
    # Catalog repo
    if [ -d "catalog-repo" ]; then
        log_info "Actualizando catalog-repo..."
        cd catalog-repo
        git pull origin $(git branch --show-current) 2>/dev/null || log_warning "No se pudo actualizar catalog-repo"
        cd ..
    fi
    
    log_success "Todos los repositorios actualizados"
}

# Mostrar ayuda
show_help() {
    echo ""
    log_info "Sistema Dinámico de Tareas - Infrastructure AI Platform"
    echo ""
    echo "Uso: $0 <tarea> [opciones]"
    echo ""
    echo "Tareas disponibles:"
    for task in "${!TASKS[@]}"; do
        printf "  %-12s %s\n" "$task" "${TASKS[$task]}"
    done
    echo ""
    echo "Ejemplos:"
    echo "  $0 check           # Verificar prerequisitos"
    echo "  $0 status          # Ver estado completo"
    echo "  $0 start           # Iniciar plataforma"
    echo "  $0 commit          # Hacer commit interactivo"
    echo "  $0 push            # Subir cambios"
    echo "  $0 tag v1.3.0      # Crear tag de versión"
    echo "  $0 deploy v1.3.0   # Deploy completo con versión"
    echo ""
}

# Función principal
main() {
    load_env
    
    if [ $# -eq 0 ]; then
        show_help
        exit 1
    fi
    
    local task=$1
    
    if [[ -n "${TASKS[$task]}" ]]; then
        run_task "$task"
    else
        log_error "Tarea no válida: $task"
        show_help
        exit 1
    fi
}

main "$@"
