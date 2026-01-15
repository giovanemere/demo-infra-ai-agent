# 🔧 Setup Guide

## Prerequisitos

```bash
# Node.js 18+
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Docker
sudo apt install docker.io docker-compose
sudo usermod -aG docker $USER

# GitHub CLI
sudo apt install gh
gh auth login
```

## Instalación

### 1. PostgreSQL
```bash
cd docker/postgres
./start-postgres.sh
```

### 2. AI Agent
```bash
cd infra-ai-agent
./setup.sh
echo "GEMINI_API_KEY=tu_key" >> .env
./start.sh
```

### 3. Backstage
```bash
cd backstage-idp
./setup-backstage.sh
echo "GITHUB_TOKEN=tu_token" >> infra-ai-backstage/.env
./scripts/start-backstage.sh
```

## Verificación

```bash
# Servicios funcionando
curl http://localhost:8000/health  # AI Agent
curl http://localhost:3000         # Backstage UI
nc -z localhost 5432               # PostgreSQL
```

## URLs

- 🤖 AI Agent: http://localhost:8000
- 🎭 Backstage: http://localhost:3000
- 🐘 PostgreSQL: localhost:5432

## Tokens Requeridos

### GEMINI_API_KEY
1. Ir a https://aistudio.google.com/app/apikey
2. Crear API key
3. Configurar en `.env`

### GITHUB_TOKEN
1. Ir a https://github.com/settings/tokens
2. Crear token con permisos: `repo`, `read:org`
3. Configurar en `backstage-idp/infra-ai-backstage/.env`
