# 🤖 Infrastructure AI Platform - Documentación Completa

## 📋 Arquitectura de la Solución

### 🏗️ Componentes Principales

```
Infrastructure AI Platform
├── 🤖 AI Agent (Backend)           # Puerto :8000
├── 🎭 Backstage IDP (Frontend)     # Puerto :3000  
├── 🗄️ PostgreSQL (Database)       # Puerto :5432
├── 📊 Catalog Repo (Storage)       # Catálogo local
└── 🔄 Templates Repo (GitHub)      # Sincronización automática
```

## 🔧 Módulos y Funcionalidades

### 1. **AI Agent** (`/infra-ai-agent/`)
**Función**: Procesamiento de arquitecturas con IA
- **Backend**: FastAPI + Python
- **IA**: Google Gemini API
- **Procesadores**: Texto e imágenes
- **Validadores**: Backstage YAML
- **Git Client**: Sincronización automática

**Estructura**:
```
agent/
├── main.py              # API principal
├── processors/          # Procesadores IA
│   ├── text.py         # Análisis de texto
│   └── vision.py       # Análisis de imágenes
├── validators/          # Validadores
│   └── backstage.py    # Validación YAML
├── generators/          # Generadores
└── static/             # Frontend web
```

### 2. **Backstage IDP** (`/backstage-idp/`)
**Función**: Portal de desarrolladores
- **Frontend**: React + TypeScript
- **Backend**: Node.js
- **Catálogo**: Sincronización GitHub
- **Auth**: GitHub OAuth + Guest

**Estructura**:
```
infra-ai-backstage/
├── app-config.yaml     # Configuración principal
├── catalog-users.yaml  # Usuarios locales
├── packages/           # Módulos Backstage
│   ├── app/           # Frontend
│   └── backend/       # Backend API
└── plugins/           # Plugins personalizados
```

### 3. **Catalog Repo** (`/catalog-repo/`)
**Función**: Almacenamiento local del catálogo
- **Components**: Definiciones de componentes
- **Systems**: Definiciones de sistemas
- **Resources**: Recursos de infraestructura

### 4. **Templates Repo** (GitHub)
**Función**: Repositorio dinámico sincronizado
- **URL**: `git@github.com:giovanemere/demo-infra-ai-agent-template-idp.git`
- **Sincronización**: Automática cada 5 minutos
- **Estructura dinámica**: Detección automática de proyectos

## 🔄 Flujos del Proyecto

### **Flujo 1: Análisis de Arquitectura**
```
Usuario → Frontend → AI Agent → Gemini API → Validación → GitHub → Backstage
```

1. **Input**: Usuario describe arquitectura (texto/imagen)
2. **Procesamiento**: AI Agent analiza con Gemini
3. **Generación**: Crea YAML de Backstage
4. **Validación**: Valida estructura YAML
5. **Almacenamiento**: Guarda en GitHub
6. **Sincronización**: Backstage detecta automáticamente

### **Flujo 2: Sincronización Automática**
```
GitHub → Backstage Provider → Catálogo → Frontend
```

1. **Detección**: GitHub Provider escanea repositorio
2. **Procesamiento**: Lee catalog-info.yaml de proyectos
3. **Indexación**: Agrega al catálogo de Backstage
4. **Visualización**: Disponible en frontend

### **Flujo 3: Creación de Proyectos**
```
Backstage Scaffolder → Template → GitHub → Catálogo
```

1. **Template**: Usuario usa template de Scaffolder
2. **Generación**: Crea proyecto con estructura
3. **Publicación**: Publica en GitHub
4. **Registro**: Auto-registro en catálogo

## 📁 Estructura de Archivos Completa

### **Configuración Principal**
```
demos/
├── README.md                    # Documentación principal
├── start-platform.sh          # Inicio completo
├── stop-platform.sh           # Parada completa
├── monitor-platform.sh        # Monitoreo
└── restart-backstage.sh       # Reinicio Backstage
```

### **Scripts de Gestión**
```
backstage-idp/
├── start-backstage-simple.sh   # Inicio Backstage
├── restart-backstage.sh        # Reinicio
├── validate-github-auth.sh     # Validación OAuth
├── test-github-auth.sh         # Test autenticación
├── check-users.sh              # Verificar usuarios
└── templates-working.sh        # Verificar templates
```

### **Documentación**
```
docs/
├── ARCHITECTURE.md             # Esta documentación
├── SETUP.md                   # Guía de instalación
├── API.md                     # Documentación API
├── TROUBLESHOOTING.md         # Solución de problemas
└── DEPLOYMENT.md              # Guía de despliegue
```

## 🚀 Scripts de Gestión

### **Inicio y Parada**
```bash
# Iniciar plataforma completa
./start-platform.sh

# Parar plataforma
./stop-platform.sh

# Reiniciar solo Backstage
./restart-backstage.sh

# Monitorear servicios
./monitor-platform.sh
```

### **Validación y Testing**
```bash
# Validar configuración GitHub
./validate-github-auth.sh

# Test de autenticación
./test-github-auth.sh

# Verificar usuarios
./check-users.sh

# Verificar templates
./check-template-sync.sh
```

## 🔐 Configuración de Seguridad

### **Variables de Entorno**
```bash
# AI Agent
GEMINI_API_KEY=your_api_key
GITHUB_TOKEN=your_token

# Backstage
GITHUB_CLIENT_ID=your_client_id
GITHUB_CLIENT_SECRET=your_secret
BACKEND_SECRET=your_backend_secret
```

### **GitHub OAuth**
- **Homepage URL**: `http://localhost:3000`
- **Callback URL**: `http://localhost:7007/api/auth/github/handler/frame`

## 📊 Monitoreo y Logs

### **Logs Principales**
```bash
# AI Agent
tail -f infra-ai-agent/ai-agent.log

# Backstage
tail -f backstage-idp/infra-ai-backstage/backstage.log

# PostgreSQL
docker logs postgres-backstage
```

### **Endpoints de Salud**
- **AI Agent**: `http://localhost:8000/health`
- **Backstage Frontend**: `http://localhost:3000`
- **Backstage API**: `http://localhost:7007/api/catalog/entities`

## 🎯 URLs de Acceso

### **Interfaces de Usuario**
- **AI Agent Frontend**: http://localhost:8000
- **AI Agent API Docs**: http://localhost:8000/docs
- **Backstage Portal**: http://localhost:3000
- **Backstage Catálogo**: http://localhost:3000/catalog
- **Backstage Templates**: http://localhost:3000/create

### **APIs**
- **AI Agent API**: http://localhost:8000/api/
- **Backstage API**: http://localhost:7007/api/

## 🔄 Mantenimiento

### **Actualizaciones**
```bash
# Actualizar dependencias AI Agent
cd infra-ai-agent && pip install -r requirements.txt

# Actualizar dependencias Backstage
cd backstage-idp/infra-ai-backstage && yarn install
```

### **Backup**
```bash
# Backup configuración
./generate-release.sh

# Backup base de datos
docker exec postgres-backstage pg_dump -U backstage backstage > backup.sql
```

## 🎉 Estado Actual

- ✅ **AI Agent**: Funcionando con Gemini API
- ✅ **Backstage**: Configurado con GitHub OAuth
- ✅ **Sincronización**: Automática cada 5 minutos
- ✅ **Catálogo**: 8+ proyectos detectados
- ✅ **Templates**: Scaffolder funcionando
- ✅ **Documentación**: Completa y actualizada
