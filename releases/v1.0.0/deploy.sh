#!/bin/bash
echo "🚀 Desplegando Infrastructure AI Platform v1.0.0"

# Verificar prerequisites
./check-prerequisites.sh

# Configurar variables de entorno
echo "🔧 Configurar variables de entorno:"
echo "1. Editar infra-ai-agent/.env"
echo "2. Editar backstage-idp/infra-ai-backstage/.env"
echo "3. Ejecutar: ./platform-cli start"

echo "✅ Despliegue completado"
