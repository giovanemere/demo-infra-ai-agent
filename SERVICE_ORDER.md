# 🚀 Orden de Servicios y CLI Maestro

## 📋 Orden Correcto de Inicio

### 1️⃣ **PostgreSQL** (Puerto 5432)
```bash
cd /home/giovanemere/docker/postgres
./start-postgres.sh
```
- **Propósito**: Base de datos para Backstage
- **Dependencias**: Ninguna
- **Tiempo**: ~10 segundos

### 2️⃣ **AI Agent** (Puerto 8000)
```bash
cd /home/giovanemere/demos/infra-ai-agent
./start.sh
```
- **Propósito**: API de análisis de arquitecturas
- **Dependencias**: GEMINI_API_KEY configurado
- **Tiempo**: ~15 segundos

### 3️⃣ **Backstage IDP** (Puertos 3000/7007)
```bash
cd /home/giovanemere/demos/backstage-idp
./scripts/start-backstage.sh
```
- **Propósito**: Interface de catálogo
- **Dependencias**: PostgreSQL + GITHUB_TOKEN
- **Tiempo**: ~30 segundos

## 🎯 CLI Maestro

### Comando Principal
```bash
cd /home/giovanemere/demos
./platform-cli start
```

### Comandos Disponibles

| Comando | Descripción | Ejemplo |
|---------|-------------|---------|
| `start` | Iniciar toda la plataforma | `./platform-cli start` |
| `stop` | Detener todos los servicios | `./platform-cli stop` |
| `status` | Ver estado de servicios | `./platform-cli status` |
| `setup` | Configuración inicial | `./platform-cli setup` |
| `restart` | Reiniciar plataforma | `./platform-cli restart` |
| `logs` | Ver logs específicos | `./platform-cli logs ai-agent` |
| `help` | Mostrar ayuda | `./platform-cli help` |

## ⚙️ Configuración Previa

### Variables Requeridas
```bash
# 1. AI Agent
echo "GEMINI_API_KEY=tu_api_key" >> infra-ai-agent/.env

# 2. Backstage
echo "GITHUB_TOKEN=tu_github_token" >> backstage-idp/infra-ai-backstage/.env
```

### Setup Automático
```bash
./platform-cli setup
```

## 🌐 URLs Finales

Después de `./platform-cli start`:

- 🤖 **AI Agent**: http://localhost:8000
- 📚 **AI Docs**: http://localhost:8000/docs
- 🎭 **Backstage**: http://localhost:3000
- 🔧 **Backstage API**: http://localhost:7007
- 🐘 **PostgreSQL**: localhost:5432

## 🧪 Verificación

```bash
# Ver estado
./platform-cli status

# Test rápido
curl http://localhost:8000/health
curl http://localhost:3000
```

## 🔄 Flujo Completo

```bash
# 1. Setup inicial (solo primera vez)
./platform-cli setup

# 2. Configurar variables
echo "GEMINI_API_KEY=tu_key" >> infra-ai-agent/.env
echo "GITHUB_TOKEN=tu_token" >> backstage-idp/infra-ai-backstage/.env

# 3. Iniciar plataforma
./platform-cli start

# 4. Verificar estado
./platform-cli status
```

**🎯 Un solo comando inicia toda la plataforma en el orden correcto**
