#!/bin/bash

# =============================================================================
# Infrastructure AI Platform - Inicio Completo con MinIO y PostgreSQL
# =============================================================================

set -e

echo "🚀 Iniciando Infrastructure AI Platform..."

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# Verificar directorios
if [ ! -d "infra-ai-agent" ] || [ ! -d "backstage-idp" ]; then
    log_error "Directorios del proyecto no encontrados"
    echo "Ejecuta este script desde /home/giovanemere/demos/"
    exit 1
fi

# Función para detener servicios de forma segura
stop_service() {
    local service_name=$1
    local pattern=$2
    local port=$3
    
    log_info "Deteniendo $service_name..."
    
    # Detener por PID file si existe
    local pid_file=""
    case $service_name in
        "AI Agent") pid_file="infra-ai-agent/ai-agent.pid" ;;
        "Backstage") pid_file="backstage.pid" ;;
        "MinIO") pid_file="minio.pid" ;;
    esac
    
    if [ -n "$pid_file" ] && [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid" 2>/dev/null && log_success "$service_name detenido (PID: $pid)"
            sleep 2
        fi
        rm -f "$pid_file"
    fi
    
    # Detener por patrón de proceso
    pkill -f "$pattern" 2>/dev/null || true
    
    # Verificar que el puerto esté libre
    if [ -n "$port" ]; then
        for i in {1..5}; do
            if ! ss -tln | grep -q ":$port "; then
                break
            fi
            log_warning "Puerto $port aún ocupado, esperando..."
            sleep 2
        done
    fi
}

# Detener servicios existentes de forma segura
log_info "Deteniendo servicios existentes..."
stop_service "Backstage" "yarn.*start" "3000"
stop_service "AI Agent" "uvicorn.*8000" "8000"
stop_service "MinIO" "minio.*server" "9000"

# Cleanup adicional
pkill -f "backstage-cli" 2>/dev/null || true
sleep 3

# 1. Iniciar PostgreSQL
log_info "Iniciando PostgreSQL..."
if ! nc -z localhost 5432; then
    sudo systemctl start postgresql 2>/dev/null || {
        log_warning "PostgreSQL no disponible via systemctl, usando Docker..."
        docker run -d --name postgres-backstage \
            -e POSTGRES_USER=backstage \
            -e POSTGRES_PASSWORD=backstage123 \
            -e POSTGRES_DB=backstage \
            -p 5432:5432 \
            postgres:15 2>/dev/null || log_warning "PostgreSQL ya corriendo"
    }
    sleep 3
fi

if nc -z localhost 5432; then
    log_success "PostgreSQL funcionando en :5432"
else
    log_error "PostgreSQL no pudo iniciarse"
    exit 1
fi

# 2. Iniciar MinIO
log_info "Iniciando MinIO..."
if ! nc -z localhost 9000; then
    mkdir -p /tmp/minio-data
    nohup minio server /tmp/minio-data --address ":9000" --console-address ":9001" > minio.log 2>&1 &
    MINIO_PID=$!
    echo $MINIO_PID > minio.pid
    sleep 3
    
    if nc -z localhost 9000; then
        log_success "MinIO iniciado (PID: $MINIO_PID)"
        log_info "MinIO Console: http://localhost:9001 (admin/password)"
    else
        log_warning "MinIO no pudo iniciarse"
    fi
else
    log_success "MinIO ya funcionando en :9000"
fi

# 3. Iniciar AI Agent
log_info "Iniciando AI Agent..."
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

# Verificar .env
if [ ! -f ".env" ]; then
    log_warning "Creando .env desde .env.example"
    cp .env.example .env
fi

cd agent
nohup python main.py > ../ai-agent.log 2>&1 &
AI_PID=$!
echo $AI_PID > ../ai-agent.pid
log_success "AI Agent iniciado (PID: $AI_PID)"
cd ../..

# 4. Iniciar Backstage con verificaciones mejoradas
log_info "Iniciando Backstage..."
cd backstage-idp/infra-ai-backstage

# Verificar que el puerto 3000 esté libre
if ss -tln | grep -q ":3000 "; then
    log_error "Puerto 3000 ocupado. Deteniendo procesos..."
    pkill -f "yarn.*start" 2>/dev/null || true
    pkill -f ":3000" 2>/dev/null || true
    sleep 5
    
    if ss -tln | grep -q ":3000 "; then
        log_error "No se pudo liberar el puerto 3000"
        cd ../..
        exit 1
    fi
fi

# Verificar .env de Backstage
if [ ! -f ".env" ]; then
    log_warning "Creando .env de Backstage"
    cat > .env << 'EOF'
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=backstage
POSTGRES_PASSWORD=backstage123
POSTGRES_DB=backstage
GITHUB_TOKEN=
AUTH_GITHUB_CLIENT_ID=
AUTH_GITHUB_CLIENT_SECRET=
EOF
fi

