#!/bin/bash

# Auto-load environment variables
if [ -f ".env" ]; then
    set -a; source .env; set +a
elif [ -f "infra-ai-agent/.env" ]; then
    set -a; source infra-ai-agent/.env; set +a
elif [ -f "backstage-idp/infra-ai-backstage/.env" ]; then
    set -a; source backstage-idp/infra-ai-backstage/.env; set +a
fi

echo "🚀 Iniciando Infrastructure AI Platform..."

# Detener servicios existentes
pkill -f "uvicorn.*8000" 2>/dev/null || true
pkill -f "yarn.*start" 2>/dev/null || true
pkill -f "backstage-cli" 2>/dev/null || true
sleep 2

# Verificar PostgreSQL
if ! nc -z localhost 5432; then
    echo "🐘 Iniciando PostgreSQL..."
    cd /home/giovanemere/docker/postgres && ./start-postgres.sh && sleep 5
    cd /home/giovanemere/demos
fi

# Iniciar AI Agent
echo "🤖 Iniciando AI Agent..."
cd infra-ai-agent
if [ -f ".env" ]; then
    set -a; source .env; set +a
fi
source venv/bin/activate
cd agent
nohup python main.py > ../ai-agent.log 2>&1 &
echo $! > ../ai-agent.pid
cd ../..

# Iniciar Backstage
echo "🎭 Iniciando Backstage..."
cd backstage-idp/infra-ai-backstage
if [ -f ".env" ]; then
    set -a; source .env; set +a
fi
nohup yarn start > backstage.log 2>&1 &
echo $! > ../../backstage.pid
cd ../..

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

echo ""
echo "✅ Servicios iniciados:"
echo "  🤖 AI Agent: http://localhost:8000"
echo "  🎭 Backstage: http://localhost:3000"
echo ""
echo "🛑 Detener: ./stop-platform.sh"
