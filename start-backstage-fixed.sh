#!/bin/bash

echo "🚀 Iniciando Backstage con configuración completa..."

# Ir al directorio de Backstage
cd /home/giovanemere/demos/backstage-idp/infra-ai-backstage

# Cargar variables de entorno
set -a
source .env
set +a

# Verificar variables críticas
echo "✅ Variables cargadas:"
echo "  - BACKEND_BASE_URL: $BACKEND_BASE_URL"
echo "  - APP_BASE_URL: $APP_BASE_URL"
echo "  - GITHUB_ORG: $GITHUB_ORG"
echo "  - POSTGRES_HOST: $POSTGRES_HOST"

# Detener procesos existentes
echo "🛑 Deteniendo procesos existentes..."
pkill -f "backstage-cli" 2>/dev/null || true
pkill -f "yarn start" 2>/dev/null || true
sleep 3

# Iniciar Backstage
echo "🎯 Iniciando Backstage..."
nohup yarn start > backstage.log 2>&1 &

echo "⏳ Esperando inicio..."
sleep 10

# Verificar estado
if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 | grep -q "200"; then
    echo "✅ Frontend iniciado en http://localhost:3000"
else
    echo "❌ Error en frontend"
fi

if curl -s -o /dev/null -w "%{http_code}" http://localhost:7007/api/catalog/locations | grep -q "200\|401"; then
    echo "✅ Backend iniciado en http://localhost:7007"
else
    echo "❌ Error en backend"
fi

echo ""
echo "🎯 URLs disponibles:"
echo "  - Frontend: http://localhost:3000"
echo "  - Backend API: http://localhost:7007"
echo "  - Catálogo: http://localhost:3000/catalog"
echo "  - Templates: http://localhost:3000/create"
echo ""
echo "📋 Para ver logs: tail -f backstage.log"
