#!/bin/bash

# =============================================================================
# Infrastructure AI Platform - Inicio Completo
# =============================================================================

set -e

echo "🚀 Iniciando Infrastructure AI Platform..."

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }

# Verificar directorios
if [ ! -d "infra-ai-agent" ] || [ ! -d "backstage-idp" ]; then
    echo "❌ Directorios del proyecto no encontrados"
    echo "Ejecuta este script desde /home/giovanemere/demos/"
    exit 1
fi

# Función para iniciar AI Agent
start_ai_agent() {
    log_info "Iniciando AI Agent..."
    cd infra-ai-agent
    
    if [ ! -f ".env" ]; then
        log_warning "Archivo .env no encontrado en AI Agent"
        return 1
    fi
    
    # Verificar GEMINI_API_KEY
    if ! grep -q "AIzaSy" .env; then
        log_warning "GEMINI_API_KEY no configurado correctamente"
        return 1
    fi
    
    # Iniciar AI Agent
    cd infra-ai-agent/agent
    source ../venv/bin/activate
    nohup python main.py > ../ai-agent.log 2>&1 &
    AI_PID=$!
    echo $AI_PID > ../ai-agent.pid
    cd ../..
    
    log_success "AI Agent iniciado (PID: $AI_PID)"
    cd ..
}

# Función para iniciar Backstage
start_backstage() {
    log_info "Iniciando Backstage IDP..."
    
    # Verificar PostgreSQL primero
    if ! nc -z localhost 5432; then
        log_warning "PostgreSQL no está ejecutándose. Iniciando..."
        cd /home/giovanemere/docker/postgres
        ./start-postgres.sh
        sleep 5
        cd /home/giovanemere/demos
    fi
    
    cd backstage-idp/infra-ai-backstage
    
    if [ ! -f ".env" ]; then
        log_warning "Variables de entorno no configuradas en Backstage"
        return 1
    fi
    
    # Detener procesos existentes
    pkill -f "backstage-cli" 2>/dev/null || true
    pkill -f "yarn start" 2>/dev/null || true
    sleep 2
    
    # Cargar variables de entorno correctamente
    set -a
    source .env
    set +a
    
    # Iniciar en background
    nohup yarn start > backstage.log 2>&1 &
    BS_PID=$!
    echo $BS_PID > ../../backstage.pid
    
    log_success "Backstage iniciado (PID: $BS_PID)"
    cd ../..
}

# Función para verificar servicios
check_services() {
    log_info "Verificando servicios..."
    
    # Esperar un momento para que inicien
    sleep 10
    
    # Verificar AI Agent
    if curl -s http://localhost:8000/health > /dev/null; then
        log_success "AI Agent funcionando en :8000"
    else
        log_warning "AI Agent no responde en :8000"
    fi
    
    # Verificar Backstage
    if curl -s http://localhost:3000 > /dev/null; then
        log_success "Backstage UI funcionando en :3000"
    else
        log_warning "Backstage UI no responde en :3000"
    fi
    
    if curl -s http://localhost:7007 > /dev/null; then
        log_success "Backstage API funcionando en :7007"
    else
        log_warning "Backstage API no responde en :7007"
    fi
    
    # Verificar PostgreSQL
    if nc -z localhost 5432; then
        log_success "PostgreSQL funcionando en :5432"
    else
        log_warning "PostgreSQL no responde en :5432"
    fi
}

# Función para mostrar información
show_info() {
    echo ""
    echo "🎉 Infrastructure AI Platform iniciada!"
    echo ""
    echo "🌐 URLs disponibles:"
    echo "  🤖 AI Agent API:    http://localhost:8000"
    echo "  📚 AI Agent Docs:   http://localhost:8000/docs"
    echo "  🎭 Backstage UI:    http://localhost:3000"
    echo "  🔧 Backstage API:   http://localhost:7007"
    echo "  🐘 PostgreSQL:      localhost:5432"
    echo ""
    echo "🧪 Prueba rápida:"
    echo "  curl -X POST \"http://localhost:8000/process-text\" \\"
    echo "    -F \"description=Una app web con S3, CloudFront y Lambda\""
    echo ""
    echo "🛑 Para detener la plataforma:"
    echo "  ./stop-platform.sh"
    echo ""
}

# Función para crear script de parada
create_stop_script() {
    cat > stop-platform.sh << 'EOF'
#!/bin/bash
echo "🛑 Deteniendo Infrastructure AI Platform..."

# Detener AI Agent
if [ -f "ai-agent.pid" ]; then
    AI_PID=$(cat ai-agent.pid)
    kill $AI_PID 2>/dev/null && echo "✅ AI Agent detenido"
    rm ai-agent.pid
fi

# Detener Backstage
if [ -f "backstage.pid" ]; then
    BS_PID=$(cat backstage.pid)
    kill $BS_PID 2>/dev/null && echo "✅ Backstage detenido"
    rm backstage.pid
fi

# Limpiar puertos si es necesario
pkill -f "uvicorn.*8000" 2>/dev/null
pkill -f "yarn.*dev" 2>/dev/null

echo "🏁 Plataforma detenida"
EOF
    chmod +x stop-platform.sh
}

# Función principal
main() {
    echo "🏗️ Infrastructure AI Platform Launcher"
    echo "======================================"
    echo ""
    
    # Crear script de parada
    create_stop_script
    
    # Iniciar servicios
    if start_ai_agent; then
        sleep 5
        if start_backstage; then
            check_services
            show_info
        else
            log_warning "Backstage no pudo iniciarse, pero AI Agent está funcionando"
            show_info
        fi
    else
        log_warning "AI Agent no pudo iniciarse. Verifica la configuración."
        exit 1
    fi
}

# Ejecutar función principal
main "$@"
