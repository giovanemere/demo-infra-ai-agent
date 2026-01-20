# Comandos Frecuentes

## Sistema de Tareas Dinámicas
```bash
# Usar el task runner principal
./task-runner.sh <tarea>

# Tareas disponibles:
./task-runner.sh check      # Verificar prerequisitos
./task-runner.sh status     # Estado completo del proyecto
./task-runner.sh start      # Iniciar toda la plataforma
./task-runner.sh stop       # Detener todos los servicios
./task-runner.sh test       # Probar conectividad GitHub-Backstage
./task-runner.sh backup     # Backup de configuraciones
./task-runner.sh sync       # Sincronizar repositorios
./task-runner.sh diagnose   # Diagnosticar problemas
./task-runner.sh env        # Gestionar variables de entorno

# Comandos Git integrados:
./task-runner.sh commit     # Commit interactivo
./task-runner.sh push       # Push cambios
./task-runner.sh tag v1.3.0 # Crear tag de versión
./task-runner.sh deploy v1.3.0 # Deploy completo
./task-runner.sh pull       # Pull todos los repos
```

## Gestión de Servicios
```bash
# Iniciar plataforma completa
./start-platform.sh

# Detener servicios
./stop-platform.sh

# Reiniciar servicios específicos
./restart-ai-agent.sh
./restart-backstage.sh
```

## Desarrollo y Debug
```bash
# Ver logs en tiempo real
docker-compose logs -f ai-agent
docker-compose logs -f backstage

# Verificar estado de contenedores
docker ps

# Acceder a contenedor
docker exec -it <container_name> bash
```

## Git y Versioning
```bash
# Flujo completo con task-runner
./task-runner.sh commit          # Commit interactivo
./task-runner.sh push            # Subir cambios
./task-runner.sh tag v1.3.0      # Crear tag
./task-runner.sh deploy v1.3.0   # Deploy completo

# Actualizar repositorios
./task-runner.sh pull            # Pull todos los repos

# Flujo tradicional (alternativo)
git add .
git commit -m "feat: descripción del cambio"
git tag -a v1.x.x -m "Version 1.x.x"
git push origin master
git push origin v1.x.x

# Sincronizar todos los repositorios
./sync-all-repositories.sh

# Actualizar repositorios específicos
cd backstage-idp/ && git pull
cd infra-ai-agent/ && git pull
cd catalog-repo/ && git pull
```

## Testing y Verificación
```bash
# Probar conectividad completa
./test-github-backstage.sh

# Verificar configuración
./manage-env-configs.sh

# Diagnosticar problemas
./diagnose-backstage.sh
```

## Gestión de Configuraciones
```bash
# Backup de configuraciones
./manage-env-configs.sh backup

# Restaurar configuraciones
./manage-env-configs.sh restore

# Validar variables
./manage-env-configs.sh validate

# Sincronización .env ↔ PostgreSQL
cd backstage-idp/
./manage-config.sh save     # Guardar en DB
./manage-config.sh restore  # Restaurar desde DB
./manage-config.sh backup   # Backup completo
```

## PostgreSQL Management
```bash
# Iniciar PostgreSQL
cd /home/giovanemere/docker/postgres
./start-postgres.sh

# Detener PostgreSQL
docker-compose down

# Verificar estado
docker ps | grep postgres

# Conectar manualmente
docker exec -it backstage-postgres psql -U backstage -d backstage
```
