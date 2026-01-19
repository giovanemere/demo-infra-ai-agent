#!/bin/bash
echo "🔄 Reiniciando AI Agent..."

# Auto-load environment variables
if [ -f ".env" ]; then
    set -a; source .env; set +a
elif [ -f "../backstage-idp/infra-ai-backstage/.env" ]; then
    cd ../backstage-idp/infra-ai-backstage; set -a; source .env; set +a; cd - > /dev/null
elif [ -f "backstage-idp/infra-ai-backstage/.env" ]; then
    cd backstage-idp/infra-ai-backstage; set -a; source .env; set +a; cd - > /dev/null
fi

# Detener proceso existente
pkill -f "python.*main.py" 2>/dev/null || true
pkill -f "uvicorn" 2>/dev/null || true
sleep 2

# Iniciar AI Agent
cd /home/giovanemere/demos/infra-ai-agent
source venv/bin/activate
cd agent
nohup python main.py > ../ai-agent.log 2>&1 &
echo $! > ../ai-agent.pid

sleep 3

# Verificar
if curl -s http://localhost:8000/health > /dev/null; then
    echo "✅ AI Agent reiniciado en :8000"
else
    echo "❌ Error reiniciando AI Agent"
fi
