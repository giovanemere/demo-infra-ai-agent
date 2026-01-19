#!/bin/bash

echo "🔧 Corrigiendo carga de variables en todos los scripts..."

# Lista de scripts que necesitan corrección
SCRIPTS=(
    "/home/giovanemere/demos/backstage-idp/start-backstage-simple.sh"
    "/home/giovanemere/demos/backstage-idp/setup-backstage.sh"
    "/home/giovanemere/demos/backstage-idp/configure-github-auth.sh"
    "/home/giovanemere/demos/backstage-idp/validate-github-auth.sh"
    "/home/giovanemere/demos/backstage-idp/test-github-auth.sh"
    "/home/giovanemere/demos/backstage-idp/fix-user-identity.sh"
    "/home/giovanemere/demos/backstage-idp/check-users.sh"
    "/home/giovanemere/demos/backstage-idp/force-fix-user.sh"
)

# Función para corregir un script
fix_script() {
    local script_path="$1"
    
    if [ ! -f "$script_path" ]; then
        echo "⚠️  Script no encontrado: $script_path"
        return
    fi
    
    echo "🔄 Corrigiendo: $(basename "$script_path")"
    
    # Crear backup
    cp "$script_path" "$script_path.backup"
    
    # Reemplazar patrones problemáticos
    sed -i 's/export $(cat \.env | grep -v "^#" | xargs)/set -a\nsource .env\nset +a/g' "$script_path"
    sed -i 's/export \$(cat \.env | grep -v "^#" | xargs)/set -a\nsource .env\nset +a/g' "$script_path"
    
    echo "✅ Corregido: $(basename "$script_path")"
}

# Corregir cada script
for script in "${SCRIPTS[@]}"; do
    fix_script "$script"
done

echo ""
echo "✅ Scripts principales ya corregidos:"
echo "  - restart-backstage.sh"
echo "  - start-platform.sh"
echo "  - verify-backstage-fixes.sh"
echo "  - diagnose-backstage.sh"
echo "  - start-backstage-fixed.sh (nuevo)"

echo ""
echo "🎯 PATRÓN CORRECTO para cargar variables:"
echo "  set -a"
echo "  source .env"
echo "  set +a"

echo ""
echo "❌ PATRÓN INCORRECTO (no usar):"
echo "  export \$(cat .env | grep -v '^#' | xargs)"

echo ""
echo "🚀 Para iniciar Backstage correctamente:"
echo "  ./start-backstage-fixed.sh"
