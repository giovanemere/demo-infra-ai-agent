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
    ["quick"]="Estado rápido de servicios"
    ["start"]="Iniciar toda la plataforma"
    ["stop"]="Detener todos los servicios"
    ["restart-backstage"]="Reiniciar solo Backstage"
    ["stop-backstage"]="Detener solo Backstage"
    ["start-backstage"]="Iniciar solo Backstage"
    ["restart-ai"]="Reiniciar solo AI Agent"
    ["stop-ai"]="Detener solo AI Agent"
    ["start-ai"]="Iniciar solo AI Agent"
    ["restart-minio"]="Reiniciar solo MinIO"
    ["stop-minio-local"]="Detener solo MinIO local"
    ["start-minio-local"]="Iniciar solo MinIO local"
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
    ["start-minio"]="Iniciar MinIO para almacenamiento distribuido"
    ["stop-minio"]="Detener MinIO"
    ["test-minio"]="Probar funcionalidad de MinIO"
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
        "quick")
            ./quick-status.sh
            ;;
        "start")
            ./start-platform.sh
            ;;
        "stop")
            ./stop-platform.sh
            ;;
        "restart-backstage")
            restart_backstage
            ;;
        "stop-backstage")
            stop_backstage
            ;;
        "start-backstage")
            start_backstage
            ;;
        "restart-ai")
            restart_ai_agent
            ;;
        "stop-ai")
            stop_ai_agent
            ;;
        "start-ai")
            start_ai_agent
            ;;
        "restart-minio")
            restart_minio_local
            ;;
        "stop-minio-local")
            stop_minio_local
            ;;
        "start-minio-local")
            start_minio_local
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
        "start-minio")
            minio_start
            ;;
        "stop-minio")
            minio_stop
            ;;
        "test-minio")
            minio_test
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

# Funciones de MinIO
minio_start() {
    log_task "Iniciando MinIO para almacenamiento distribuido..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker no está instalado"
        return 1
    fi
    
    cd /home/giovanemere/docker/minio
    ./start-minio.sh
    
    log_success "MinIO iniciado correctamente"
    log_info "Console: http://localhost:9001 (backstage/backstage123)"
    log_info "API: http://localhost:9000"
}

minio_stop() {
    log_task "Deteniendo MinIO..."
    
    cd /home/giovanemere/docker/minio
    ./stop-minio.sh
    
    log_success "MinIO detenido"
}

minio_test() {
    log_task "Probando funcionalidad de MinIO..."
    
    cd /home/giovanemere/demos/infra-ai-agent
    source venv/bin/activate
    python3 test_minio.py
    
    if [ $? -eq 0 ]; then
        log_success "MinIO funcionando correctamente"
    else
        log_error "MinIO tiene problemas"
        return 1
    fi
}

# Funciones específicas para gestión de Backstage
restart_backstage() {
    log_task "Reiniciando Backstage..."
    
    # Detener Backstage
    if [ -f "backstage.pid" ]; then
        local pid=$(cat backstage.pid)
        if kill -0 "$pid" 2>/dev/null; then
            log_info "Deteniendo Backstage (PID: $pid)..."
            kill "$pid" 2>/dev/null
            sleep 3
            if kill -0 "$pid" 2>/dev/null; then
                kill -9 "$pid" 2>/dev/null
            fi
        fi
        rm -f backstage.pid
    fi
    
    # Cleanup procesos
    pkill -f "yarn.*start" 2>/dev/null || true
    pkill -f "backstage-cli" 2>/dev/null || true
    
    # Verificar puerto libre
    for i in {1..10}; do
        if ! ss -tln | grep -q ":3000 "; then
            break
        fi
        log_info "Esperando que se libere el puerto 3000..."
        sleep 2
    done
    
    if ss -tln | grep -q ":3000 "; then
        log_error "No se pudo liberar el puerto 3000"
        return 1
    fi
    
    # Iniciar Backstage
    cd backstage-idp/infra-ai-backstage
    
    # Limpiar cache
    rm -rf dist-types/ dist/ .cache/ 2>/dev/null || true
    
    log_info "Iniciando Backstage..."
    nohup yarn start > ../../backstage.log 2>&1 &
    local new_pid=$!
    echo $new_pid > ../../backstage.pid
    
    cd ../..
    
    # Verificar inicio
    log_info "Esperando que Backstage inicie..."
    for i in {1..24}; do
        if curl -s --connect-timeout 5 http://localhost:3000 > /dev/null 2>&1; then
            log_success "Backstage reiniciado correctamente (PID: $new_pid)"
            log_info "URL: http://localhost:3000"
            return 0
        fi
        
        if ! kill -0 "$new_pid" 2>/dev/null; then
            log_error "Proceso de Backstage terminó inesperadamente"
            log_info "Últimas líneas del log:"
            tail -10 backstage.log
            return 1
        fi
        
        echo -n "."
        sleep 5
    done
    
    echo ""
    log_warning "Backstage no responde después de 2 minutos"
    log_info "Revisa los logs: tail -f backstage.log"
    return 1
}

