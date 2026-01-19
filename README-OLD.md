# 🤖 Infra AI Agent

**Agente IA para análisis de arquitecturas AWS y generación automática de catálogos Backstage**

## 🚀 Inicio Rápido

```bash
./setup.sh
echo "GEMINI_API_KEY=tu_key" >> .env
./start.sh
```

**URLs**: http://localhost:8000 | http://localhost:8000/docs

## 🏗️ Arquitectura

```
Usuario → FastAPI (:8000) → Gemini AI → YAML → GitHub → Backstage
```

## 📁 Estructura

```
agent/
├── processors/     # Vision + Text AI
├── validators/     # YAML validation
├── git_client.py   # GitHub integration
└── main.py         # FastAPI app
```

## 🔧 Configuración

```bash
# .env
GEMINI_API_KEY=tu_gemini_key
TEMPLATES_REPO=git@github.com:user/templates.git
```

## 🧪 API Usage

```bash
# Procesar texto
curl -X POST "http://localhost:8000/process-text" \
  -F "description=App web con S3, CloudFront y Lambda"

# Procesar diagrama
curl -X POST "http://localhost:8000/process-diagram" \
  -F "file=@architecture.png"
```

## 📊 Mapeo AWS → Backstage

| AWS Service | Backstage Kind | Type |
|-------------|----------------|------|
| S3 | Resource | storage |
| Lambda | Component | service |
| CloudFront | Component | cdn |
| API Gateway | Component | api |

## 🔍 Monitoreo

```bash
curl http://localhost:8000/health
tail -f logs/agent.log
```
