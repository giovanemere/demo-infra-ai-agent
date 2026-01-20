#!/bin/bash

# Script para hacer push seguro de repositorios

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

# Función para limpiar archivos sensibles
clean_sensitive_files() {
    local repo_path="$1"
    local repo_name="$2"
    
    log_info "Limpiando archivos sensibles en $repo_name..."
    
    cd "$repo_path"
    
    # Remover archivos .env del tracking si están trackeados
    git rm --cached .env .env.* 2>/dev/null || true
    
    # Asegurar que .env está en .gitignore
    if ! grep -q "^\.env$" .gitignore 2>/dev/null; then
        echo ".env" >> .gitignore
        echo ".env.*" >> .gitignore
        log_info "Agregado .env a .gitignore"
    fi
    
    # Verificar otros archivos sensibles
    local sensitive_files=$(git ls-files | grep -E "\.(key|pem|p12|pfx)$" || true)
    if [[ -n "$sensitive_files" ]]; then
        log_warning "Archivos sensibles encontrados en tracking:"
        echo "$sensitive_files" | sed 's/^/    /'
        echo "$sensitive_files" | xargs git rm --cached 2>/dev/null || true
    fi
}

# Función para hacer push seguro
safe_push() {
    local repo_path="$1"
    local repo_name="$2"
    
    log_info "Preparando push seguro para $repo_name..."
    
    cd "$repo_path"
    
    # Verificar que es un repositorio git
    if [[ ! -d .git ]]; then
        log_error "$repo_name no es un repositorio git"
        return 1
    fi
    
    # Limpiar archivos sensibles
    clean_sensitive_files "$repo_path" "$repo_name"
    
    # Verificar si hay cambios
    if [[ -z "$(git status --porcelain)" ]]; then
        log_info "No hay cambios pendientes en $repo_name"
        return 0
    fi
    
    # Mostrar cambios
    log_info "Cambios a subir en $repo_name:"
    git status --short | sed 's/^/    /'
    
    # Confirmar con usuario
    echo ""
    read -p "¿Continuar con el push de $repo_name? (y/N): " confirm
    
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        log_warning "Push cancelado para $repo_name"
        return 0
    fi
    
    # Hacer commit si hay cambios
    if [[ -n "$(git status --porcelain)" ]]; then
        log_info "Haciendo commit..."
        git add .
        
        # Pedir mensaje de commit
        echo ""
        read -p "Mensaje del commit: " commit_msg
        
        if [[ -z "$commit_msg" ]]; then
            commit_msg="Update $(date +%Y-%m-%d)"
        fi
        
        git commit -m "$commit_msg"
    fi
    
    # Hacer push
    local branch=$(git branch --show-current)
    log_info "Subiendo cambios a origin/$branch..."
    
    git push origin "$branch"
    
    log_success "Push completado para $repo_name"
}

# Función principal
main() {
    local repo_name="$1"
    
    if [[ -z "$repo_name" ]]; then
        log_info "Uso: $0 <repo_name>"
        echo ""
        echo "Repositorios disponibles:"
        echo "  demos           - /home/giovanemere/demos"
        echo "  backstage-idp   - /home/giovanemere/demos/backstage-idp"
        echo "  infra-ai-agent  - /home/giovanemere/demos/infra-ai-agent"
        echo "  catalog-repo    - /home/giovanemere/demos/catalog-repo"
        echo ""
        echo "Ejemplo: $0 backstage-idp"
        exit 1
    fi
    
    # Mapear nombres a rutas
    case "$repo_name" in
        "demos")
            safe_push "/home/giovanemere/demos" "demos"
            ;;
        "backstage-idp")
            safe_push "/home/giovanemere/demos/backstage-idp" "backstage-idp"
            ;;
        "infra-ai-agent")
            safe_push "/home/giovanemere/demos/infra-ai-agent" "infra-ai-agent"
            ;;
        "catalog-repo")
            safe_push "/home/giovanemere/demos/catalog-repo" "catalog-repo"
            ;;
        "all")
            log_info "Procesando todos los repositorios..."
            safe_push "/home/giovanemere/demos" "demos"
            safe_push "/home/giovanemere/demos/backstage-idp" "backstage-idp"
            safe_push "/home/giovanemere/demos/infra-ai-agent" "infra-ai-agent"
            safe_push "/home/giovanemere/demos/catalog-repo" "catalog-repo"
            ;;
        *)
            log_error "Repositorio no reconocido: $repo_name"
            exit 1
            ;;
    esac
}

main "$@"