stop_backstage() {
    log_task "Deteniendo solo Backstage..."
    if [ -f "backstage.pid" ]; then
        local pid=$(cat backstage.pid)
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid" 2>/dev/null && log_success "Backstage detenido"
            sleep 2
        fi
        rm -f backstage.pid
    fi
    pkill -f "yarn.*start" 2>/dev/null || true
    pkill -f "backstage-cli" 2>/dev/null || true
}

start_backstage() {
    log_task "Iniciando solo Backstage..."
    
    # Verificar que PostgreSQL esté corriendo
    if ! ss -tln | grep -q ":5432 "; then
        log_error "PostgreSQL no está corriendo. Inicia la plataforma completa primero."
        return 1
    fi
    
    # Verificar puerto libre
    if ss -tln | grep -q ":3000 "; then
        log_error "Puerto 3000 ocupado. Usa 'restart-backstage' en su lugar."
        return 1
    fi
    
    cd backstage-idp/infra-ai-backstage
    rm -rf dist-types/ dist/ .cache/ 2>/dev/null || true
    
    nohup yarn start > ../../backstage.log 2>&1 &
    local pid=$!
    echo $pid > ../../backstage.pid
    log_success "Backstage iniciado (PID: $pid)"
    cd ../..
}

# Funciones específicas para AI Agent
restart_ai_agent() {
    log_task "Reiniciando AI Agent..."
    
    # Detener AI Agent
    if [ -f "infra-ai-agent/ai-agent.pid" ]; then
        local pid=$(cat infra-ai-agent/ai-agent.pid)
        if kill -0 "$pid" 2>/dev/null; then
            log_info "Deteniendo AI Agent (PID: $pid)..."
            kill "$pid" 2>/dev/null
            sleep 3
            if kill -0 "$pid" 2>/dev/null; then
                kill -9 "$pid" 2>/dev/null
            fi
        fi
        rm -f infra-ai-agent/ai-agent.pid
    fi
    
    # Cleanup procesos
    pkill -f "uvicorn.*8000" 2>/dev/null || true
    pkill -f "python.*main.py" 2>/dev/null || true
    
    # Verificar puerto libre
    for i in {1..10}; do
        if ! ss -tln | grep -q ":8000 "; then
            break
        fi
        log_info "Esperando que se libere el puerto 8000..."
        sleep 2
    done
    
    if ss -tln | grep -q ":8000 "; then
        log_error "No se pudo liberar el puerto 8000"
        return 1
    fi
    
    # Iniciar AI Agent
    cd infra-ai-agent
    
    # Verificar entorno virtual
    if [ ! -d "venv" ]; then
        log_info "Creando entorno virtual..."
        python3 -m venv venv
        source venv/bin/activate
        pip install -r requirements.txt
    else
        source venv/bin/activate
    fi
    
    cd agent
    log_info "Iniciando AI Agent..."
    nohup python main.py > ../ai-agent.log 2>&1 &
    local new_pid=$!
    echo $new_pid > ../ai-agent.pid
    
    cd ../..
    
    # Verificar inicio
    log_info "Esperando que AI Agent inicie..."
    for i in {1..12}; do
        if curl -s --connect-timeout 5 http://localhost:8000/health > /dev/null 2>&1; then
            log_success "AI Agent reiniciado correctamente (PID: $new_pid)"
            log_info "URL: http://localhost:8000"
            return 0
        fi
        
        if ! kill -0 "$new_pid" 2>/dev/null; then
            log_error "Proceso de AI Agent terminó inesperadamente"
            log_info "Últimas líneas del log:"
            tail -10 infra-ai-agent/ai-agent.log
            return 1
        fi
        
        echo -n "."
        sleep 5
    done
    
    echo ""
    log_warning "AI Agent no responde después de 1 minuto"
    log_info "Revisa los logs: tail -f infra-ai-agent/ai-agent.log"
    return 1
}

stop_ai_agent() {
    log_task "Deteniendo solo AI Agent..."
    if [ -f "infra-ai-agent/ai-agent.pid" ]; then
        local pid=$(cat infra-ai-agent/ai-agent.pid)
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid" 2>/dev/null && log_success "AI Agent detenido"
            sleep 2
        fi
        rm -f infra-ai-agent/ai-agent.pid
    fi
    pkill -f "uvicorn.*8000" 2>/dev/null || true
    pkill -f "python.*main.py" 2>/dev/null || true
}

