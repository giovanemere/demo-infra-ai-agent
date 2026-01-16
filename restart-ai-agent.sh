#!/bin/bash
# Reiniciar AI Agent
echo "🔄 Reiniciando AI Agent..."

# Detener proceso actual
pkill -f uvicorn
sleep 2

# Iniciar nuevo proceso
cd /home/giovanemere/demos/infra-ai-agent
source venv/bin/activate
PYTHONPATH=/home/giovanemere/demos/infra-ai-agent nohup uvicorn agent.main:app --host 0.0.0.0 --port 8000 > ai-agent.log 2>&1 & 
echo $! > ai-agent.pid

echo "✅ AI Agent reiniciado en puerto 8000"
