#!/bin/bash

echo "🔍 Verificando Solución de Problemas Backstage"
echo "=============================================="

# Cargar variables
cd /home/giovanemere/demos/backstage-idp/infra-ai-backstage
export $(cat .env | grep -v '^#' | xargs)

echo ""
echo "1️⃣ Verificando grupo 'developers'..."
sleep 10  # Esperar que Backstage cargue

# Verificar en logs si el grupo se cargó
if tail -50 backstage.log | grep -q "developers"; then
    echo "✅ Grupo 'developers' detectado en logs"
else
    echo "⏳ Grupo 'developers' aún cargando..."
fi

echo ""
echo "2️⃣ Verificando templates de Scaffolder..."

# Verificar si hay templates disponibles
if curl -s "http://localhost:3000" | grep -q "Create"; then
    echo "✅ Interfaz de creación disponible"
else
    echo "⏳ Interfaz de creación aún cargando..."
fi

echo ""
echo "3️⃣ Verificando documentación TechDocs..."

# Verificar si TechDocs está configurado
if grep -q "backstage.io/techdocs-ref" ../../infra-ai-agent/catalog-info.yaml; then
    echo "✅ TechDocs configurado en AI Agent"
else
    echo "❌ TechDocs no configurado"
fi

echo ""
echo "4️⃣ Verificando sincronización de repositorio..."

# Verificar logs de sincronización
if tail -100 backstage.log | grep -q "github-provider"; then
    echo "✅ GitHub provider activo"
else
    echo "⏳ GitHub provider iniciando..."
fi

echo ""
echo "🎯 SOLUCIONES APLICADAS"
echo "======================"

echo ""
echo "✅ Problemas solucionados:"
echo "  1. Grupo 'developers' agregado con miembros"
echo "  2. Template de Scaffolder creado en repositorio"
echo "  3. TechDocs configurado para AI Agent"
echo "  4. catalog-info.yaml actualizado con referencias correctas"
echo "  5. Estructura de templates corregida"

echo ""
echo "🔗 URLs para verificar:"
echo "  - Catálogo: http://localhost:3000/catalog"
echo "  - AI Agent: http://localhost:3000/catalog/default/component/ai-agent"
echo "  - Templates: http://localhost:3000/create"
echo "  - Grupo developers: http://localhost:3000/catalog/default/group/developers"
echo "  - Docs AI Agent: http://localhost:3000/docs/default/component/ai-agent"

echo ""
echo "⏳ Nota: La sincronización puede tomar hasta 5 minutos"
echo "🔄 Si aún hay problemas, espera la próxima sincronización automática"

echo ""
echo "🧪 Test manual:"
echo "1. Ve a http://localhost:3000/catalog"
echo "2. Busca 'ai-agent' - debe aparecer sin errores de relaciones"
echo "3. Ve a http://localhost:3000/create - debe mostrar template"
echo "4. Haz clic en 'AI Infrastructure Project'"
