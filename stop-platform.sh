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
