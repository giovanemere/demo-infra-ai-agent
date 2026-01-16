#!/bin/bash
# Reiniciar Backstage
echo "🔄 Reiniciando Backstage..."

# Detener proceso actual
pkill -f "python3 -m http.server 3000"
pkill -f "yarn dev"
pkill -f "backstage"
sleep 2

# Iniciar Backstage real
cd /home/giovanemere/demos/backstage-idp/infra-ai-backstage

# Configurar variables de entorno
export POSTGRES_HOST=localhost
export POSTGRES_PORT=5432
export POSTGRES_USER=backstage
export POSTGRES_PASSWORD=backstage
export POSTGRES_DB=backstage
export GITHUB_TOKEN=${GITHUB_TOKEN:-your_github_token_here}

# Intentar iniciar con yarn dev (modo desarrollo)
echo "🎭 Iniciando Backstage real..."
nohup yarn dev > backstage.log 2>&1 &

echo "✅ Backstage iniciado en puerto 3000"
echo "📝 Ver logs: tail -f backstage-idp/infra-ai-backstage/backstage.log"
