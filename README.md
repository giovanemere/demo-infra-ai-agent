# 🤖 Infrastructure AI Agent

**Análisis automático de arquitecturas AWS con IA → Templates de Backstage**

AI Agent que procesa descripciones de texto e imágenes de arquitecturas AWS usando Gemini AI, genera templates de Backstage automáticamente y los integra con GitHub.

## 🏗️ Arquitectura

```
Backstage Frontend → AI Agent (FastAPI) → Gemini AI → Template Generator → GitHub → Backstage Catalog
```

### 🔧 Componentes Principales

- **FastAPI Backend**: API REST con endpoints para procesamiento
- **Gemini AI Integration**: Análisis inteligente de texto e imágenes
- **Template Generators**: Generación automática de templates Backstage
- **GitHub Integration**: Sincronización automática de templates
- **Backstage Integration**: Catálogo dinámico de templates

## 🚀 Inicio Rápido

### Prerrequisitos
```bash
# Python 3.9+
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Configuración
```bash
# Copiar variables de entorno
cp .env.example .env

# Editar .env con tus credenciales:
# GEMINI_API_KEY=tu_api_key_de_gemini
# GITHUB_TOKEN=tu_github_token
# GITHUB_CLIENT_ID=tu_github_client_id
```

### Ejecutar
```bash
# Desde el directorio agent/
cd agent
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

## 🌐 Endpoints API

### Procesamiento de Texto
```bash
curl -X POST "http://localhost:8000/process-text" \
  -F "description=Aplicación web con S3, CloudFront y Lambda"
```

### Análisis de Imágenes
```bash
curl -X POST "http://localhost:8000/process-image" \
  -F "file=@architecture-diagram.png"
```

### Health Check
```bash
curl http://localhost:8000/health
```

## 📁 Estructura del Proyecto

```
infra-ai-agent/
├── agent/                          # Código principal
│   ├── main.py                     # FastAPI application
│   ├── processors/                 # Procesadores IA
│   │   ├── text.py                 # Procesamiento de texto
│   │   └── vision.py               # Análisis de imágenes
│   ├── generators/                 # Generadores de templates
│   │   ├── template_generator.py   # Generador principal
│   │   └── scaffolder_generator.py # Generador Backstage
│   ├── validators/                 # Validadores
│   └── static/                     # Frontend estático
├── venv/                           # Entorno virtual Python
├── requirements.txt                # Dependencias
├── .env.example                    # Variables de entorno ejemplo
└── README.md                       # Esta documentación
```

## 🔧 Configuración Avanzada

### Variables de Entorno
```bash
# API Keys
GEMINI_API_KEY=your_gemini_api_key
GITHUB_TOKEN=your_github_token
GITHUB_CLIENT_ID=your_github_client_id

# Repositorios
TEMPLATES_REPO=git@github.com:user/templates-repo.git
CATALOG_REPO=git@github.com:user/catalog-repo.git

# Base de datos
DATABASE_URL=postgresql://user:pass@localhost:5432/backstage
```

### Integración con Backstage
El AI Agent se integra automáticamente con Backstage a través de:
- Templates generados en formato Scaffolder v1beta3
- Catálogo dinámico sincronizado con GitHub
- Componentes registrados automáticamente

## 🧪 Testing

```bash
# Ejecutar tests
python -m pytest

# Test específico del AI Agent
python test_ai_agent.py

# Test de MinIO
python test_minio.py
```

## 📚 Documentación

- **[Arquitectura Detallada](docs/architecture.md)**
- **[Configuración](docs/configuration.md)**
- **[API Reference](docs/api.md)**

## 🐛 Troubleshooting

### Problemas Comunes

**Error: Gemini API Key**
```bash
# Verificar API key
echo $GEMINI_API_KEY
```

**Error: Puerto ocupado**
```bash
# Liberar puerto 8000
sudo lsof -ti:8000 | xargs kill -9
```

**Error: Dependencias**
```bash
# Reinstalar dependencias
pip install -r requirements.txt --force-reinstall
```

## 🤝 Contribución

1. Fork el repositorio
2. Crear rama feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crear Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT.

---

**Parte de**: [Infrastructure AI Platform](https://github.com/giovanemere/demo-infrastructure-ai-platform)  
**Versión**: v1.2.0  
**Última actualización**: Enero 2026
