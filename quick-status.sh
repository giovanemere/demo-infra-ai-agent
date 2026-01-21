#!/bin/bash

# Quick Status Check - Infrastructure AI Platform

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Estado Rápido de Servicios${NC}"
echo "================================"

# Función para verificar servicio
check_service() {
    local name=$1
    local port=$2
    local url=$3
    
    if ss -tln | grep -q ":$port "; then
        if [ -n "$url" ] && curl -s --connect-timeout 3 "$url" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ $name${NC} - Puerto $port (Respondiendo)"
        else
            echo -e "${YELLOW}⚠️  $name${NC} - Puerto $port (Puerto abierto, no responde HTTP)"
        fi
    else
        echo -e "${RED}❌ $name${NC} - Puerto $port (No disponible)"
    fi
}

# Verificar servicios
check_service "PostgreSQL" "5432"
check_service "AI Agent" "8000" "http://localhost:8000/health"
check_service "MinIO" "9000" "http://localhost:9000/minio/health/live"
check_service "Backstage" "3000" "http://localhost:3000"

echo ""

# Verificar PIDs
echo -e "${BLUE}📋 Procesos Activos${NC}"
echo "==================="

if [ -f "infra-ai-agent/ai-agent.pid" ]; then
    pid=$(cat infra-ai-agent/ai-agent.pid)
    if kill -0 "$pid" 2>/dev/null; then
        echo -e "${GREEN}✅ AI Agent${NC} - PID: $pid"
    else
        echo -e "${RED}❌ AI Agent${NC} - PID file existe pero proceso no"
    fi
else
    echo -e "${YELLOW}⚠️  AI Agent${NC} - Sin PID file"
fi

if [ -f "backstage.pid" ]; then
    pid=$(cat backstage.pid)
    if kill -0 "$pid" 2>/dev/null; then
        echo -e "${GREEN}✅ Backstage${NC} - PID: $pid"
    else
        echo -e "${RED}❌ Backstage${NC} - PID file existe pero proceso no"
    fi
else
    echo -e "${YELLOW}⚠️  Backstage${NC} - Sin PID file"
fi

if [ -f "minio.pid" ]; then
    pid=$(cat minio.pid)
    if kill -0 "$pid" 2>/dev/null; then
        echo -e "${GREEN}✅ MinIO${NC} - PID: $pid"
    else
        echo -e "${RED}❌ MinIO${NC} - PID file existe pero proceso no"
    fi
else
    echo -e "${YELLOW}⚠️  MinIO${NC} - Sin PID file"
fi

echo ""
echo -e "${BLUE}🌐 URLs Disponibles${NC}"
echo "=================="
echo "🤖 AI Agent:     http://localhost:8000"
echo "📚 Docs:         http://localhost:8000/docs"
echo "🎭 Backstage:    http://localhost:3000"
echo "💾 MinIO:        http://localhost:9000"
echo "🗄️  MinIO Console: http://localhost:9001"