start_ai_agent() {
    log_task "Iniciando solo AI Agent..."
    
    # Verificar puerto libre
    if ss -tln | grep -q ":8000 "; then
        log_error "Puerto 8000 ocupado. Usa 'restart-ai' en su lugar."
        return 1
    fi
    
    cd infra-ai-agent
    
    if [ ! -d "venv" ]; then
        python3 -m venv venv
        source venv/bin/activate
        pip install -r requirements.txt
    else
        source venv/bin/activate
    fi
    
    cd agent
    nohup python main.py > ../ai-agent.log 2>&1 &
    local pid=$!
    echo $pid > ../ai-agent.pid
    log_success "AI Agent iniciado (PID: $pid)"
    cd ../..
}

# Funciones específicas para MinIO local
restart_minio_local() {
    log_task "Reiniciando MinIO..."
    
    # Detener contenedor Docker si existe
    if docker ps -a -q -f name=backstage-minio | grep -q .; then
        log_info "Deteniendo contenedor MinIO..."
        docker stop backstage-minio >/dev/null 2>&1 || true
        docker rm backstage-minio >/dev/null 2>&1 || true
    fi
    
    # Detener MinIO local si existe
    if [ -f "minio.pid" ]; then
        local pid=$(cat minio.pid)
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid" 2>/dev/null
        fi
        rm -f minio.pid
    fi
    
    # Cleanup procesos
    pkill -f "minio.*server" 2>/dev/null || true
    sudo pkill -f "minio.*server" 2>/dev/null || true
    
    # Verificar puerto libre
    for i in {1..10}; do
        if ! ss -tln | grep -q ":9000 "; then
            break
        fi
        log_info "Esperando que se libere el puerto 9000..."
        sleep 2
    done
    
    if ss -tln | grep -q ":9000 "; then
        log_error "No se pudo liberar el puerto 9000"
        return 1
    fi
    
    # Iniciar MinIO con Docker
    log_info "Iniciando MinIO con Docker..."
    docker run -d --name backstage-minio \
        -p 9000:9000 -p 9001:9001 \
        -e MINIO_ROOT_USER=backstage \
        -e MINIO_ROOT_PASSWORD=backstage123 \
        -v /tmp/minio-data:/data \
        minio/minio:latest server /data --console-address ":9001" > minio.log 2>&1
    
    # Verificar inicio
    log_info "Esperando que MinIO inicie..."
    for i in {1..12}; do
        if curl -s --connect-timeout 5 http://localhost:9000/minio/health/live > /dev/null 2>&1; then
            log_success "MinIO reiniciado correctamente"
            log_info "Console: http://localhost:9001 (backstage/backstage123)"
            return 0
        fi
        
        echo -n "."
        sleep 3
    done
    
    echo ""
    log_warning "MinIO no responde después de 40 segundos"
    log_info "Revisa los logs: docker logs backstage-minio"
    return 1
}

stop_minio_local() {
    log_task "Deteniendo MinIO..."
    
    # Detener contenedor Docker
    if docker ps -q -f name=backstage-minio | grep -q .; then
        docker stop backstage-minio >/dev/null 2>&1 && log_success "MinIO Docker detenido"
        docker rm backstage-minio >/dev/null 2>&1
    fi
    
    # Detener MinIO local
    if [ -f "minio.pid" ]; then
        local pid=$(cat minio.pid)
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid" 2>/dev/null && log_success "MinIO local detenido"
        fi
        rm -f minio.pid
    fi
    
    pkill -f "minio.*server" 2>/dev/null || true
    sudo pkill -f "minio.*server" 2>/dev/null || true
}

start_minio_local() {
    log_task "Iniciando MinIO..."
    
    # Verificar puerto libre
    if ss -tln | grep -q ":9000 "; then
        log_error "Puerto 9000 ocupado. Usa 'restart-minio' en su lugar."
        return 1
    fi
    
    # Iniciar con Docker
    docker run -d --name backstage-minio \
        -p 9000:9000 -p 9001:9001 \
        -e MINIO_ROOT_USER=backstage \
        -e MINIO_ROOT_PASSWORD=backstage123 \
        -v /tmp/minio-data:/data \
        minio/minio:latest server /data --console-address ":9001" >/dev/null 2>&1
    
    log_success "MinIO iniciado con Docker"
    log_info "Console: http://localhost:9001 (backstage/backstage123)"
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
