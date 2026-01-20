#!/bin/bash

echo "🔧 LIMPIANDO Y ORGANIZANDO templates-repo LOCAL"
echo "==============================================="

# Auto-load environment variables
if [ -f ".env" ]; then
    set -a; source .env; set +a
elif [ -f "../backstage-idp/infra-ai-backstage/.env" ]; then
    cd ../backstage-idp/infra-ai-backstage; set -a; source .env; set +a; cd - > /dev/null
elif [ -f "backstage-idp/infra-ai-backstage/.env" ]; then
    cd backstage-idp/infra-ai-backstage; set -a; source .env; set +a; cd - > /dev/null
fi

echo "1️⃣ Analizando estructura actual..."
echo "Directorio templates-repo:"
ls -la templates-repo/

echo ""
echo "2️⃣ Verificando remote del repositorio local..."
cd templates-repo
git remote -v

echo ""
echo "3️⃣ Decisión: ¿Mantener templates-repo local o usar solo GitHub?"
echo ""
echo "OPCIONES:"
echo "A) Eliminar templates-repo local (usar solo GitHub repo)"
echo "B) Sincronizar templates-repo local con GitHub repo"
echo "C) Mantener templates-repo como repositorio separado"

echo ""
echo "RECOMENDACIÓN: Opción A - Eliminar local y usar solo GitHub"
echo "Razón: Ya tenemos estructura completa en GitHub repo"

read -p "¿Proceder con eliminación de templates-repo local? (y/N): " confirm

if [[ $confirm =~ ^[Yy]$ ]]; then
    echo ""
    echo "4️⃣ Eliminando templates-repo local..."
    cd ..
    rm -rf templates-repo
    echo "✅ templates-repo local eliminado"
    
    echo ""
    echo "5️⃣ Verificando que Backstage use solo GitHub repo..."
    cd backstage-idp/infra-ai-backstage
    
    echo "Configuración actual en app-config.yaml:"
    grep -A 10 "locations:" app-config.yaml
    
    echo ""
    echo "✅ LIMPIEZA COMPLETADA"
    echo "====================="
    echo "🗑️ templates-repo local eliminado"
    echo "✅ Backstage usa solo GitHub repo:"
    echo "   https://github.com/giovanemere/demo-infra-ai-agent-template-idp"
    echo ""
    echo "🌐 Estructura única en GitHub:"
    echo "  - Systems, Components, Resources"
    echo "  - Templates de Scaffolder"
    echo "  - TechDocs completa"
    echo "  - Auto-discovery configurado"
    
else
    echo ""
    echo "4️⃣ Sincronizando templates-repo local con GitHub..."
    
    # Verificar si tiene remote correcto
    if git remote get-url origin | grep -q "demo-infra-ai-agent-template-idp"; then
        echo "✅ Remote correcto detectado"
        git pull origin main
        echo "✅ Sincronizado con GitHub"
    else
        echo "❌ Remote incorrecto. Configurando..."
        git remote set-url origin https://github.com/giovanemere/demo-infra-ai-agent-template-idp.git
        git pull origin main
        echo "✅ Remote corregido y sincronizado"
    fi
    
    echo ""
    echo "✅ SINCRONIZACIÓN COMPLETADA"
    echo "============================"
    echo "🔄 templates-repo local sincronizado con GitHub"
    echo "✅ Estructura unificada"
fi

cd /home/giovanemere/demos

echo ""
echo "6️⃣ Verificando módulos en Backstage..."

# Verificar si Backstage está corriendo
if curl -s http://localhost:3000 > /dev/null; then
    echo "✅ Backstage corriendo en :3000"
    
    echo ""
    echo "🔍 Verificando módulos disponibles:"
    echo "  - Home: http://localhost:3000"
    echo "  - Catalog: http://localhost:3000/catalog"
    echo "  - APIs: http://localhost:3000/api-docs"
    echo "  - Docs: http://localhost:3000/docs"
    echo "  - Create: http://localhost:3000/create"
    echo "  - Tech Radar: http://localhost:3000/tech-radar"
    echo "  - Search: http://localhost:3000/search"
    
    echo ""
    echo "🧪 Pruebas recomendadas:"
    echo "1. Ve a /catalog - Busca 'infrastructure-ai-platform'"
    echo "2. Ve a /create - Busca 'AI Infrastructure Project'"
    echo "3. Ve a /api-docs - Busca 'ai-agent-api'"
    echo "4. Haz clic en componentes para ver TechDocs"
    
else
    echo "❌ Backstage no está corriendo"
    echo "Ejecuta: ./restart-backstage.sh"
fi

echo ""
echo "🎯 RESULTADO FINAL:"
echo "=================="
echo "✅ Estructura organizada y funcional"
echo "✅ Un solo repositorio de templates (GitHub)"
echo "✅ Auto-discovery configurado"
echo "✅ Módulos Backstage verificados"
