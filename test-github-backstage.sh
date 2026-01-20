#!/bin/bash

echo "🔍 Probando conexión GitHub y Backstage..."
echo ""

# Cargar variables de entorno
if [ -f ".env" ]; then
    source .env
fi

# Verificar que el token esté configurado
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ GITHUB_TOKEN no configurado en .env"
    exit 1
fi

# 1. Probar token de GitHub
echo "1️⃣ Verificando token de GitHub..."
GITHUB_USER=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user | python3 -c "import sys, json; print(json.load(sys.stdin)['login'])" 2>/dev/null)
if [ "$GITHUB_USER" = "giovanemere" ]; then
    echo "✅ GitHub token válido - Usuario: $GITHUB_USER"
else
    echo "❌ GitHub token inválido"
    exit 1
fi

# 2. Probar acceso al repositorio
echo ""
echo "2️⃣ Verificando acceso al repositorio..."
REPO_NAME=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/giovanemere/demo-infra-ai-agent | python3 -c "import sys, json; print(json.load(sys.stdin)['name'])" 2>/dev/null)
if [ "$REPO_NAME" = "demo-infra-ai-agent" ]; then
    echo "✅ Acceso al repositorio: $REPO_NAME"
else
    echo "❌ No se puede acceder al repositorio"
    exit 1
fi

# 3. Probar catalog-info.yaml
echo ""
echo "3️⃣ Verificando catalog-info.yaml..."
CATALOG_EXISTS=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://raw.githubusercontent.com/giovanemere/demo-infra-ai-agent/main/catalog-info.yaml | head -1)
if [[ "$CATALOG_EXISTS" == *"apiVersion"* ]]; then
    echo "✅ catalog-info.yaml encontrado"
else
    echo "❌ catalog-info.yaml no encontrado"
    exit 1
fi

# 4. Probar API de Backstage
echo ""
echo "4️⃣ Verificando API de Backstage..."
TOKEN=$(curl -s "http://localhost:7007/api/auth/guest/refresh" | python3 -c "import sys, json; print(json.load(sys.stdin)['backstageIdentity']['token'])" 2>/dev/null)
if [ ! -z "$TOKEN" ]; then
    echo "✅ Token de Backstage obtenido"
else
    echo "❌ No se pudo obtener token de Backstage"
    exit 1
fi

# 5. Probar entidades del catálogo
echo ""
echo "5️⃣ Verificando entidades del catálogo..."
ENTITIES=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:7007/api/catalog/entities" | python3 -c "import sys, json; print(len(json.load(sys.stdin)))" 2>/dev/null)
if [ "$ENTITIES" -gt "0" ]; then
    echo "✅ Catálogo cargado - $ENTITIES entidades encontradas"
else
    echo "❌ Catálogo vacío"
    exit 1
fi

# 6. Verificar componente AI Agent
echo ""
echo "6️⃣ Verificando componente AI Agent..."
AI_AGENT=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:7007/api/catalog/entities/by-name/component/default/ai-agent" | python3 -c "import sys, json; print(json.load(sys.stdin)['metadata']['name'])" 2>/dev/null)
if [ "$AI_AGENT" = "ai-agent" ]; then
    echo "✅ Componente AI Agent encontrado en Backstage"
else
    echo "❌ Componente AI Agent no encontrado"
    exit 1
fi

echo ""
echo "🎉 ¡Todas las pruebas pasaron! GitHub y Backstage están conectados correctamente."
echo ""
echo "📊 Resumen:"
echo "  • GitHub Usuario: $GITHUB_USER"
echo "  • Repositorio: $REPO_NAME"
echo "  • Entidades en catálogo: $ENTITIES"
echo "  • Componente AI Agent: ✅"
echo ""
echo "🌐 URLs:"
echo "  • Backstage: http://localhost:3000"
echo "  • AI Agent: http://localhost:8000"
