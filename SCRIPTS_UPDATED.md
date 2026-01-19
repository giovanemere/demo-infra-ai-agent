# ✅ SCRIPTS ACTUALIZADOS - Variables y Servicios

## 🎯 Scripts Principales Actualizados

### 1. `restart-all-services.sh` ⭐ (NUEVO - RECOMENDADO)
- **Función**: Reinicia todos los servicios con variables correctas
- **Servicios**: PostgreSQL + AI Agent + Backstage
- **Variables**: Carga automática desde .env
- **Verificación**: Estado completo de todos los servicios

### 2. `restart-ai-agent.sh` (ACTUALIZADO)
- **Función**: Reinicia solo AI Agent
- **Ruta**: `infra-ai-agent/agent/main.py` (frontend funcional)
- **Variables**: Carga automática
- **Verificación**: Health check

### 3. `start-platform.sh` (ACTUALIZADO)
- **Función**: Inicio completo de la plataforma
- **AI Agent**: Usa ruta correcta `agent/main.py`
- **Variables**: Carga automática

## 🔧 Variables de Entorno Actualizadas

### AI Agent (.env)
```bash
GEMINI_API_KEY=AIzaSyCtgNIrn69ADfk8Gdw2fjnDOpMQshWbi0U
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
GITHUB_TOKEN=ghp_XXXXXXXXXXXXXXXXXXXXXXXXX
```

### Backstage (.env)
```bash
BACKEND_BASE_URL=http://localhost:7007
APP_BASE_URL=http://localhost:3000
GITHUB_ORG=giovanemere
GITHUB_REPO=demo-infra-ai-agent-template-idp
POSTGRES_HOST=localhost
```

## 📊 Estado Actual de Servicios

✅ **FUNCIONANDO CORRECTAMENTE:**
- 🤖 AI Agent: http://localhost:8000 (Frontend funcional)
- 🎭 Backstage Frontend: http://localhost:3000
- 🔧 Backstage Backend: http://localhost:7007 (401 = OK, necesita auth)
- 🐘 PostgreSQL: localhost:5432

## 🚀 Comandos para Usar

### Reiniciar Todo
```bash
./restart-all-services.sh
```

### Reiniciar Individual
```bash
./restart-ai-agent.sh      # Solo AI Agent
./restart-backstage.sh     # Solo Backstage
./restart-postgres.sh      # Solo PostgreSQL
```

### Probar Funcionalidad
```bash
# Probar AI Agent
curl -X POST 'http://localhost:8000/process-text' -F 'description=App web con S3 y Lambda'

# Ver logs
tail -f infra-ai-agent/ai-agent.log
tail -f backstage-idp/infra-ai-backstage/backstage.log
```

## 🎯 Resultado Final

✅ **Plataforma completamente funcional:**
1. **AI Agent** - Frontend único funcional con GitHub
2. **Backstage** - Catálogo y templates funcionando
3. **PostgreSQL** - Base de datos activa
4. **Variables** - Carga automática en todos los scripts
5. **Integración** - AI Agent → GitHub → Backstage

**🎉 Todo listo para usar la plataforma completa!**
