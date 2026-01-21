#!/bin/bash

# Script para hacer login automático en Backstage y verificar el catálogo

BACKSTAGE_URL="http://localhost:3000"
BACKEND_URL="http://localhost:7007"

echo "🔐 Configurando acceso a Backstage..."

# Verificar que Backstage esté corriendo
if ! curl -s --connect-timeout 5 "$BACKSTAGE_URL" > /dev/null; then
    echo "❌ Backstage no está corriendo"
    exit 1
fi

# Hacer login como guest
echo "👤 Haciendo login como guest..."
LOGIN_RESPONSE=$(curl -s -X POST "$BACKEND_URL/api/auth/guest/start" \
  -H "Content-Type: application/json" \
  -d '{}' 2>/dev/null)

if echo "$LOGIN_RESPONSE" | grep -q "token"; then
    echo "✅ Login exitoso"
    
    # Extraer token (simplificado)
    TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
    
    if [ -n "$TOKEN" ]; then
        echo "🔑 Token obtenido"
        
        # Probar API con token
        echo "📋 Verificando catálogo con autenticación..."
        ENTITIES=$(curl -s -H "Authorization: Bearer $TOKEN" "$BACKEND_URL/api/catalog/entities" 2>/dev/null)
        
        if [ $? -eq 0 ] && [ -n "$ENTITIES" ]; then
            echo "✅ API del catálogo funcionando"
            echo "$ENTITIES" | head -20
        else
            echo "⚠️  API del catálogo no responde correctamente"
        fi
    else
        echo "⚠️  No se pudo extraer el token"
    fi
else
    echo "⚠️  Login falló o no se requiere"
    echo "Respuesta: $LOGIN_RESPONSE"
fi

echo ""
echo "🌐 Accede manualmente a:"
echo "  Frontend: $BACKSTAGE_URL"
echo "  Backend:  $BACKEND_URL"
