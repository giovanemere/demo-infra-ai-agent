#!/bin/bash

echo "🔧 ACTUALIZACIÓN COMPLETA - Variables y Servicios"
echo "================================================"

# Auto-load environment variables
if [ -f ".env" ]; then
    set -a; source .env; set +a
elif [ -f "../backstage-idp/infra-ai-backstage/.env" ]; then
    cd ../backstage-idp/infra-ai-backstage; set -a; source .env; set +a; cd - > /dev/null
elif [ -f "backstage-idp/infra-ai-backstage/.env" ]; then
    cd backstage-idp/infra-ai-backstage; set -a; source .env; set +a; cd - > /dev/null
fi

echo "1️⃣ Deteniendo servicios existentes..."
pkill -f "uvicorn" 2>/dev/null || true
pkill -f "backstage-cli" 2>/dev/null || true
pkill -f "yarn start" 2>/dev/null || true
pkill -f "python.*main.py" 2>/dev/null || true
sleep 3

echo ""
echo "2️⃣ Verificando PostgreSQL..."
if ! nc -z localhost 5432; then
    echo "🐘 Iniciando PostgreSQL..."
    cd /home/giovanemere/docker/postgres
    ./start-postgres.sh
    sleep 5
    cd /home/giovanemere/demos
fi
echo "✅ PostgreSQL: $(nc -z localhost 5432 && echo "OK" || echo "ERROR")"

echo ""
echo "3️⃣ Iniciando AI Agent (Frontend funcional)..."
cd infra-ai-agent

# Verificar estructura
if [ ! -f "agent/main.py" ]; then
    echo "❌ agent/main.py no encontrado"
    exit 1
fi

# Activar venv y instalar dependencias
if [ ! -d "venv" ]; then
    python -m venv venv
fi
source venv/bin/activate
pip install -r requirements.txt -q

# Iniciar AI Agent
cd agent
nohup python main.py > ../ai-agent.log 2>&1 &
AI_PID=$!
echo $AI_PID > ../ai-agent.pid
cd ../..

sleep 5
AI_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health)
echo "✅ AI Agent (:8000): $AI_STATUS"

echo ""
echo "4️⃣ Iniciando Backstage..."
cd backstage-idp/infra-ai-backstage

# Cargar variables de entorno
set -a
source .env
set +a

# Verificar variables críticas
if [ -z "$BACKEND_BASE_URL" ] || [ -z "$GITHUB_ORG" ]; then
    echo "❌ Variables de entorno no cargadas correctamente"
    echo "BACKEND_BASE_URL: $BACKEND_BASE_URL"
    echo "GITHUB_ORG: $GITHUB_ORG"
    exit 1
fi

# Iniciar Backstage
nohup yarn start > backstage.log 2>&1 &
BS_PID=$!
echo $BS_PID > ../../backstage.pid

cd ../..

echo ""
echo "5️⃣ Esperando servicios..."
sleep 15

# Verificar estados finales
AI_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health)
BS_FRONTEND=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000)
BS_BACKEND=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:7007/api/catalog/locations)
PG_STATUS=$(nc -z localhost 5432 && echo "200" || echo "000")

echo ""
echo "📊 ESTADO FINAL DE SERVICIOS:"
echo "=============================="
echo "🤖 AI Agent (:8000): $AI_STATUS $([ "$AI_STATUS" = "200" ] && echo "✅" || echo "❌")"
echo "🎭 Backstage Frontend (:3000): $BS_FRONTEND $([ "$BS_FRONTEND" = "200" ] && echo "✅" || echo "❌")"
echo "🔧 Backstage Backend (:7007): $BS_BACKEND $([ "$BS_BACKEND" = "200" ] || [ "$BS_BACKEND" = "401" ] && echo "✅" || echo "❌")"
echo "🐘 PostgreSQL (:5432): $PG_STATUS $([ "$PG_STATUS" = "200" ] && echo "✅" || echo "❌")"

echo ""
echo "🌐 URLs DISPONIBLES:"
echo "==================="
echo "🤖 AI Agent (Frontend funcional): http://localhost:8000"
echo "📚 AI Agent Docs: http://localhost:8000/docs"
echo "🎭 Backstage UI: http://localhost:3000"
echo "📋 Catálogo Backstage: http://localhost:3000/catalog"
echo "🏗️ Templates Backstage: http://localhost:3000/create"

echo ""
echo "🧪 PRUEBAS RÁPIDAS:"
echo "==================="
echo "# Probar AI Agent:"
echo "curl -X POST 'http://localhost:8000/process-text' -F 'description=App web con S3 y Lambda'"
echo ""
echo "# Ver logs:"
echo "tail -f infra-ai-agent/ai-agent.log"
echo "tail -f backstage-idp/infra-ai-backstage/backstage.log"

# Verificar si todo está funcionando
if [ "$AI_STATUS" = "200" ] && [ "$BS_FRONTEND" = "200" ] && [ "$PG_STATUS" = "200" ]; then
    echo ""
    echo "🎉 ¡TODOS LOS SERVICIOS FUNCIONANDO CORRECTAMENTE!"
    echo "✅ Plataforma lista para usar"
else
    echo ""
    echo "⚠️ Algunos servicios tienen problemas. Revisa los logs."
fi
