#!/bin/bash

echo "🔄 Registrando templates en Backstage..."

# Esperar a que Backstage esté listo
echo "Esperando a que Backstage esté disponible..."
for i in {1..30}; do
    if curl -s http://localhost:7007/api/catalog/locations > /dev/null 2>&1; then
        echo "✅ Backstage API disponible"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ Backstage API no disponible después de 30 intentos"
        exit 1
    fi
    sleep 2
done

# Registrar la ubicación de los templates
echo "📋 Registrando ubicación de templates..."

curl -X POST "http://localhost:7007/api/catalog/locations" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "url",
    "target": "https://github.com/giovanemere/demo-infra-ai-agent-template-idp/blob/main/catalog-info.yaml"
  }' && echo "✅ Ubicación principal registrada"

# Registrar templates individuales
echo "🏗️ Registrando templates individuales..."

curl -X POST "http://localhost:7007/api/catalog/locations" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "url", 
    "target": "https://github.com/giovanemere/demo-infra-ai-agent-template-idp/blob/main/templates/ai-infrastructure-project/template.yaml"
  }' && echo "✅ Template ai-infrastructure-project registrado"

# Verificar templates registrados
echo "🔍 Verificando templates registrados..."
sleep 5

curl -s "http://localhost:7007/api/catalog/entities?filter=kind=template" | \
  python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    templates = [item['metadata']['name'] for item in data.get('items', [])]
    if templates:
        print('✅ Templates encontrados:', ', '.join(templates))
    else:
        print('⚠️ No se encontraron templates')
except:
    print('❌ Error al verificar templates')
"

echo ""
echo "🎯 Para ver los templates:"
echo "  1. Ir a http://localhost:3000"
echo "  2. Hacer clic en 'Create Component'"
echo "  3. Los templates deberían aparecer en la lista"
echo ""
echo "🔄 Si no aparecen, espera 2-5 minutos para que Backstage sincronice"
