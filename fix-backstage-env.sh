#!/bin/bash

echo "🔧 Corrigiendo problema de variables de entorno en Backstage"
echo "=========================================================="

# Ir al directorio de Backstage
cd /home/giovanemere/demos/backstage-idp/infra-ai-backstage

# Verificar que existe el archivo .env
if [ ! -f ".env" ]; then
    echo "❌ Archivo .env no encontrado en backstage-idp/infra-ai-backstage/"
    exit 1
fi

echo "📋 Variables actuales en .env:"
cat .env

# Detener Backstage si está corriendo
echo "🛑 Deteniendo Backstage existente..."
pkill -f "yarn.*start" 2>/dev/null || true
pkill -f "backstage-cli" 2>/dev/null || true
sleep 2

# Verificar PostgreSQL
echo "🐘 Verificando PostgreSQL..."
if ! nc -z localhost 5432; then
    echo "❌ PostgreSQL no está corriendo. Iniciando..."
    cd /home/giovanemere/docker/postgres
    ./start-postgres.sh
    sleep 5
    cd /home/giovanemere/demos/backstage-idp/infra-ai-backstage
fi

# Cargar variables de entorno explícitamente
echo "🔄 Cargando variables de entorno..."
set -a
source .env
set +a

# Exportar variables críticas
export APP_BASE_URL
export BACKEND_BASE_URL
export POSTGRES_HOST
export POSTGRES_PORT
export POSTGRES_USER
export POSTGRES_PASSWORD
export POSTGRES_DB
export GITHUB_TOKEN
export GITHUB_ORG
export GITHUB_REPO
export GITHUB_BRANCH
export CATALOG_PATH
export GITHUB_CLIENT_ID
export GITHUB_CLIENT_SECRET
export BACKEND_SECRET

echo "✅ Variables exportadas:"
echo "  BACKEND_BASE_URL: $BACKEND_BASE_URL"
echo "  APP_BASE_URL: $APP_BASE_URL"

# Iniciar Backstage con variables cargadas
echo "🚀 Iniciando Backstage con variables de entorno..."
yarn start
