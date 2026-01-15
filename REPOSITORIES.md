# 📋 Repositorios del Proyecto

## 🔗 URLs GitHub Actualizadas

| Repositorio | Propósito | URL SSH | URL HTTPS |
|-------------|-----------|---------|-----------|
| **demo-infra-ai-agent** | AI Agent (Python + FastAPI) | `git@github.com:giovanemere/demo-infra-ai-agent.git` | https://github.com/giovanemere/demo-infra-ai-agent |
| **demo-infra-ai-agent-template-idp** | Templates generados | `git@github.com:giovanemere/demo-infra-ai-agent-template-idp.git` | https://github.com/giovanemere/demo-infra-ai-agent-template-idp |
| **demo-infra-backstage** | Backstage IDP Platform | `git@github.com:giovanemere/demo-infra-backstage.git` | https://github.com/giovanemere/demo-infra-backstage |
| **demo-infra-postgres** | PostgreSQL Docker setup | `git@github.com:giovanemere/demo-infra-postgres.git` | https://github.com/giovanemere/demo-infra-postgres |

## 🔧 Variables de Entorno Actualizadas

### AI Agent (.env)
```bash
GEMINI_API_KEY=AIzaSyCtgNIrn69ADfk8Gdw2fjnDOpMQshWbi0U
AGENT_REPO=git@github.com:giovanemere/demo-infra-ai-agent.git
TEMPLATES_REPO=git@github.com:giovanemere/demo-infra-ai-agent-template-idp.git
BACKSTAGE_REPO=git@github.com:giovanemere/demo-infra-backstage.git
POSTGRES_REPO=git@github.com:giovanemere/demo-infra-postgres.git
```

### Backstage (.env)
```bash
GITHUB_TOKEN=tu_github_token
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=backstage
POSTGRES_PASSWORD=backstage123
POSTGRES_DB=backstage
```

## 🚀 Comandos de Clonado

```bash
# Clonar todos los repositorios
mkdir ~/infrastructure-ai-platform
cd ~/infrastructure-ai-platform

git clone git@github.com:giovanemere/demo-infra-ai-agent.git
git clone git@github.com:giovanemere/demo-infra-ai-agent-template-idp.git
git clone git@github.com:giovanemere/demo-infra-backstage.git
git clone git@github.com:giovanemere/demo-infra-postgres.git
```

## 📦 Deployment Actualizado

```bash
# Script de deployment automático
curl -sSL https://raw.githubusercontent.com/giovanemere/demo-infra-backstage/main/deploy-new-environment.sh | bash
```
