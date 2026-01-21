#!/bin/bash

# Script para corregir archivos YAML problemáticos en el repositorio de templates

echo "🔧 Corrigiendo archivos YAML problemáticos..."

# Función para limpiar descripciones largas
fix_yaml_descriptions() {
    local file="$1"
    echo "Corrigiendo: $file"
    
    # Crear backup
    cp "$file" "$file.backup"
    
    # Usar sed para corregir descripciones largas
    sed -i 's/description: \(.*\): \(.*\)/description: "\1"/' "$file"
    sed -i 's/description: \([^"]*\)$/description: "\1"/' "$file"
    
    # Verificar si el YAML es válido ahora
    if python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
        echo "✅ $file corregido exitosamente"
        rm "$file.backup"
    else
        echo "❌ Error en $file, restaurando backup"
        mv "$file.backup" "$file"
    fi
}

# Encontrar y corregir archivos problemáticos
cd /home/giovanemere/demos/templates-repo

# Corregir archivos en projects/
for project_dir in projects/*/; do
    if [ -f "$project_dir/catalog-info.yaml" ]; then
        fix_yaml_descriptions "$project_dir/catalog-info.yaml"
    fi
done

echo "🎯 Corrección completada"
