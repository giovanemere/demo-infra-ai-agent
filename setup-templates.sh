#!/bin/bash

echo "🔧 Configurando templates para carga automática desde GitHub..."

# Usar el template local corregido temporalmente
echo "📝 Registrando template local corregido..."
curl -s -X POST "http://localhost:3000/api/catalog/locations" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "url",
    "target": "http://localhost:8080/aws-web-app-fixed.yaml"
  }' > /dev/null

echo "✅ Template registrado localmente"
echo ""
echo "🌐 Ve a http://localhost:3000/create para usar el template"
echo ""
echo "📋 Para usar templates desde GitHub:"
echo "1. Los templates están en: https://github.com/giovanemere/demo-infra-ai-agent-template-idp/tree/main/templates"
echo "2. Necesitan ser corregidos (quitar espacios en tags)"
echo "3. Backstage los cargará automáticamente desde catalog-info.yaml"
