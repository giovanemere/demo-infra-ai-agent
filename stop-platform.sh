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
