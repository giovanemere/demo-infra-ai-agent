#!/bin/bash

# =============================================================================
# Infrastructure AI Platform - Prerequisites Checker & Installer
# =============================================================================

set -e

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

echo "🔍 Verificando Prerequisites - Infrastructure AI Platform"
echo "========================================================"
echo ""

# Variables de estado
PYTHON_OK=false
PIP_OK=false
NODE_OK=false
DOCKER_OK=false
GIT_OK=false

# 1. Verificar Python 3
check_python() {
    log_info "Verificando Python 3..."
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
        log_success "Python $PYTHON_VERSION instalado"
        PYTHON_OK=true
    else
        log_error "Python 3 no encontrado"
        log_info "Instalando Python 3..."
        sudo apt update && sudo apt install -y python3
        PYTHON_OK=true
    fi
}

# 2. Verificar pip
check_pip() {
    log_info "Verificando pip..."
    if python3 -c "import pip" 2>/dev/null || command -v pip3 &> /dev/null; then
        log_success "pip disponible"
        PIP_OK=true
    else
        log_warning "pip no encontrado"
        log_info "Instalando pip..."
        sudo apt install -y python3-pip python3-venv
        PIP_OK=true
    fi
}

# 3. Verificar Node.js
check_nodejs() {
    log_info "Verificando Node.js..."
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version | sed 's/v//')
        MAJOR_VERSION=$(echo $NODE_VERSION | cut -d. -f1)
        
        if [ "$MAJOR_VERSION" -ge 20 ]; then
            log_success "Node.js $NODE_VERSION instalado (compatible con Backstage)"
            NODE_OK=true
        else
            log_warning "Node.js $NODE_VERSION encontrado (necesita v20+)"
            read -p "¿Actualizar Node.js a v20? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                install_nodejs_20
            fi
        fi
    else
        log_warning "Node.js no encontrado"
        read -p "¿Instalar Node.js 20? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_nodejs_20
        fi
    fi
}

# Función para instalar Node.js 20
install_nodejs_20() {
    log_info "Instalando Node.js 20..."
    
    # Remover Node.js anterior si existe
    sudo apt remove -y nodejs npm
    
    # Instalar Node.js 20
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
    
    # Verificar instalación
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        log_success "Node.js $NODE_VERSION instalado correctamente"
        NODE_OK=true
    else
        log_error "Error al instalar Node.js 20"
        NODE_OK=false
    fi
}

# 4. Verificar Docker y Docker Compose
check_docker() {
    log_info "Verificando Docker..."
    
    # Verificar Docker
    if command -v docker &> /dev/null; then
        DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
        log_success "Docker $DOCKER_VERSION instalado"
        
        # Verificar Docker Compose
        if docker compose version &> /dev/null; then
            COMPOSE_VERSION=$(docker compose version --short 2>/dev/null || echo "v2+")
            log_success "Docker Compose $COMPOSE_VERSION instalado"
        else
            log_warning "Docker Compose no encontrado"
            log_info "Docker Compose viene incluido con Docker Engine moderno"
        fi
        
        # Verificar si el usuario está en el grupo docker
        if groups $USER | grep -q docker; then
            log_success "Usuario en grupo docker"
        else
            log_warning "Usuario no está en grupo docker"
            sudo usermod -aG docker $USER
            log_info "Agregado al grupo docker (reinicia sesión para aplicar)"
        fi
        
        # Verificar que Docker esté corriendo
        if docker info &> /dev/null; then
            log_success "Docker daemon corriendo"
        else
            log_warning "Docker daemon no está corriendo"
            log_info "Iniciando Docker..."
            sudo systemctl start docker
            sudo systemctl enable docker
        fi
        
        DOCKER_OK=true
    else
        log_warning "Docker no encontrado"
        install_docker_ubuntu
    fi
}

# Función específica para instalar Docker en Ubuntu
install_docker_ubuntu() {
    log_info "Instalando Docker Engine en Ubuntu..."
    
    # Actualizar paquetes
    sudo apt-get update
    
    # Instalar dependencias
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Agregar clave GPG oficial de Docker
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Configurar repositorio
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Instalar Docker Engine
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Agregar usuario al grupo docker
    sudo usermod -aG docker $USER
    
    # Iniciar y habilitar Docker
    sudo systemctl start docker
    sudo systemctl enable docker
    
    log_success "Docker Engine instalado correctamente"
    log_info "Reinicia tu sesión para usar Docker sin sudo"
    
    DOCKER_OK=true
}

# 5. Verificar Git
check_git() {
    log_info "Verificando Git..."
    if command -v git &> /dev/null; then
        GIT_VERSION=$(git --version | cut -d' ' -f3)
        log_success "Git $GIT_VERSION instalado"
        GIT_OK=true
    else
        log_warning "Git no encontrado"
        log_info "Instalando Git..."
        sudo apt install -y git
        GIT_OK=true
    fi
}

