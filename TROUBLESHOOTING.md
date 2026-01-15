# 🆘 Troubleshooting

## Problemas Comunes

### Puerto ocupado
```bash
lsof -i :3000 :7007 :8000 :5432
kill -9 $(lsof -t -i:3000)
```

### PostgreSQL no inicia
```bash
docker logs backstage-postgres
docker-compose down && docker-compose up -d
```

### AI Agent falla
```bash
# Verificar API key
grep GEMINI_API_KEY infra-ai-agent/.env

# Logs
tail -f infra-ai-agent/logs/agent.log
```

### Backstage no conecta
```bash
# Verificar variables
grep -E "GITHUB_TOKEN|POSTGRES" backstage-idp/infra-ai-backstage/.env

# Verificar PostgreSQL
nc -z localhost 5432
```

### GitHub no actualiza
```bash
# Verificar token
gh auth status

# Verificar permisos del token
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user
```

## Logs Útiles

```bash
# PostgreSQL
docker logs backstage-postgres

# AI Agent
tail -f infra-ai-agent/logs/agent.log

# Backstage
tail -f backstage-idp/infra-ai-backstage/packages/backend/dist/logs/backend.log
```

## Reinicio Completo

```bash
# Detener todo
./stop-platform.sh

# Limpiar
docker-compose down
pkill -f "uvicorn\|yarn"

# Reiniciar
./start-platform.sh
```

## Verificación de Estado

```bash
./monitor-platform.sh
```
