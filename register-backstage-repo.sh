#!/bin/bash

# Script para registrar repositorio en Backstage automáticamente

BACKSTAGE_URL="http://localhost:3000"
REPO_URL="https://github.com/giovanemere/demo-infra-ai-agent-template-idp/blob/main/catalog-info.yaml"

echo "🔗 Registrando repositorio en Backstage..."
echo "URL: $REPO_URL"

# Verificar que Backstage esté corriendo
if ! curl -s --connect-timeout 5 "$BACKSTAGE_URL" > /dev/null; then
    echo "❌ Backstage no está corriendo en $BACKSTAGE_URL"
    echo "Inicia Backstage primero: ./task-runner.sh start"
    exit 1
fi

# Intentar registrar via API
echo "📝 Intentando registro automático..."

# Crear payload JSON
PAYLOAD=$(cat << EOF
{
  "type": "url",
  "target": "$REPO_URL"
}
EOF
)

# Hacer petición POST
RESPONSE=$(curl -s -X POST \
  "$BACKSTAGE_URL/api/catalog/locations" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  2>/dev/null)

if echo "$RESPONSE" | grep -q "error"; then
    echo "⚠️  Registro automático falló. Registra manualmente:"
    echo ""
    echo "1. Ve a: $BACKSTAGE_URL/catalog-import"
    echo "2. Pega esta URL: $REPO_URL"
    echo "3. Haz clic en 'Analyze'"
    echo ""
    echo "Respuesta de la API:"
    echo "$RESPONSE" | jq . 2>/dev/null || echo "$RESPONSE"
else
    echo "✅ Repositorio registrado exitosamente"
    echo "🌐 Ve a: $BACKSTAGE_URL/catalog"
fi

echo ""
echo "📋 URLs útiles:"
echo "  🎭 Backstage Catalog: $BACKSTAGE_URL/catalog"
echo "  📥 Import Component: $BACKSTAGE_URL/catalog-import"
echo "  🏗️  Create Component: $BACKSTAGE_URL/create"