# 6. Instalar dependencias Python con entorno virtual
install_python_deps() {
    if [ "$PIP_OK" = true ]; then
        log_info "Configurando entorno virtual Python..."
        
        # Crear directorio del proyecto si no existe
        PROJECT_DIR="/home/giovanemere/demos/infra-ai-agent"
        if [ ! -d "$PROJECT_DIR" ]; then
            log_info "Creando directorio del proyecto..."
            mkdir -p "$PROJECT_DIR"
        fi
        
        cd "$PROJECT_DIR"
        
        # Crear entorno virtual si no existe
        if [ ! -d "venv" ]; then
            log_info "Creando entorno virtual..."
            python3 -m venv venv
        fi
        
        # Activar entorno virtual e instalar dependencias
        log_info "Instalando dependencias Python en entorno virtual..."
        source venv/bin/activate
        
        # Crear requirements.txt si no existe
        if [ ! -f "requirements.txt" ]; then
            cat > requirements.txt << EOF
fastapi==0.104.1
uvicorn[standard]==0.24.0
google-generativeai==0.3.2
pillow==10.1.0
pyyaml==6.0.1
python-multipart==0.0.6
python-dotenv==1.0.0
EOF
        fi
        
        pip install --upgrade pip
        pip install -r requirements.txt
        
        log_success "Dependencias Python instaladas en entorno virtual"
        log_info "Para activar: cd $PROJECT_DIR && source venv/bin/activate"
        
        deactivate
    else
        log_error "pip no disponible - no se pueden instalar dependencias Python"
    fi
}

# 7. Verificar dependencias Python
check_python_deps() {
    log_info "Verificando dependencias Python..."
    local deps=("fastapi" "uvicorn" "google.generativeai" "PIL" "yaml")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if python3 -c "import $dep" 2>/dev/null; then
            log_success "$dep disponible"
        else
            log_warning "$dep no encontrado"
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        log_info "Instalando dependencias faltantes..."
        install_python_deps
    fi
}

# 8. Verificar configuración SSH
check_ssh() {
    log_info "Verificando configuración SSH para GitHub..."
    if [ -f ~/.ssh/id_rsa ] || [ -f ~/.ssh/id_ed25519 ]; then
        log_success "Claves SSH encontradas"
        if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
            log_success "SSH configurado correctamente para GitHub"
        else
            log_warning "SSH no configurado para GitHub"
            log_info "Configura tu clave SSH en GitHub: https://github.com/settings/keys"
        fi
    else
        log_warning "No se encontraron claves SSH"
        read -p "¿Generar clave SSH? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)" -f ~/.ssh/id_ed25519 -N ""
            log_success "Clave SSH generada"
            log_info "Agrega esta clave a GitHub:"
            cat ~/.ssh/id_ed25519.pub
        fi
    fi
}

# Resumen final
show_summary() {
    echo ""
    echo "📊 Resumen de Prerequisites"
    echo "=========================="
    
    [ "$PYTHON_OK" = true ] && log_success "Python 3" || log_error "Python 3"
    [ "$PIP_OK" = true ] && log_success "pip" || log_error "pip"
    [ "$NODE_OK" = true ] && log_success "Node.js" || log_warning "Node.js (opcional)"
    [ "$DOCKER_OK" = true ] && log_success "Docker" || log_warning "Docker (opcional)"
    [ "$GIT_OK" = true ] && log_success "Git" || log_error "Git"
    
    echo ""
    echo "🎯 Estado de la Plataforma:"
    
    if [ "$PYTHON_OK" = true ] && [ "$PIP_OK" = true ]; then
        log_success "AI Agent: Listo para funcionar"
    else
        log_error "AI Agent: Necesita Python + pip"
    fi
    
    if [ "$NODE_OK" = true ]; then
        log_success "Backstage: Listo para funcionar"
    else
        log_warning "Backstage: Necesita Node.js (opcional)"
    fi
    
    if [ "$DOCKER_OK" = true ]; then
        log_success "PostgreSQL: Listo para funcionar"
        log_info "Usar: docker compose up -d postgres"
    else
        log_warning "PostgreSQL: Necesita Docker (opcional)"
    fi
    
    echo ""
    echo "🚀 Próximos pasos:"
    echo "1. cd /home/giovanemere/demos/infra-ai-agent"
    echo "2. ./platform-cli start"
}

# Función principal
main() {
    check_python
    check_pip
    check_nodejs
    check_docker
    check_git
    check_python_deps
    check_ssh
    show_summary
}

main "$@"
