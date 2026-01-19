#!/bin/bash

echo "🔧 Corrigiendo TODOS los scripts para cargar .env automáticamente..."

# Función para agregar carga de .env a un script
add_env_loading() {
    local script="$1"
    
    if [ ! -f "$script" ]; then
        return
    fi
    
    # Skip si ya tiene carga de .env
    if grep -q "set -a" "$script" || grep -q "source .env" "$script"; then
        echo "✅ $(basename "$script") - Ya tiene carga de .env"
        return
    fi
    
    echo "🔄 $(basename "$script") - Agregando carga de .env"
    
    # Crear backup
    cp "$script" "$script.backup"
    
    # Crear archivo temporal
    temp_file=$(mktemp)
    
    # Agregar carga de .env después del shebang
    {
        head -1 "$script"  # Shebang
        echo ""
        echo "# Auto-load environment variables"
        echo "if [ -f \".env\" ]; then"
        echo "    set -a"
        echo "    source .env"
        echo "    set +a"
        echo "elif [ -f \"../backstage-idp/infra-ai-backstage/.env\" ]; then"
        echo "    cd ../backstage-idp/infra-ai-backstage"
        echo "    set -a"
        echo "    source .env"
        echo "    set +a"
        echo "    cd - > /dev/null"
        echo "elif [ -f \"backstage-idp/infra-ai-backstage/.env\" ]; then"
        echo "    cd backstage-idp/infra-ai-backstage"
        echo "    set -a"
        echo "    source .env"
        echo "    set +a"
        echo "    cd - > /dev/null"
        echo "fi"
        echo ""
        tail -n +2 "$script"  # Resto del archivo
    } > "$temp_file"
    
    # Reemplazar archivo original
    mv "$temp_file" "$script"
    chmod +x "$script"
}

# Encontrar todos los scripts .sh
find /home/giovanemere/demos -name "*.sh" -not -name "*.backup" | while read script; do
    add_env_loading "$script"
done

echo ""
echo "✅ COMPLETADO - Todos los scripts ahora cargan .env automáticamente"
echo ""
echo "🎯 Carga automática agregada a:"
echo "  - Scripts principales"
echo "  - Scripts de backstage-idp/"
echo "  - Scripts de infra-ai-agent/"
echo "  - Scripts de utilidades"
echo ""
echo "📋 La carga busca .env en:"
echo "  1. Directorio actual"
echo "  2. ../backstage-idp/infra-ai-backstage/"
echo "  3. backstage-idp/infra-ai-backstage/"
