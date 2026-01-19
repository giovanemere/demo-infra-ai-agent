#!/bin/bash

# =============================================================================
# Infrastructure AI Platform - Deployment Script
# =============================================================================

set -e

echo "🚀 Implementando Infrastructure AI Platform en GitHub..."

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# Verificar prerequisitos
check_prerequisites() {
    log_info "Verificando prerequisitos..."
    
    command -v docker >/dev/null 2>&1 || { log_error "Docker requerido"; exit 1; }
    command -v node >/dev/null 2>&1 || { log_error "Node.js requerido"; exit 1; }
    command -v python3 >/dev/null 2>&1 || { log_error "Python3 requerido"; exit 1; }
    command -v gh >/dev/null 2>&1 || { log_error "GitHub CLI requerido"; exit 1; }
    
    log_success "Prerequisitos verificados"
}

# Crear repositorios GitHub si no existen
create_github_repos() {
    log_info "Creando repositorios GitHub..."
    
    # PostgreSQL Docker
    if ! gh repo view giovanemere/demo-infra-postgres >/dev/null 2>&1; then
        gh repo create demo-infra-postgres --public --description "PostgreSQL Docker setup for Backstage IDP"
        log_success "Repositorio demo-infra-postgres creado"
    else
        log_warning "Repositorio demo-infra-postgres ya existe"
    fi
    
    # Backstage IDP
    if ! gh repo view giovanemere/demo-infra-backstage >/dev/null 2>&1; then
        gh repo create demo-infra-backstage --public --description "Backstage IDP Platform configuration"
        log_success "Repositorio demo-infra-backstage creado"
    else
        log_warning "Repositorio demo-infra-backstage ya existe"
    fi
}

# Subir PostgreSQL Docker a GitHub
deploy_postgres() {
    log_info "Subiendo PostgreSQL Docker a GitHub..."
    
    cd /home/giovanemere/docker/postgres
    
    if [ ! -d ".git" ]; then
        git init
        git add .
        git commit -m "Initial PostgreSQL Docker setup for Backstage"
        git branch -M main
        git remote add origin git@github.com:giovanemere/demo-infra-postgres.git
        git push -u origin main
        log_success "PostgreSQL Docker subido a GitHub"
    else
        git add .
        git commit -m "Update PostgreSQL configuration" || true
        git push origin main
        log_success "PostgreSQL Docker actualizado en GitHub"
    fi
    
    cd /home/giovanemere/demos
}

# Subir Backstage a GitHub
deploy_backstage() {
    log_info "Subiendo Backstage IDP a GitHub..."
    
    cd /home/giovanemere/demos/backstage-idp
    
    if [ ! -d ".git" ]; then
        git init
        git add .
        git commit -m "Initial Backstage IDP configuration"
        git branch -M main
        git remote add origin git@github.com:giovanemere/demo-infra-backstage.git
        git push -u origin main
        log_success "Backstage IDP subido a GitHub"
    else
        git add .
        git commit -m "Update Backstage configuration" || true
        git push origin main
        log_success "Backstage IDP actualizado en GitHub"
    fi
    
    cd /home/giovanemere/demos
}

# Actualizar repositorio del AI Agent
update_ai_agent() {
    log_info "Actualizando AI Agent en GitHub..."
    
    cd /home/giovanemere/demos/infra-ai-agent
    
    git add .
    git commit -m "Update AI Agent with complete platform integration" || true
    git push origin main
    log_success "AI Agent actualizado en GitHub"
    
    cd /home/giovanemere/demos
}

# Crear archivo de configuración de deployment
create_deployment_config() {
    log_info "Creando configuración de deployment..."
    
    cat > deployment-config.yml << 'EOF'
# Infrastructure AI Platform - Deployment Configuration
platform:
  name: "Infrastructure AI Platform"
  version: "1.0.0"
  
repositories:
  ai_agent: "git@github.com:giovanemere/demo-infra-ai-agent.git"
  templates: "git@github.com:giovanemere/demo-infra-ai-agent-template-idp.git"
  backstage: "git@github.com:giovanemere/backstage-idp.git"
  postgres: "git@github.com:giovanemere/postgres-docker.git"

services:
  postgres:
    port: 5432
    database: "backstage"
    user: "backstage"
    password: "backstage123"
  
  ai_agent:
    port: 8000
    api_key_required: true
  
  backstage:
    ui_port: 3000
    api_port: 7007
    github_token_required: true

deployment:
  order:
    - postgres
    - ai_agent
    - backstage
  
  health_checks:
    - "http://localhost:8000/health"
    - "http://localhost:3000"
    - "http://localhost:7007"
    - "nc -z localhost 5432"
EOF
    
    log_success "Configuración de deployment creada"
}

# Crear script de deployment para nuevos entornos
create_deployment_script() {
    log_info "Creando script de deployment..."
    
    cat > deploy-new-environment.sh << 'EOF'
#!/bin/bash

# Script para deployment en nuevo entorno
echo "🚀 Deployando Infrastructure AI Platform..."

# Crear directorio de trabajo
mkdir -p ~/infrastructure-ai-platform
cd ~/infrastructure-ai-platform

# Clonar repositorios
echo "📦 Clonando repositorios..."
git clone git@github.com:giovanemere/demo-infra-ai-agent.git
git clone git@github.com:giovanemere/demo-infra-ai-agent-template-idp.git
git clone git@github.com:giovanemere/demo-infra-backstage.git
git clone git@github.com:giovanemere/demo-infra-postgres.git

# Setup PostgreSQL
echo "🐘 Configurando PostgreSQL..."
cd demo-infra-postgres
./start-postgres.sh
cd ..

# Setup AI Agent
echo "🤖 Configurando AI Agent..."
cd demo-infra-ai-agent
./setup.sh
echo "⚠️  Configura GEMINI_API_KEY en .env"
cd ..

# Setup Backstage
echo "🎭 Configurando Backstage..."
cd demo-infra-backstage
./setup-backstage.sh
echo "⚠️  Configura GITHUB_TOKEN en infra-ai-backstage/.env"
cd ..

echo "✅ Deployment completado!"
echo "📋 Próximos pasos:"
echo "1. Configurar GEMINI_API_KEY"
echo "2. Configurar GITHUB_TOKEN"
echo "3. Ejecutar ./start-platform.sh"
EOF
    
    chmod +x deploy-new-environment.sh
    log_success "Script de deployment creado"
}

