# 🚀 Infrastructure AI Platform - v1.0.0

## 📋 Versión Estable

**Fecha**: 2026-01-16  
**Versión**: 1.0.0  
**Estado**: Producción Ready

## ✅ Servicios Incluidos

### 🤖 AI Agent (Puerto 8000)
- **Versión**: 1.0.0
- **Estado**: ✅ Funcionando
- **Tecnología**: FastAPI + Gemini AI
- **Funcionalidades**:
  - Análisis de arquitecturas AWS
  - Generación de YAML para Backstage
  - API REST documentada
  - Fallback automático

### 🎭 Backstage IDP (Puertos 3000/7007)
- **Versión**: 1.7.3
- **Estado**: ✅ Funcionando
- **Tecnología**: Node.js 20 + React
- **Funcionalidades**:
  - Catálogo de servicios
  - Interface web completa
  - Backend API
  - Integración PostgreSQL

### 🐘 PostgreSQL (Puerto 5432)
- **Versión**: 13
- **Estado**: ✅ Funcionando
- **Tecnología**: Docker
- **Configuración**:
  - Base de datos: backstage
  - Usuario: backstage
  - Persistencia de datos

## 🔧 Configuración

### Variables de Entorno
```bash
# AI Agent
GEMINI_API_KEY=your_gemini_api_key_here
GITHUB_TOKEN=your_github_token_here

# PostgreSQL
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=backstage
POSTGRES_PASSWORD=backstage
POSTGRES_DB=backstage
```

### Prerequisites
- ✅ Ubuntu 24.04 LTS
- ✅ Docker 29.1.4
- ✅ Node.js 20.20.0
- ✅ Python 3.12.3
- ✅ Git 2.43.0

## 🚀 Comandos de Inicio

### Inicio Completo
```bash
cd /home/giovanemere/demos
./platform-cli start
```

### Servicios Individuales
```bash
# AI Agent
cd infra-ai-agent
source venv/bin/activate
uvicorn agent.main:app --host 0.0.0.0 --port 8000

# Backstage
cd backstage-idp/infra-ai-backstage
POSTGRES_HOST=localhost yarn start

# PostgreSQL
docker run -d --name backstage-postgres \
  -e POSTGRES_USER=backstage \
  -e POSTGRES_PASSWORD=backstage \
  -e POSTGRES_DB=backstage \
  -p 5432:5432 postgres:13
```

## 🧪 Verificación

### Health Checks
```bash
# AI Agent
curl http://localhost:8000/health

# Backstage Frontend
curl http://localhost:3000

# Backstage Backend
curl http://localhost:7007/api/catalog/entities

# PostgreSQL
docker exec backstage-postgres pg_isready
```

### Prueba Funcional
```bash
# Procesar arquitectura
curl -X POST "http://localhost:8000/process-text" \
  -F "description=App web con S3, CloudFront y Lambda"
```

## 📊 URLs de Acceso

| Servicio | URL | Descripción |
|----------|-----|-------------|
| AI Agent | http://localhost:8000 | API principal |
| AI Docs | http://localhost:8000/docs | Documentación Swagger |
| Backstage UI | http://localhost:3000 | Interface de catálogo |
| Backstage API | http://localhost:7007 | Backend API |

## 🔄 Scripts de Gestión

```bash
# Estado de servicios
./platform-cli status

# Reiniciar servicios
./platform-cli restart
./restart-ai-agent.sh
./restart-backstage.sh
./restart-postgres.sh

# Logs
tail -f infra-ai-agent/ai-agent.log
tail -f backstage-idp/infra-ai-backstage/backstage.log
docker logs backstage-postgres
```

## 📚 Documentación

- [Guía de Comandos](COMMANDS_GUIDE.md)
- [Referencia Rápida](QUICK_REFERENCE.md)
- [Setup Completo](SETUP.md)
- [Troubleshooting](TROUBLESHOOTING.md)

## 🏗️ Arquitectura

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   AI Agent      │    │   Backstage     │    │   PostgreSQL    │
│   :8000         │◄──►│   :3000/:7007   │◄──►│   :5432         │
│                 │    │                 │    │                 │
│ • FastAPI       │    │ • React UI      │    │ • Docker        │
│ • Gemini AI     │    │ • Node.js API   │    │ • Persistence   │
│ • YAML Gen      │    │ • Catalog       │    │ • Backup Ready  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🔒 Seguridad

- ✅ API Keys configuradas
- ✅ GitHub Token válido
- ✅ PostgreSQL con credenciales
- ✅ CORS configurado
- ⚠️ Autenticación Backstage (opcional)

## 📈 Métricas

- **Tiempo de inicio**: ~60 segundos
- **Memoria total**: ~2GB
- **CPU**: Mínimo 2 cores
- **Disco**: ~5GB

---

**🎯 Plataforma lista para producción**  
**Versión estable y completamente funcional**
