#!/bin/bash

# Auto-load environment variables
if [ -f ".env" ]; then
    set -a
    source .env
    set +a
elif [ -f "../backstage-idp/infra-ai-backstage/.env" ]; then
    cd ../backstage-idp/infra-ai-backstage
    set -a
    source .env
    set +a
    cd - > /dev/null
elif [ -f "backstage-idp/infra-ai-backstage/.env" ]; then
    cd backstage-idp/infra-ai-backstage
    set -a
    source .env
    set +a
    cd - > /dev/null
fi

echo "🚀 Desplegando Infrastructure AI Platform v1.0.0"

# Verificar prerequisites
./check-prerequisites.sh

# Configurar variables de entorno
echo "🔧 Configurar variables de entorno:"
echo "1. Editar infra-ai-agent/.env"
echo "2. Editar backstage-idp/infra-ai-backstage/.env"
echo "3. Ejecutar: ./platform-cli start"

echo "✅ Despliegue completado"