# Verificar dependencias
if [ ! -d "node_modules" ]; then
    log_info "Instalando dependencias de Backstage..."
    yarn install --frozen-lockfile
fi

# Limpiar cache de Backstage
log_info "Limpiando cache de Backstage..."
rm -rf dist-types/ dist/ .cache/ 2>/dev/null || true

# Iniciar Backstage con timeout
log_info "Iniciando Backstage (esto puede tardar 1-2 minutos)..."
timeout 300 yarn start > ../../backstage.log 2>&1 &
BS_PID=$!
echo $BS_PID > ../../backstage.pid
log_success "Backstage iniciado (PID: $BS_PID)"
cd ../..

# Crear script de parada mejorado
cat > stop-platform.sh << 'EOF'
#!/bin/bash
echo "🛑 Deteniendo Infrastructure AI Platform..."

# Detener AI Agent
if [ -f "infra-ai-agent/ai-agent.pid" ]; then
    kill $(cat infra-ai-agent/ai-agent.pid) 2>/dev/null && echo "✅ AI Agent detenido"
    rm infra-ai-agent/ai-agent.pid
fi

# Detener Backstage
if [ -f "backstage.pid" ]; then
    kill $(cat backstage.pid) 2>/dev/null && echo "✅ Backstage detenido"
    rm backstage.pid
fi

# Detener MinIO
if [ -f "minio.pid" ]; then
    kill $(cat minio.pid) 2>/dev/null && echo "✅ MinIO detenido"
    rm minio.pid
fi

# Cleanup de procesos
pkill -f "uvicorn.*8000" 2>/dev/null || true
pkill -f "yarn.*start" 2>/dev/null || true
pkill -f "minio" 2>/dev/null || true

# Detener PostgreSQL Docker si existe
docker stop postgres-backstage 2>/dev/null || true
docker rm postgres-backstage 2>/dev/null || true

echo "🏁 Plataforma detenida"
EOF
chmod +x stop-platform.sh

# Esperar y verificar servicios
log_info "Verificando servicios..."
sleep 15

# Verificar PostgreSQL
if nc -z localhost 5432; then
    log_success "PostgreSQL funcionando en :5432"
else
    log_warning "PostgreSQL no responde en :5432"
fi

# Verificar MinIO
if nc -z localhost 9000; then
    log_success "MinIO funcionando en :9000"
else
    log_warning "MinIO no responde en :9000"
fi

# Verificar AI Agent
if curl -s http://localhost:8000/health > /dev/null; then
    log_success "AI Agent funcionando en :8000"
else
    log_warning "AI Agent no responde en :8000"
fi

# Verificar Backstage (puede tardar más)
log_info "Esperando Backstage (puede tardar 60-120 segundos)..."
backstage_ready=false
for i in {1..24}; do
    if curl -s --connect-timeout 5 http://localhost:3000 > /dev/null 2>&1; then
        log_success "Backstage funcionando en :3000"
        backstage_ready=true
        break
    fi
    
    # Verificar si el proceso sigue corriendo
    if [ -f "backstage.pid" ]; then
        local bs_pid=$(cat backstage.pid)
        if ! kill -0 "$bs_pid" 2>/dev/null; then
            log_error "Proceso de Backstage terminó inesperadamente"
            log_info "Últimas líneas del log:"
            tail -10 backstage.log
            break
        fi
    fi
    
    if [ $i -eq 24 ]; then
        log_warning "Backstage no responde en :3000 - revisa logs: tail -f backstage.log"
        log_info "Últimas líneas del log:"
        tail -10 backstage.log
    else
        echo -n "."
        sleep 5
    fi
done

# Mostrar información final
echo ""
echo "🎉 Infrastructure AI Platform iniciada!"
echo ""
echo "🌐 URLs:"
echo "  🤖 AI Agent:     http://localhost:8000"
echo "  📚 Docs:         http://localhost:8000/docs"
echo "  🎭 Backstage:    http://localhost:3000"
echo "  💾 MinIO:        http://localhost:9000"
echo "  🗄️  MinIO Console: http://localhost:9001"
echo ""
echo "🔧 Base de Datos:"
echo "  📊 PostgreSQL:   localhost:5432 (backstage/backstage123)"
echo ""
echo "📋 Logs:"
echo "  🤖 AI Agent:     tail -f infra-ai-agent/ai-agent.log"
echo "  🎭 Backstage:    tail -f backstage.log"
echo "  💾 MinIO:        tail -f minio.log"
echo ""
echo "🧪 Prueba:"
echo "  curl -X POST \"http://localhost:8000/process-text\" \\"
echo "    -F \"description=App web con S3 y Lambda\""
echo ""
echo "🛑 Detener: ./stop-platform.sh"
echo ""
