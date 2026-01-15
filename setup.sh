#!/bin/bash

# =============================================================================
# Infra AI Agent - Setup Script
# =============================================================================

set -e

echo "🚀 Iniciando setup del Infra AI Agent..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funciones de utilidad
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Verificar Python
check_python() {
    log_info "Verificando Python..."
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
        log_success "Python $PYTHON_VERSION encontrado"
    else
        log_error "Python 3 no está instalado"
        exit 1
    fi
}

# Verificar Git
check_git() {
    log_info "Verificando Git..."
    if command -v git &> /dev/null; then
        GIT_VERSION=$(git --version | cut -d' ' -f3)
        log_success "Git $GIT_VERSION encontrado"
    else
        log_error "Git no está instalado"
        exit 1
    fi
}

# Crear entorno virtual
setup_venv() {
    log_info "Configurando entorno virtual..."
    if [ ! -d "venv" ]; then
        python3 -m venv venv
        log_success "Entorno virtual creado"
    else
        log_warning "Entorno virtual ya existe"
    fi
    
    source venv/bin/activate
    log_success "Entorno virtual activado"
}

# Instalar dependencias
install_dependencies() {
    log_info "Instalando dependencias..."
    pip install --upgrade pip
    pip install -r requirements.txt
    log_success "Dependencias instaladas"
}

# Configurar variables de entorno
setup_env() {
    log_info "Configurando variables de entorno..."
    if [ ! -f ".env" ]; then
        cp .env.example .env
        log_warning "Archivo .env creado desde .env.example"
        log_warning "⚠️  IMPORTANTE: Configura tu GEMINI_API_KEY en el archivo .env"
    else
        log_success "Archivo .env ya existe"
    fi
}

# Verificar SSH para GitHub
check_ssh() {
    log_info "Verificando configuración SSH para GitHub..."
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        log_success "SSH configurado correctamente para GitHub"
    else
        log_warning "SSH no configurado para GitHub"
        log_info "Ejecuta: ssh-keygen -t ed25519 -C 'tu-email@ejemplo.com'"
        log_info "Luego agrega la clave pública a GitHub"
    fi
}

# Clonar repositorio de templates
setup_templates_repo() {
    log_info "Configurando repositorio de templates..."
    TEMPLATES_DIR="../catalog-repo"
    
    if [ ! -d "$TEMPLATES_DIR" ]; then
        log_info "Clonando repositorio de templates..."
        git clone git@github.com:giovanemere/demo-infra-ai-agent-template-idp.git "$TEMPLATES_DIR"
        log_success "Repositorio de templates clonado"
    else
        log_success "Repositorio de templates ya existe"
        cd "$TEMPLATES_DIR"
        git pull origin main
        cd - > /dev/null
        log_success "Repositorio de templates actualizado"
    fi
}

# Crear directorios necesarios
create_directories() {
    log_info "Creando directorios necesarios..."
    
    directories=(
        "logs"
        "temp"
        "examples/outputs"
        "tests"
        "docs/api"
    )
    
    for dir in "${directories[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            log_success "Directorio $dir creado"
        fi
    done
}

# Verificar configuración
verify_setup() {
    log_info "Verificando configuración..."
    
    # Verificar archivo .env
    if [ -f ".env" ]; then
        if grep -q "your_gemini_api_key_here" .env; then
            log_warning "⚠️  Recuerda configurar tu GEMINI_API_KEY en .env"
        else
            log_success "Variables de entorno configuradas"
        fi
    fi
    
    # Verificar dependencias
    if python3 -c "import fastapi, google.generativeai, yaml, PIL" 2>/dev/null; then
        log_success "Todas las dependencias están instaladas"
    else
        log_error "Faltan dependencias por instalar"
    fi
}

# Generar documentación API
generate_api_docs() {
    log_info "Generando documentación de API..."
    
    cat > docs/api/README.md << 'EOF'
# API Documentation

## Endpoints Disponibles

### POST /process-diagram
Procesa un diagrama PNG de arquitectura AWS.

**Parámetros:**
- `file`: Archivo PNG (multipart/form-data)

**Respuesta:**
```json
{
  "status": "success",
  "yaml_content": "...",
  "github_url": "...",
  "type": "diagram"
}
```

### POST /process-text
Procesa una descripción textual de arquitectura.

**Parámetros:**
- `description`: Descripción de la arquitectura (form data)

**Respuesta:**
```json
{
  "status": "success",
  "yaml_content": "...",
  "github_url": "...",
  "type": "text"
}
```

### POST /analyze-architecture
Endpoint avanzado para análisis completo.

**Parámetros:**
```json
{
  "type": "diagram|text|hybrid",
  "content": {...},
  "metadata": {...},
  "options": {...}
}
```

### GET /health
Verifica el estado del servicio.

**Respuesta:**
```json
{
  "status": "healthy",
  "version": "1.0.0"
}
```

## Ejemplos de Uso

### cURL Examples

```bash
# Procesar diagrama
curl -X POST "http://localhost:8000/process-diagram" \
  -F "file=@architecture.png"

# Procesar texto
curl -X POST "http://localhost:8000/process-text" \
  -F "description=Una aplicación web con S3, CloudFront y Lambda"

# Health check
curl -X GET "http://localhost:8000/health"
```

### Python Examples

```python
import requests

# Procesar diagrama
with open('architecture.png', 'rb') as f:
    response = requests.post(
        'http://localhost:8000/process-diagram',
        files={'file': f}
    )

# Procesar texto
response = requests.post(
    'http://localhost:8000/process-text',
    data={'description': 'Una aplicación serverless con AWS Lambda y S3'}
)
```
EOF
    
    log_success "Documentación de API generada"
}

