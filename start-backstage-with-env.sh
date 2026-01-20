#!/bin/bash

# Script para iniciar Backstage con variables de entorno correctas
set -e

echo "🎭 Iniciando Backstage con configuración completa..."

# Ir al directorio de Backstage
cd /home/giovanemere/demos/backstage-idp/infra-ai-backstage

# Cargar variables de entorno
if [ -f ".env" ]; then
    echo "📋 Cargando variables de entorno..."
    set -a
    source .env
    set +a
    
    # Exportar explícitamente las variables críticas
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
    
    echo "✅ Variables cargadas:"
    echo "  APP_BASE_URL: $APP_BASE_URL"
    echo "  BACKEND_BASE_URL: $BACKEND_BASE_URL"
    echo "  POSTGRES_HOST: $POSTGRES_HOST"
    echo "  GITHUB_ORG: $GITHUB_ORG"
else
    echo "❌ Archivo .env no encontrado"
    exit 1
fi

# Verificar que PostgreSQL esté corriendo
if ! nc -z localhost 5432; then
    echo "❌ PostgreSQL no está corriendo en puerto 5432"
    echo "Inicia PostgreSQL primero"
    exit 1
fi

# Iniciar Backstage
echo "🚀 Iniciando Backstage..."
yarn start
