#!/bin/bash

# =============================================================================
# Infrastructure AI Platform - Monitor Script
# =============================================================================

echo "📊 Estado de Infrastructure AI Platform"
echo "======================================"
echo ""

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_service() {
    local service=$1
    local check_cmd=$2
    local url=$3
    
    if eval $check_cmd >/dev/null 2>&1; then
        echo -e "✅ ${GREEN}$service: Funcionando${NC} ($url)"
        return 0
    else
        echo -e "❌ ${RED}$service: No disponible${NC} ($url)"
        return 1
    fi
}

# Verificar servicios
echo "🔍 Verificando servicios..."

check_service "PostgreSQL" "nc -z localhost 5432" "localhost:5432"
check_service "AI Agent" "curl -s http://localhost:8000/health" "http://localhost:8000"
check_service "Backstage UI" "curl -s http://localhost:3000" "http://localhost:3000"
check_service "Backstage API" "curl -s http://localhost:7007" "http://localhost:7007"

echo ""
echo "🌐 URLs de acceso:"
echo "  🤖 AI Agent API:    http://localhost:8000"
echo "  📚 AI Agent Docs:   http://localhost:8000/docs"
echo "  🎭 Backstage UI:    http://localhost:3000"
echo "  🔧 Backstage API:   http://localhost:7007"
echo "  🐘 PostgreSQL:      localhost:5432"

echo ""
echo "📊 Información del sistema:"
echo "  🐳 Docker containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(backstage|postgres)" || echo "    No hay containers relacionados ejecutándose"

echo ""
echo "💾 Uso de puertos:"
netstat -tulpn 2>/dev/null | grep -E ":(3000|7007|8000|5432)" | head -10 || echo "    No se pudieron obtener los puertos"

echo ""
echo "🔄 Para reiniciar la plataforma:"
echo "  ./start-platform.sh"

echo ""
echo "🛑 Para detener la plataforma:"
echo "  ./stop-platform.sh"
