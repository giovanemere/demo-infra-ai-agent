#!/bin/bash

echo "🔍 ANÁLISIS DE REPOSITORIOS - Infrastructure AI Platform"
echo "======================================================="

# Función para analizar un repositorio
analyze_repo() {
    local repo_path=$1
    local repo_name=$2
    local expected_remote=$3
    
    echo ""
    echo "📁 REPOSITORIO: $repo_name"
    echo "================================"
    
    if [ ! -d "$repo_path" ]; then
        echo "❌ Directorio no existe: $repo_path"
        return 1
    fi
    
    cd "$repo_path"
    
    # Verificar si es un repositorio git
    if [ ! -d ".git" ]; then
        echo "❌ No es un repositorio Git"
        return 1
    fi
    
    # Información básica
    echo "📍 Ubicación: $repo_path"
    echo "🌿 Branch: $(git branch --show-current 2>/dev/null || echo 'No branch')"
    
    # Remote
    local current_remote=$(git remote get-url origin 2>/dev/null || echo "No remote")
    echo "🔗 Remote: $current_remote"
    
    if [ "$current_remote" != "$expected_remote" ] && [ "$expected_remote" != "" ]; then
        echo "⚠️  Remote incorrecto. Esperado: $expected_remote"
    fi
    
    # Estado
    local changes=$(git status --porcelain 2>/dev/null | wc -l)
    echo "📊 Cambios pendientes: $changes"
    
    if [ $changes -gt 0 ]; then
        echo "📝 Archivos modificados:"
        git status --porcelain | head -10 | sed 's/^/    /'
        if [ $changes -gt 10 ]; then
            echo "    ... y $((changes - 10)) más"
        fi
    fi
    
    # Último commit
    echo "💾 Último commit: $(git log -1 --oneline 2>/dev/null || echo 'No commits')"
    
    # Verificar si está sincronizado con remote
    if git remote get-url origin >/dev/null 2>&1; then
        local behind=$(git rev-list HEAD..origin/$(git branch --show-current) --count 2>/dev/null || echo "?")
        local ahead=$(git rev-list origin/$(git branch --show-current)..HEAD --count 2>/dev/null || echo "?")
        
        if [ "$behind" != "?" ] && [ "$ahead" != "?" ]; then
            echo "🔄 Sincronización: $ahead commits adelante, $behind commits atrás"
        fi
    fi
    
    cd - >/dev/null
}

# Analizar cada repositorio
analyze_repo "/home/giovanemere/demos" "demos (principal)" "git@github.com:giovanemere/demo-infra-ai-agent.git"

analyze_repo "/home/giovanemere/demos/infra-ai-agent" "infra-ai-agent" "git@github.com:giovanemere/demo-infra-ai-agent.git"

analyze_repo "/home/giovanemere/demos/backstage-idp" "backstage-idp" "git@github.com:giovanemere/demo-infra-backstage.git"

analyze_repo "/home/giovanemere/demos/catalog-repo" "catalog-repo" "git@github.com:giovanemere/demo-infra-catalog.git"

analyze_repo "/home/giovanemere/demos/templates-repo" "templates-repo" "git@github.com:giovanemere/demo-infra-ai-agent-template-idp.git"

echo ""
echo "🎯 RESUMEN DE PROBLEMAS DETECTADOS"
echo "=================================="

problems=0

# Verificar repositorio principal
cd /home/giovanemere/demos
if [ $(git status --porcelain | wc -l) -gt 0 ]; then
    echo "❌ Repositorio principal tiene cambios sin commitear"
    problems=$((problems + 1))
fi

# Verificar infra-ai-agent
cd /home/giovanemere/demos/infra-ai-agent
if [ $(git status --porcelain | wc -l) -gt 0 ]; then
    echo "❌ infra-ai-agent tiene cambios sin commitear"
    problems=$((problems + 1))
fi

# Verificar backstage-idp
cd /home/giovanemere/demos/backstage-idp
if [ $(git status --porcelain | wc -l) -gt 0 ]; then
    echo "❌ backstage-idp tiene cambios sin commitear"
    problems=$((problems + 1))
fi

# Verificar duplicación
if [ -d "/home/giovanemere/demos/infra-ai-agent/templates-repo" ]; then
    echo "⚠️  Duplicación detectada: infra-ai-agent/templates-repo"
    problems=$((problems + 1))
fi

# Verificar remotes incorrectos
cd /home/giovanemere/demos/catalog-repo
current_remote=$(git remote get-url origin 2>/dev/null)
if [[ "$current_remote" == *"template-idp"* ]]; then
    echo "⚠️  catalog-repo apunta al repositorio de templates (incorrecto)"
    problems=$((problems + 1))
fi

echo ""
if [ $problems -eq 0 ]; then
    echo "✅ No se detectaron problemas críticos"
else
    echo "🔧 Se detectaron $problems problemas que requieren atención"
fi

echo ""
echo "📋 RECOMENDACIONES"
echo "=================="
echo "1. Hacer commit y push de cambios pendientes"
echo "2. Crear repositorios separados para cada componente"
echo "3. Eliminar duplicaciones (infra-ai-agent/templates-repo)"
echo "4. Configurar remotes correctos"
echo "5. Sincronizar todos los repositorios"

cd /home/giovanemere/demos
