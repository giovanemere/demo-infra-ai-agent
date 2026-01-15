# 🤖 Infrastructure AI Platform

**Análisis automático de arquitecturas AWS con IA → Catálogo Backstage**

## 🚀 Inicio Rápido

```bash
# 1. Clonar y configurar
git clone git@github.com:giovanemere/demo-infra-ai-agent.git
cd demo-infra-ai-agent
./setup.sh

# 2. Configurar API key
echo "GEMINI_API_KEY=AIzaSyCtgNIrn69ADfk8Gdw2fjnDOpMQshWbi0U" >> .env

# 3. Iniciar
./start.sh
```

**URLs**: http://localhost:8000 (API) | http://localhost:8000/docs (Docs)

## 🏗️ Arquitectura

```
Usuario → AI Agent (:8000) → Gemini AI → GitHub → Backstage (:3000)
```

## 📁 Estructura

```
demos/
├── infra-ai-agent/     # AI Agent (Python)
├── backstage-idp/      # Backstage IDP  
├── catalog-repo/       # YAMLs generados
└── docker/postgres/    # PostgreSQL
```

## 🔧 Configuración

### Variables (.env)
```bash
GEMINI_API_KEY=tu_api_key
GITHUB_TOKEN=tu_github_token
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
```

### Servicios
- **AI Agent**: :8000
- **Backstage UI**: :3000  
- **Backstage API**: :7007
- **PostgreSQL**: :5432

## 🧪 Uso

```bash
# Procesar texto
curl -X POST "http://localhost:8000/process-text" \
  -F "description=App web con S3, CloudFront y Lambda"

# Ver resultado en Backstage
# http://localhost:3000/catalog
```

## 📦 Setup Completo

```bash
# PostgreSQL
cd docker/postgres && ./start-postgres.sh

# Backstage  
cd backstage-idp && ./setup-backstage.sh

# Iniciar todo
cd demos && ./start-platform.sh
```

## 🔍 Monitoreo

```bash
./monitor-platform.sh  # Estado de servicios
```

## 📚 Docs

- [Setup Completo](SETUP.md)
- [API Reference](http://localhost:8000/docs)
- [Troubleshooting](TROUBLESHOOTING.md)
