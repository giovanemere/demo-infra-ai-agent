#!/bin/bash

echo "🔍 Verificando acceso a templates en Backstage..."

# Verificar si Backstage está corriendo
if ! curl -s http://localhost:3000 > /dev/null; then
    echo "❌ Backstage no está disponible en :3000"
    echo "Iniciando Backstage..."
    cd /home/giovanemere/demos/backstage-idp/infra-ai-backstage
    nohup yarn start > ../../backstage.log 2>&1 &
    echo "⏳ Esperando 30 segundos para que Backstage inicie..."
    sleep 30
fi

# Verificar templates disponibles
echo "📋 Verificando templates en GitHub..."
echo "Templates disponibles en el repositorio:"
curl -s https://api.github.com/repos/giovanemere/demo-infra-ai-agent-template-idp/contents/templates | \
  python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if isinstance(data, list):
        templates = [item['name'] for item in data if item['type'] == 'dir']
        for template in templates:
            print(f'  ✅ {template}')
    else:
        print('  ⚠️ No se pudieron obtener los templates')
except Exception as e:
    print(f'  ❌ Error: {e}')
"

echo ""
echo "🌐 URLs para verificar:"
echo "  📱 Frontend: http://localhost:3000"
echo "  🔧 Create: http://localhost:3000/create"
echo "  📊 Catalog: http://localhost:3000/catalog"
echo ""
echo "📝 Instrucciones:"
echo "  1. Abrir http://localhost:3000 en el navegador"
echo "  2. Hacer clic en 'Create Component' en el menú lateral"
echo "  3. Deberías ver los templates disponibles"
echo "  4. Si no aparecen, esperar 2-5 minutos para sincronización"
echo ""
echo "🔄 Para forzar sincronización:"
echo "  1. Ir a http://localhost:3000/catalog"
echo "  2. Hacer clic en 'Register Existing Component'"
echo "  3. Pegar: https://github.com/giovanemere/demo-infra-ai-agent-template-idp/blob/main/catalog-info.yaml"
echo "  4. Hacer clic en 'Analyze'"
