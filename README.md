# 🤖 Infrastructure AI Platform

**Análisis automático de arquitecturas AWS con IA → Catálogo Backstage**

## 🚀 Inicio Rápido

```bash
# 1. Clonar repositorio
git clone git@github.com:giovanemere/demo-infra-ai-agent.git
cd demo-infra-ai-agent

# 2. Iniciar plataforma completa (carga .env automáticamente)
./start-platform.sh
```

**URLs**: http://localhost:8000 (API) | http://localhost:8000/docs (Docs) | http://localhost:3000 (Backstage)

## 🏗️ Arquitectura

```
Usuario → AI Agent (:8000) → Gemini AI → GitHub → Backstage (:3000)
```

## 🔧 Comandos

```bash
./start-platform.sh    # Iniciar todo
./stop-platform.sh     # Detener todo
```

## 🧪 Uso

```bash
# Procesar texto
curl -X POST "http://localhost:8000/process-text" \
  -F "description=App web con S3, CloudFront y Lambda"

# Ver resultado en Backstage
# http://localhost:3000/catalog
```
