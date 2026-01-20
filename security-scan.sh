#!/bin/bash

# Script para revisar y subir cambios de forma segura

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

# Patrones de datos sensibles
SENSITIVE_PATTERNS=(
    "ghp_[a-zA-Z0-9]{36}"           # GitHub tokens
    "sk-[a-zA-Z0-9]{48}"            # OpenAI API keys
    "AIza[0-9A-Za-z\\-_]{35}"       # Google API keys
    "AKIA[0-9A-Z]{16}"              # AWS Access Keys
    "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}" # UUIDs
    "password.*=.*['\"][^'\"]+['\"]" # Passwords
    "token.*=.*['\"][^'\"]+['\"]"   # Tokens
    "secret.*=.*['\"][^'\"]+['\"]"  # Secrets
)

# Función para escanear datos sensibles
scan_sensitive_data() {
    local repo_path="$1"
    local repo_name="$2"
    
    log_info "Escaneando datos sensibles en $repo_name..."
    
    local found_issues=0
    
    # Escanear archivos trackeados y no trackeados
    cd "$repo_path"
    
    # Archivos a revisar (excluir .git y node_modules)
    local files=$(find . -type f \( -name "*.sh" -o -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.yaml" -o -name "*.yml" -o -name "*.json" -o -name "*.md" -o -name ".env*" \) ! -path "./.git/*" ! -path "./node_modules/*" ! -path "./archived-*/*")
    
    for pattern in "${SENSITIVE_PATTERNS[@]}"; do
        local matches=$(echo "$files" | xargs grep -l -E "$pattern" 2>/dev/null || true)
        if [[ -n "$matches" ]]; then
            log_error "Datos sensibles encontrados en $repo_name:"
            echo "$matches" | sed 's/^/    /'
            ((found_issues++))
        fi
    done
    
    # Verificar archivos .env
    if ls .env* >/dev/null 2>&1; then
        log_warning "Archivos .env encontrados en $repo_name:"
        ls -la .env* | sed 's/^/    /'
        ((found_issues++))
    fi
    
    if [[ $found_issues -eq 0 ]]; then
        log_success "No se encontraron datos sensibles en $repo_name"
    fi
    
    return $found_issues
}

# Función para verificar .gitignore
check_gitignore() {
    local repo_path="$1"
    local repo_name="$2"
    
    log_info "Verificando .gitignore en $repo_name..."
    
    cd "$repo_path"
    
    if [[ ! -f .gitignore ]]; then
        log_warning "No existe .gitignore en $repo_name"
        return 1
    fi
    
    # Patrones requeridos en .gitignore
    local required_patterns=(
        "\.env"
        "\.env\."
        "\*\.log"
        "node_modules"
        "__pycache__"
        "\*\.key"
        "\*\.pem"
    )
    
    local missing_patterns=()
    for pattern in "${required_patterns[@]}"; do
        if ! grep -q "$pattern" .gitignore; then
            missing_patterns+=("$pattern")
        fi
    done
    
    if [[ ${#missing_patterns[@]} -gt 0 ]]; then
        log_warning "Patrones faltantes en .gitignore de $repo_name:"
        printf '    %s\n' "${missing_patterns[@]}"
        return 1
    fi
    
    log_success ".gitignore correcto en $repo_name"
    return 0
}

# Función para mostrar estado del repositorio
show_repo_status() {
    local repo_path="$1"
    local repo_name="$2"
    
    log_info "Estado de $repo_name:"
    
    cd "$repo_path"
    
    # Verificar si es un repositorio git
    if [[ ! -d .git ]]; then
        log_error "$repo_name no es un repositorio git"
        return 1
    fi
    
    # Mostrar remote
    local remote=$(git remote get-url origin 2>/dev/null || echo "Sin remote")
    echo "    Remote: $remote"
    
    # Mostrar rama actual
    local branch=$(git branch --show-current 2>/dev/null || echo "Sin rama")
    echo "    Rama: $branch"
    
    # Mostrar archivos modificados
    local modified=$(git status --porcelain | wc -l)
    echo "    Archivos modificados: $modified"
    
    if [[ $modified -gt 0 ]]; then
        echo "    Cambios pendientes:"
        git status --short | sed 's/^/      /'
    fi
    
    return 0
}

# Función principal
main() {
    log_info "Revisión de seguridad para repositorios"
    echo ""
    
    # Lista de repositorios a revisar
    local repos=(
        "/home/giovanemere/demos:demos"
        "/home/giovanemere/demos/backstage-idp:backstage-idp"
        "/home/giovanemere/demos/infra-ai-agent:infra-ai-agent"
        "/home/giovanemere/demos/catalog-repo:catalog-repo"
    )
    
    local total_issues=0
    
    for repo_info in "${repos[@]}"; do
        local repo_path="${repo_info%:*}"
        local repo_name="${repo_info#*:}"
        
        if [[ ! -d "$repo_path" ]]; then
            log_warning "Repositorio no encontrado: $repo_path"
            continue
        fi
        
        echo ""
        echo "=================================="
        log_info "Revisando repositorio: $repo_name"
        echo "=================================="
        
        # Mostrar estado
        show_repo_status "$repo_path" "$repo_name"
        
        echo ""
        
        # Verificar .gitignore
        check_gitignore "$repo_path" "$repo_name"
        gitignore_status=$?
        
        echo ""
        
        # Escanear datos sensibles
        scan_sensitive_data "$repo_path" "$repo_name"
        sensitive_status=$?
        
        if [[ $gitignore_status -ne 0 || $sensitive_status -ne 0 ]]; then
            ((total_issues++))
        fi
        
        echo ""
    done
    
    echo "=================================="
    if [[ $total_issues -eq 0 ]]; then
        log_success "Todos los repositorios están seguros para subir cambios"
        echo ""
        log_info "Para subir cambios usa:"
        echo "  ./safe-push.sh <repo_name>"
        echo "  Ejemplo: ./safe-push.sh backstage-idp"
    else
        log_error "Se encontraron $total_issues repositorios con problemas"
        log_warning "Corrige los problemas antes de subir cambios"
    fi
}

main "$@"
