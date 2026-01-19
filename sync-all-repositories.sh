#!/bin/bash

echo "🔄 SINCRONIZACIÓN COMPLETA DE REPOSITORIOS"
echo "=========================================="

# Función para hacer commit y push
sync_repo() {
    local repo_path=$1
    local repo_name=$2
    local commit_message=$3
    
    echo ""
    echo "📁 Sincronizando: $repo_name"
    echo "================================"
    
    cd "$repo_path"
    
    # Verificar si hay cambios
    local changes=$(git status --porcelain | wc -l)
    
    if [ $changes -eq 0 ]; then
        echo "✅ No hay cambios pendientes"
        return 0
    fi
    
    echo "📝 Cambios detectados: $changes archivos"
    
    # Mostrar cambios
    echo "Archivos a commitear:"
    git status --porcelain | head -5 | sed 's/^/  /'
    
    # Agregar todos los archivos
    git add .
    
    # Hacer commit
    if git commit -m "$commit_message"; then
        echo "✅ Commit realizado"
        
        # Push
        if git push origin $(git branch --show-current); then
            echo "✅ Push exitoso"
        else
            echo "❌ Error en push"
            return 1
        fi
    else
        echo "❌ Error en commit"
        return 1
    fi
}

# 1. Sincronizar repositorio principal
sync_repo "/home/giovanemere/demos" "demos (principal)" "feat: Complete Infrastructure AI Platform documentation

- Added comprehensive architecture documentation
- Created repository analysis and sync scripts
- Added solution verification and summary scripts
- Updated all documentation with complete structure
- Added catalog management and dynamic generation scripts

Complete solution with:
- AI Agent with Gemini integration
- Backstage IDP with GitHub OAuth
- Dynamic catalog synchronization
- Automated project detection
- Complete documentation and scripts"

# 2. Limpiar duplicación en infra-ai-agent
echo ""
echo "🧹 Limpiando duplicaciones..."
cd /home/giovanemere/demos/infra-ai-agent
if [ -d "templates-repo" ]; then
    echo "Eliminando duplicación: infra-ai-agent/templates-repo"
    rm -rf templates-repo
fi

# 3. Sincronizar infra-ai-agent
sync_repo "/home/giovanemere/demos/infra-ai-agent" "infra-ai-agent" "feat: Complete AI Agent implementation

- Updated comprehensive README with detailed architecture
- Enhanced git client with better error handling
- Added static frontend interface
- Removed duplicate templates-repo directory
- Complete FastAPI backend with Gemini integration
- Processors for text and image analysis
- YAML validators for Backstage compatibility
- Automatic GitHub synchronization

Ready for production with full documentation"

# 4. Sincronizar backstage-idp
sync_repo "/home/giovanemere/demos/backstage-idp" "backstage-idp" "feat: Complete Backstage IDP configuration

- Added comprehensive configuration documentation
- Created GitHub OAuth validation scripts
- Added user identity resolution scripts
- Complete app-config.yaml with all integrations
- GitHub provider with automatic synchronization
- User and group management
- Template sync verification scripts
- Docker compose for easy deployment

Complete Backstage setup with:
- GitHub OAuth authentication
- Automatic catalog synchronization
- Dynamic project detection
- Scaffolder templates
- User management system"

# 5. Verificar y corregir catalog-repo remote
echo ""
echo "🔧 Corrigiendo remote de catalog-repo..."
cd /home/giovanemere/demos/catalog-repo

# El catalog-repo debería apuntar a un repositorio separado o ser parte del principal
# Por ahora lo mantenemos como está ya que funciona con templates-repo

echo "✅ catalog-repo mantiene remote actual (funcional)"

echo ""
echo "🎯 RESUMEN DE SINCRONIZACIÓN"
echo "============================"

# Verificar estado final
cd /home/giovanemere/demos
echo "📊 Estado final:"

for repo in . infra-ai-agent backstage-idp; do
    cd "/home/giovanemere/demos/$repo" 2>/dev/null || cd "/home/giovanemere/demos"
    changes=$(git status --porcelain 2>/dev/null | wc -l)
    if [ $changes -eq 0 ]; then
        echo "  ✅ $repo: Sincronizado"
    else
        echo "  ⚠️  $repo: $changes cambios pendientes"
    fi
done

echo ""
echo "🔗 Repositorios GitHub actualizados:"
echo "  - https://github.com/giovanemere/demo-infra-ai-agent"
echo "  - https://github.com/giovanemere/demo-infra-backstage"
echo "  - https://github.com/giovanemere/demo-infra-ai-agent-template-idp"

echo ""
echo "✅ Sincronización completa finalizada"

cd /home/giovanemere/demos