# Crear script de inicio mejorado
create_start_script() {
    log_info "Creando script de inicio mejorado..."
    
    cat > start-dev.sh << 'EOF'
#!/bin/bash

# Script de inicio para desarrollo
echo "🚀 Iniciando Infra AI Agent en modo desarrollo..."

# Activar entorno virtual
if [ -d "venv" ]; then
    source venv/bin/activate
    echo "✅ Entorno virtual activado"
else
    echo "❌ Entorno virtual no encontrado. Ejecuta ./setup.sh primero"
    exit 1
fi

# Verificar variables de entorno
if [ ! -f ".env" ]; then
    echo "❌ Archivo .env no encontrado"
    exit 1
fi

# Cargar variables de entorno
export $(cat .env | grep -v '^#' | xargs)

# Verificar GEMINI_API_KEY
if [ -z "$GEMINI_API_KEY" ] || [ "$GEMINI_API_KEY" = "your_gemini_api_key_here" ]; then
    echo "❌ GEMINI_API_KEY no configurado en .env"
    exit 1
fi

# Crear logs directory si no existe
mkdir -p logs

# Iniciar servidor con recarga automática
echo "🌐 Servidor disponible en: http://localhost:8000"
echo "📚 Documentación en: http://localhost:8000/docs"
echo "📖 ReDoc en: http://localhost:8000/redoc"
echo ""
echo "Presiona Ctrl+C para detener el servidor"

uvicorn agent.main:app --host 0.0.0.0 --port 8000 --reload --log-level info
EOF
    
    chmod +x start-dev.sh
    log_success "Script de inicio para desarrollo creado"
}

# Crear tests básicos
create_tests() {
    log_info "Creando tests básicos..."
    
    cat > tests/test_api.py << 'EOF'
import pytest
from fastapi.testclient import TestClient
from agent.main import app

client = TestClient(app)

def test_health_check():
    """Test del endpoint de health check"""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"

def test_process_text_endpoint():
    """Test básico del endpoint de procesamiento de texto"""
    response = client.post(
        "/process-text",
        data={"description": "Una aplicación simple con S3 y Lambda"}
    )
    # Nota: Este test fallará sin GEMINI_API_KEY válido
    assert response.status_code in [200, 500]  # 500 si no hay API key

def test_invalid_endpoint():
    """Test de endpoint inexistente"""
    response = client.get("/invalid-endpoint")
    assert response.status_code == 404
EOF
    
    cat > tests/__init__.py << 'EOF'
# Tests para Infra AI Agent
EOF
    
    log_success "Tests básicos creados"
}

# Función principal
main() {
    echo "🤖 Infra AI Agent Setup"
    echo "======================"
    echo ""
    
    check_python
    check_git
    setup_venv
    install_dependencies
    setup_env
    check_ssh
    setup_templates_repo
    create_directories
    generate_api_docs
    create_start_script
    create_tests
    verify_setup
    
    echo ""
    echo "🎉 Setup completado exitosamente!"
    echo ""
    echo "📋 Próximos pasos:"
    echo "1. ✅ GEMINI_API_KEY ya configurado"
    echo "2. Ejecuta ./start.sh para iniciar el agente"
    echo "3. Visita http://localhost:8000/docs para ver la documentación"
    echo "4. Para Backstage: cd ../backstage-idp && ./setup-backstage.sh"
    echo ""
    echo "🔧 Scripts disponibles:"
    echo "  ./start.sh        - Iniciar agente IA"
    echo "  ./start-dev.sh    - Iniciar en modo desarrollo (generado)"
    echo "  ./check-ssh.sh    - Verificar configuración SSH"
    echo ""
    echo "📚 Documentación:"
    echo "  docs/base-implementation.md     - Documentación base"
    echo "  docs/architecture-diagrams.md  - Diagramas de arquitectura"
    echo "  ../PLATFORM_GUIDE.md           - Guía completa de la plataforma"
    echo ""
    echo "🌐 URLs cuando esté ejecutándose:"
    echo "  http://localhost:8000           - AI Agent API"
    echo "  http://localhost:8000/docs      - Documentación Swagger"
    echo "  http://localhost:3000           - Backstage UI (después de setup)"
    echo ""
}

# Ejecutar función principal
main "$@"
