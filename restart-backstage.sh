#!/bin/bash
echo "🔄 Reiniciando Backstage..."

cd /home/giovanemere/demos/backstage-idp/infra-ai-backstage

# Detener procesos existentes
pkill -f "backstage-cli" 2>/dev/null || true
pkill -f "yarn start" 2>/dev/null || true
sleep 3

# Cargar variables de entorno correctamente
set -a
source .env
set +a

# Iniciar Backstage
echo "🚀 Iniciando Backstage..."
nohup yarn start > backstage.log 2>&1 &

sleep 10

# Verificar estado
if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 | grep -q "200"; then
    echo "✅ Backstage reiniciado exitosamente"
    echo "🌐 Frontend: http://localhost:3000"
    echo "🔧 Backend: http://localhost:7007"
else
    echo "❌ Error al reiniciar Backstage"
    echo "📋 Ver logs: tail -f backstage.log"
fi
