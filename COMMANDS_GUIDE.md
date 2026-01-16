# 📚 Infrastructure AI Platform - Guía de Comandos

## 🚀 Comandos Principales

### Iniciar Plataforma
```bash
cd /home/giovanemere/demos
./platform-cli start          # Iniciar todos los servicios
./platform-cli status         # Ver estado de servicios
```

### Detener Plataforma
```bash
./platform-cli stop           # Detener todos los servicios
```

### Reiniciar Plataforma
```bash
./platform-cli restart        # Reiniciar todos los servicios
```

## 🔧 Servicios Individuales

### AI Agent (Puerto 8000)
```bash
# Iniciar
cd infra-ai-agent
source venv/bin/activate
uvicorn agent.main:app --host 0.0.0.0 --port 8000 &

# Reiniciar
./restart-ai-agent.sh

# Detener
pkill -f uvicorn

# Verificar
curl http://localhost:8000/health
```

### Backstage (Puerto 3000)
```bash
# Iniciar
cd backstage-idp/infra-ai-backstage
python3 -m http.server 3000 &

# Reiniciar
./restart-backstage.sh

# Detener
pkill -f "python3 -m http.server 3000"

# Verificar
curl http://localhost:3000
```

### PostgreSQL (Puerto 5432)
```bash
# Iniciar
docker run -d --name backstage-postgres \
  -e POSTGRES_USER=backstage \
  -e POSTGRES_PASSWORD=backstage \
  -e POSTGRES_DB=backstage \
  -p 5432:5432 postgres:13

# Reiniciar
./restart-postgres.sh
# O simplemente:
docker restart backstage-postgres

# Detener
docker stop backstage-postgres

# Verificar
docker ps | grep postgres
```

## 🧪 Pruebas y Verificación

### Health Checks
```bash
# AI Agent
curl http://localhost:8000/health

# Backstage
curl -I http://localhost:3000

# PostgreSQL
docker exec backstage-postgres pg_isready
```

### Probar AI Agent
```bash
# Procesar texto
curl -X POST "http://localhost:8000/process-text" \
  -F "description=App web con S3, CloudFront y Lambda"

# Ver documentación
curl http://localhost:8000/docs
```

### Ver Logs
```bash
# AI Agent
tail -f infra-ai-agent/ai-agent.log

# Backstage
tail -f backstage-idp/infra-ai-backstage/backstage.log

# PostgreSQL
docker logs backstage-postgres
```

## 🔍 Diagnóstico

### Ver Procesos Activos
```bash
# Todos los servicios
ps aux | grep -E "(uvicorn|http.server|postgres)"

# Puertos ocupados
ss -tlnp | grep -E ":(3000|8000|5432)"
```

### Ver Estado de Docker
```bash
docker ps                     # Contenedores activos
docker ps -a                  # Todos los contenedores
docker images                 # Imágenes disponibles
```

### Verificar Variables de Entorno
```bash
# Ver configuración AI Agent
cat infra-ai-agent/.env

# Verificar API keys
echo $GEMINI_API_KEY
echo $GITHUB_TOKEN
```

## 🛠️ Troubleshooting

### Problemas Comunes

**AI Agent no inicia:**
```bash
cd infra-ai-agent
source venv/bin/activate
python -c "import agent.main"  # Verificar imports
```

**Puerto ocupado:**
```bash
# Ver qué usa el puerto
lsof -i :8000
# O detener proceso
pkill -f uvicorn
```

**Docker no funciona:**
```bash
# Verificar Docker
docker --version
docker ps

# Reiniciar Docker
sudo systemctl restart docker
```

**Permisos de Docker:**
```bash
# Agregar usuario al grupo docker
sudo usermod -aG docker $USER
# O usar sudo temporalmente
sudo docker ps
```

## 📊 URLs de la Plataforma

| Servicio | URL | Descripción |
|----------|-----|-------------|
| AI Agent | http://localhost:8000 | API principal |
| AI Docs | http://localhost:8000/docs | Documentación Swagger |
| Backstage | http://localhost:3000 | Interface de catálogo |
| PostgreSQL | localhost:5432 | Base de datos |

## 🔄 Flujo de Trabajo Típico

```bash
# 1. Iniciar plataforma
./platform-cli start

# 2. Verificar estado
./platform-cli status

# 3. Probar AI Agent
curl -X POST "http://localhost:8000/process-text" \
  -F "description=Sistema con RDS y EC2"

# 4. Ver resultado en Backstage
open http://localhost:3000

# 5. Detener cuando termine
./platform-cli stop
```

## 📝 Configuración

### Variables de Entorno Requeridas
```bash
# En infra-ai-agent/.env
GEMINI_API_KEY=tu_api_key_aqui
GITHUB_TOKEN=tu_github_token_aqui
```

### Dependencias del Sistema
```bash
# Verificar prerequisitos
./check-prerequisites.sh

# Instalar si faltan
sudo apt install docker.io nodejs npm python3-pip
```

---

**💡 Tip:** Usa `./platform-cli help` para ver todos los comandos disponibles.
