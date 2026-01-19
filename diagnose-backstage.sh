#!/bin/bash

echo "🔍 DIAGNÓSTICO BACKSTAGE"
echo "========================"

echo ""
echo "1️⃣ Verificando servicios..."
echo "Frontend (3000): $(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000)"
echo "Backend (7007): $(curl -s -o /dev/null -w "%{http_code}" http://localhost:7007/api/catalog/locations)"

echo ""
echo "2️⃣ Verificando configuración..."
cd /home/giovanemere/demos/backstage-idp/infra-ai-backstage
set -a
source .env
set +a
echo "Variables de entorno:"
echo "- GITHUB_ORG: $GITHUB_ORG"
echo "- GITHUB_REPO: $GITHUB_REPO"
echo "- GITHUB_BRANCH: $GITHUB_BRANCH"
echo "- CATALOG_PATH: $CATALOG_PATH"

echo ""
echo "3️⃣ Verificando repositorio GitHub..."
REPO_URL="https://raw.githubusercontent.com/${GITHUB_ORG}/${GITHUB_REPO}/${GITHUB_BRANCH}${CATALOG_PATH}"
echo "URL del catálogo: $REPO_URL"
echo "Estado: $(curl -s -o /dev/null -w "%{http_code}" "$REPO_URL")"

echo ""
echo "4️⃣ Verificando logs recientes..."
tail -5 backstage.log 2>/dev/null | grep -E "(error|Error|ERROR)" || echo "No hay errores recientes"

echo ""
echo "5️⃣ Verificando base de datos..."
docker exec postgres-backstage psql -U backstage -d backstage -c "SELECT COUNT(*) as entities FROM final_entities;" 2>/dev/null || echo "No se puede conectar a la base de datos"

echo ""
echo "🎯 RECOMENDACIONES:"
echo "1. Ve a http://localhost:3000 y haz login con GitHub"
echo "2. Ve a http://localhost:3000/catalog para ver las entidades"
echo "3. Ve a http://localhost:3000/create para ver los templates"
echo "4. Si no ves contenido, espera 5 minutos para la sincronización"
