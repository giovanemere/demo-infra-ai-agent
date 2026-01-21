#!/bin/bash

# Verificar estado del catálogo de Backstage

BACKSTAGE_URL="http://localhost:3000"

echo "🔍 Verificando catálogo de Backstage..."

# Verificar que Backstage esté corriendo
if ! curl -s --connect-timeout 5 "$BACKSTAGE_URL" > /dev/null; then
    echo "❌ Backstage no está corriendo"
    exit 1
fi

echo "✅ Backstage está corriendo"

# Obtener entidades del catálogo
echo ""
echo "📋 Entidades en el catálogo:"

ENTITIES=$(curl -s "$BACKSTAGE_URL/api/catalog/entities" 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$ENTITIES" ]; then
    # Contar entidades por tipo
    echo "$ENTITIES" | jq -r '.[] | .kind' 2>/dev/null | sort | uniq -c | while read count kind; do
        echo "  $kind: $count"
    done
    
    echo ""
    echo "🏗️  Templates disponibles:"
    echo "$ENTITIES" | jq -r '.[] | select(.kind == "Template") | "  - " + .metadata.name + " (" + .metadata.title + ")"' 2>/dev/null
    
    echo ""
    echo "🧩 Componentes disponibles:"
    echo "$ENTITIES" | jq -r '.[] | select(.kind == "Component") | "  - " + .metadata.name + " (" + .metadata.title + ")"' 2>/dev/null
    
    echo ""
    echo "🏢 Sistemas disponibles:"
    echo "$ENTITIES" | jq -r '.[] | select(.kind == "System") | "  - " + .metadata.name + " (" + .metadata.title + ")"' 2>/dev/null
    
else
    echo "⚠️  No se pudieron obtener las entidades del catálogo"
fi

echo ""
echo "🌐 URLs útiles:"
echo "  🎭 Catalog: $BACKSTAGE_URL/catalog"
echo "  🏗️  Create: $BACKSTAGE_URL/create"
echo "  📥 Import: $BACKSTAGE_URL/catalog-import"
