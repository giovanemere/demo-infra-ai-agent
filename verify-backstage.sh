#!/bin/bash

echo "🔍 VERIFICACIÓN COMPLETA DE BACKSTAGE"
echo "===================================="

# Verificar servicios
echo -e "\n🌐 SERVICIOS:"
echo "- Backstage Frontend: $(curl -s -o /dev/null -w '%{http_code}' http://localhost:3000)"
echo "- Backstage Backend: $(curl -s -o /dev/null -w '%{http_code}' http://localhost:7007/api/catalog/entities 2>/dev/null || echo 'No disponible')"

# Verificar templates
echo -e "\n📋 TEMPLATES DISPONIBLES:"
curl -s "http://localhost:7007/api/catalog/entities?filter=kind=template" 2>/dev/null | grep -o '"name":"[^"]*"' | sed 's/"name":"//g' | sed 's/"//g' | sed 's/^/- /' || echo "No se pudieron obtener templates"

# Verificar componentes
echo -e "\n🔧 COMPONENTES:"
curl -s "http://localhost:7007/api/catalog/entities?filter=kind=component" 2>/dev/null | grep -o '"name":"[^"]*"' | sed 's/"name":"//g' | sed 's/"//g' | sed 's/^/- /' || echo "No se pudieron obtener componentes"

# Verificar sistemas
echo -e "\n🏗️ SISTEMAS:"
curl -s "http://localhost:7007/api/catalog/entities?filter=kind=system" 2>/dev/null | grep -o '"name":"[^"]*"' | sed 's/"name":"//g' | sed 's/"//g' | sed 's/^/- /' || echo "No se pudieron obtener sistemas"

# Verificar errores recientes
echo -e "\n⚠️ ERRORES RECIENTES:"
cd /home/giovanemere/demos/backstage-idp/infra-ai-backstage
if tail -50 backstage.log | grep -i error | tail -3; then
    echo "Se encontraron errores (mostrando últimos 3)"
else
    echo "✅ No hay errores recientes"
fi

echo -e "\n🎯 ACCESO:"
echo "- Backstage: http://localhost:3000"
echo "- Create Templates: http://localhost:3000/create"
echo "- Catalog: http://localhost:3000/catalog"

echo -e "\n✅ Verificación completada"
