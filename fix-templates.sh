#!/bin/bash

echo "🔧 Solucionando problema de templates en Backstage..."

# 1. Verificar que los templates existen en GitHub
echo "📋 Verificando templates en GitHub..."
TEMPLATES=$(curl -s https://api.github.com/repos/giovanemere/demo-infra-ai-agent-template-idp/contents/templates | grep -o '"name":"[^"]*"' | cut -d'"' -f4)
echo "Templates encontrados: $TEMPLATES"

# 2. Esperar a que Backstage esté listo
echo "⏳ Esperando a que Backstage esté disponible..."
for i in {1..20}; do
    if curl -s http://localhost:3000 > /dev/null 2>&1; then
        echo "✅ Backstage disponible"
        break
    fi
    echo -n "."
    sleep 3
done

# 3. Registrar templates manualmente via API
echo "📝 Registrando templates directamente..."

# Template 1: AI Infrastructure Project
curl -X POST "http://localhost:7007/api/catalog/locations" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer fake-token" \
  -d '{
    "type": "url",
    "target": "https://github.com/giovanemere/demo-infra-ai-agent-template-idp/blob/main/templates/ai-infrastructure-project/template.yaml"
  }' 2>/dev/null && echo "✅ Template ai-infrastructure-project registrado"

# Template 2: AWS Simple Web App  
curl -X POST "http://localhost:7007/api/catalog/locations" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer fake-token" \
  -d '{
    "type": "url",
    "target": "https://github.com/giovanemere/demo-infra-ai-agent-template-idp/blob/main/templates/aws-simple-web-app/template.yaml"
  }' 2>/dev/null && echo "✅ Template aws-simple-web-app registrado"

echo ""
echo "🎯 SOLUCIÓN INMEDIATA:"
echo "1. Abrir: http://localhost:3000"
echo "2. Ir a: Settings → Integrations"
echo "3. Hacer clic en: 'Register Existing Component'"
echo "4. Pegar esta URL:"
echo "   https://github.com/giovanemere/demo-infra-ai-agent-template-idp/blob/main/templates/ai-infrastructure-project/template.yaml"
echo "5. Hacer clic en 'Analyze' y luego 'Import'"
echo "6. Repetir para:"
echo "   https://github.com/giovanemere/demo-infra-ai-agent-template-idp/blob/main/templates/aws-simple-web-app/template.yaml"
echo ""
echo "🔄 Después de registrar, ir a: http://localhost:3000/create"
