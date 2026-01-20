#!/bin/bash

# Auto-load environment variables
if [ -f ".env" ]; then
    set -a; source .env; set +a
elif [ -f "infra-ai-agent/.env" ]; then
    set -a; source infra-ai-agent/.env; set +a
elif [ -f "backstage-idp/infra-ai-backstage/.env" ]; then
    set -a; source backstage-idp/infra-ai-backstage/.env; set +a
fi

# Restaurar configuraciones si no existen
if [ ! -f "infra-ai-agent/.env" ] || [ ! -f "backstage-idp/infra-ai-backstage/.env" ]; then
    echo "🔄 Restaurando configuraciones .env..."
    ./manage-env-configs.sh restore
fi

# Hacer backup automático de configuraciones
./manage-env-configs.sh backup > /dev/null 2>&1

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

# Detener servicios existentes
log_info "Deteniendo servicios existentes..."
pkill -f "uvicorn.*8000" 2>/dev/null || true
pkill -f "yarn.*start" 2>/dev/null || true
pkill -f "backstage-cli" 2>/dev/null || true
sleep 2

# Iniciar PostgreSQL si no está corriendo
if ! nc -z localhost 5432; then
    log_info "Iniciando PostgreSQL..."
    cd /home/giovanemere/docker/postgres
    ./start-postgres.sh
    sleep 5
    cd /home/giovanemere/demos
fi

# Iniciar AI Agent
log_info "Iniciando AI Agent..."
cd infra-ai-agent
if [ ! -f ".env" ]; then
    log_warning "Creando .env desde .env.example"
    cp .env.example .env
fi
source venv/bin/activate
cd agent
nohup python main.py > ../ai-agent.log 2>&1 &
AI_PID=$!
echo $AI_PID > ../ai-agent.pid
log_success "AI Agent iniciado (PID: $AI_PID)"
cd ../..

# Iniciar Backstage
log_info "Iniciando Backstage..."
nohup ./start-backstage-with-env.sh > backstage.log 2>&1 &
BS_PID=$!
echo $BS_PID > backstage.pid
log_success "Backstage iniciado (PID: $BS_PID)"

# Crear script de parada
cat > stop-platform.sh << 'EOF'
#!/bin/bash
echo "🛑 Deteniendo Infrastructure AI Platform..."

if [ -f "ai-agent.pid" ]; then
    kill $(cat ai-agent.pid) 2>/dev/null && echo "✅ AI Agent detenido"
    rm ai-agent.pid
fi

if [ -f "backstage.pid" ]; then
    kill $(cat backstage.pid) 2>/dev/null && echo "✅ Backstage detenido"
    rm backstage.pid
fi

pkill -f "uvicorn.*8000" 2>/dev/null || true
pkill -f "yarn.*start" 2>/dev/null || true

echo "🏁 Plataforma detenida"
EOF
chmod +x stop-platform.sh

# Esperar y verificar servicios
log_info "Verificando servicios..."
sleep 30  # Dar más tiempo a Backstage para iniciar

if curl -s http://localhost:8000/health > /dev/null; then
    log_success "AI Agent funcionando en :8000"
else
    log_warning "AI Agent no responde en :8000"
fi

if curl -s http://localhost:3000 > /dev/null; then
    log_success "Backstage funcionando en :3000"
else
    log_warning "Backstage no responde en :3000"
fi

# Mostrar información final
echo ""
echo "🎉 Infrastructure AI Platform iniciada!"
echo ""
echo "🌐 URLs:"
echo "  🤖 AI Agent:     http://localhost:8000"
echo "  📚 Docs:         http://localhost:8000/docs"
echo "  🎭 Backstage:    http://localhost:3000"
echo ""
echo "🧪 Prueba:"
echo "  curl -X POST \"http://localhost:8000/process-text\" \\"
echo "    -F \"description=App web con S3 y Lambda\""
echo ""
echo "🛑 Detener: ./stop-platform.sh"
echo ""
