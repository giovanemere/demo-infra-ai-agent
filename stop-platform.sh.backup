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