# Crear documentación de deployment
create_deployment_docs() {
    log_info "Creando documentación de deployment..."
    
    cat > DEPLOYMENT_GUIDE.md << 'EOF'
# 🚀 Infrastructure AI Platform - Deployment Guide

## 📋 Repositorios GitHub

| Repositorio | Propósito | URL |
|-------------|-----------|-----|
| demo-infra-ai-agent | AI Agent (Python + FastAPI) | https://github.com/giovanemere/demo-infra-ai-agent |
| demo-infra-ai-agent-template-idp | Templates generados | https://github.com/giovanemere/demo-infra-ai-agent-template-idp |
| backstage-idp | Backstage IDP Platform | https://github.com/giovanemere/backstage-idp |
| postgres-docker | PostgreSQL Docker setup | https://github.com/giovanemere/postgres-docker |

## 🔧 Deployment en Nuevo Entorno

### Prerequisitos
- Docker
- Node.js 18+
- Python 3.8+
- GitHub CLI
- SSH configurado para GitHub

### Deployment Automático
```bash
curl -sSL https://raw.githubusercontent.com/giovanemere/demo-infra-backstage/main/deploy-new-environment.sh | bash
```

### Deployment Manual
```bash
# 1. Clonar repositorios
mkdir ~/infrastructure-ai-platform && cd ~/infrastructure-ai-platform
git clone git@github.com:giovanemere/demo-infra-ai-agent.git
git clone git@github.com:giovanemere/demo-infra-ai-agent-template-idp.git
git clone git@github.com:giovanemere/demo-infra-backstage.git
git clone git@github.com:giovanemere/demo-infra-postgres.git

# 2. PostgreSQL
cd demo-infra-postgres && ./start-postgres.sh && cd ..

# 3. AI Agent
cd demo-infra-ai-agent && ./setup.sh && cd ..

# 4. Backstage
cd demo-infra-backstage && ./setup-backstage.sh && cd ..
```

## ⚙️ Configuración Requerida

### AI Agent (.env)
```bash
GEMINI_API_KEY=tu_gemini_api_key
AGENT_REPO=git@github.com:giovanemere/demo-infra-ai-agent.git
TEMPLATES_REPO=git@github.com:giovanemere/demo-infra-ai-agent-template-idp.git
```

### Backstage (.env)
```bash
GITHUB_TOKEN=ghp_tu_github_token
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=backstage
POSTGRES_PASSWORD=backstage123
POSTGRES_DB=backstage
```

## 🚀 Iniciar Plataforma

```bash
cd ~/infrastructure-ai-platform
./start-platform.sh
```

## 🌐 URLs de Acceso

- 🤖 AI Agent: http://localhost:8000
- 📚 AI Agent Docs: http://localhost:8000/docs
- 🎭 Backstage UI: http://localhost:3000
- 🔧 Backstage API: http://localhost:7007
- 🐘 PostgreSQL: localhost:5432

## 🧪 Testing

```bash
# Test AI Agent
curl -X POST "http://localhost:8000/process-text" \
  -F "description=Una aplicación web con S3, CloudFront y Lambda"

# Verificar en Backstage
# http://localhost:3000/catalog
```

## 📊 Monitoreo

```bash
# Estado de servicios
./monitor-platform.sh

# Logs
docker logs backstage-postgres
tail -f demo-infra-ai-agent/logs/agent.log
tail -f backstage-idp/infra-ai-backstage/packages/backend/dist/logs/backend.log
```
EOF
    
    log_success "Documentación de deployment creada"
}

# Función principal
main() {
    echo "🏗️ Infrastructure AI Platform Deployment"
    echo "========================================"
    echo ""
    
    check_prerequisites
    create_github_repos
    deploy_postgres
    deploy_backstage
    update_ai_agent
    create_deployment_config
    create_deployment_script
    create_deployment_docs
    
    echo ""
    echo "🎉 Deployment completado exitosamente!"
    echo ""
    echo "📋 Repositorios GitHub creados/actualizados:"
    echo "  🐘 https://github.com/giovanemere/demo-infra-postgres"
    echo "  🎭 https://github.com/giovanemere/demo-infra-backstage"
    echo "  🤖 https://github.com/giovanemere/demo-infra-ai-agent (actualizado)"
    echo "  📁 https://github.com/giovanemere/demo-infra-ai-agent-template-idp (existente)"
    echo ""
    echo "📚 Archivos creados:"
    echo "  deployment-config.yml"
    echo "  deploy-new-environment.sh"
    echo "  DEPLOYMENT_GUIDE.md"
    echo ""
    echo "🚀 Para deployment en nuevo entorno:"
    echo "  curl -sSL https://raw.githubusercontent.com/giovanemere/demo-infra-backstage/main/deploy-new-environment.sh | bash"
}

main "$@"
