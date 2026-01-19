# 🤖 Infrastructure AI Agent

## 📋 Descripción

AI Agent para análisis automático de arquitecturas de infraestructura usando Google Gemini API. Procesa descripciones de texto e imágenes para generar definiciones de Backstage YAML automáticamente.

## 🏗️ Arquitectura

```
Frontend (Static) → FastAPI Backend → Gemini AI → Validators → GitHub → Backstage
```

### Componentes:
- **Frontend**: Interfaz web estática (HTML/JS)
- **Backend**: FastAPI + Python
- **Procesadores**: Texto e imágenes con Gemini
- **Validadores**: Validación YAML de Backstage
- **Git Client**: Sincronización automática con GitHub

## 🚀 Inicio Rápido

```bash
# 1. Configurar entorno
./setup.sh

# 2. Configurar API key
echo "GEMINI_API_KEY=your_api_key" >> .env

# 3. Iniciar servicio
./start.sh
```

**URL**: http://localhost:8000

## 📁 Estructura del Proyecto

```
agent/
├── main.py              # API principal FastAPI
├── processors/          # Procesadores IA
│   ├── text.py         # Análisis de texto
│   └── vision.py       # Análisis de imágenes
├── validators/          # Validadores
│   └── backstage.py    # Validación YAML Backstage
├── generators/          # Generadores de contenido
├── database.py          # Gestión de base de datos
├── git_client.py        # Cliente Git para sincronización
└── static/             # Frontend web
    └── index.html      # Interfaz principal
```

## 🔧 Funcionalidades

### 1. **Procesamiento de Texto**
- Análisis de descripciones de arquitectura
- Extracción de componentes y relaciones
- Generación de YAML estructurado

### 2. **Procesamiento de Imágenes**
- Análisis de diagramas de arquitectura
- Reconocimiento de componentes visuales
- Interpretación de flujos y conexiones

### 3. **Validación YAML**
- Validación de sintaxis Backstage
- Verificación de estructura
- Corrección automática de errores

### 4. **Sincronización Git**
- Push automático a repositorio GitHub
- Organización por proyectos
- Versionado automático

## 🔌 API Endpoints

### **POST /process-text**
Procesa descripción de texto de arquitectura
```json
{
  "description": "App web con S3, CloudFront y Lambda"
}
```

### **POST /process-image**
Procesa imagen de diagrama de arquitectura
```json
{
  "image": "base64_encoded_image"
}
```

### **GET /health**
Verificación de estado del servicio

### **GET /docs**
Documentación interactiva de la API

## ⚙️ Configuración

### Variables de Entorno (.env)
```bash
# API Keys
GEMINI_API_KEY=your_gemini_api_key

# GitHub
GITHUB_TOKEN=your_github_token

# Base de datos
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=backstage
POSTGRES_PASSWORD=backstage123
POSTGRES_DB=backstage

# Repositorios
TEMPLATES_REPO=git@github.com:giovanemere/demo-infra-ai-agent-template-idp.git
```

## 🔄 Flujo de Procesamiento

1. **Input**: Usuario envía descripción/imagen
2. **Análisis**: Gemini AI procesa el contenido
3. **Estructuración**: Extrae componentes y relaciones
4. **Generación**: Crea YAML de Backstage válido
5. **Validación**: Verifica estructura y sintaxis
6. **Almacenamiento**: Guarda en repositorio GitHub
7. **Sincronización**: Backstage detecta automáticamente

## 🧪 Testing

```bash
# Test básico
curl -X POST "http://localhost:8000/process-text" \
  -H "Content-Type: application/json" \
  -d '{"description": "App web con S3 y Lambda"}'

# Test con imagen
curl -X POST "http://localhost:8000/process-image" \
  -F "image=@diagram.png"
```

## 📊 Monitoreo

### Logs
```bash
tail -f ai-agent.log
```

### Métricas
- Requests procesados
- Tiempo de respuesta
- Errores de validación
- Sincronizaciones exitosas

## 🔧 Desarrollo

### Instalación de dependencias
```bash
pip install -r requirements.txt
```

### Estructura de desarrollo
```bash
# Activar entorno virtual
source venv/bin/activate

# Instalar en modo desarrollo
pip install -e .

# Ejecutar tests
python -m pytest

# Linting
flake8 agent/
```

## 🎯 Estado Actual

- ✅ **API FastAPI**: Funcionando
- ✅ **Procesador de texto**: Gemini integrado
- ✅ **Procesador de imágenes**: Gemini Vision
- ✅ **Validador YAML**: Backstage compatible
- ✅ **Git Client**: Sincronización automática
- ✅ **Frontend**: Interfaz web funcional
- ✅ **Base de datos**: PostgreSQL integrada

## 🚀 Próximas Mejoras

- [ ] Cache de respuestas IA
- [ ] Métricas avanzadas
- [ ] Templates personalizados
- [ ] Integración con más proveedores IA
- [ ] API de webhooks
