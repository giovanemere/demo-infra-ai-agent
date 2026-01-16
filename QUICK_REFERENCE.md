# 🚀 Quick Reference - Infrastructure AI Platform

## Comandos Esenciales

### Inicio Rápido
```bash
cd /home/giovanemere/demos
./platform-cli start    # Iniciar todo
./platform-cli status   # Ver estado
./platform-cli stop     # Detener todo
```

### Reiniciar Servicios
```bash
./platform-cli restart           # Todo
./restart-ai-agent.sh            # Solo AI Agent
./restart-backstage.sh           # Solo Backstage  
./restart-postgres.sh            # Solo PostgreSQL
```

### Verificación Rápida
```bash
curl http://localhost:8000/health    # AI Agent OK?
curl http://localhost:3000           # Backstage OK?
docker ps | grep postgres           # PostgreSQL OK?
```

### Probar AI
```bash
curl -X POST "http://localhost:8000/process-text" \
  -F "description=App con S3 y Lambda"
```

### URLs
- 🤖 AI Agent: http://localhost:8000
- 📚 AI Docs: http://localhost:8000/docs  
- 🎭 Backstage: http://localhost:3000

### Logs
```bash
tail -f infra-ai-agent/ai-agent.log        # AI Agent
docker logs backstage-postgres             # PostgreSQL
```

### Troubleshooting
```bash
# Puertos ocupados
ss -tlnp | grep -E ":(3000|8000|5432)"

# Procesos activos  
ps aux | grep -E "(uvicorn|http.server)"

# Reiniciar Docker
sudo systemctl restart docker
```
