# 📋 Documentación del Proyecto

## 📚 Índice de Documentos

### 🚀 Inicio Rápido
- **[README.md](README.md)** - Introducción y inicio rápido
- **[SETUP.md](SETUP.md)** - Guía de instalación paso a paso

### 🔧 Configuración
- **[docker/postgres/README.md](docker/postgres/README.md)** - PostgreSQL setup
- **[infra-ai-agent/.env.example](infra-ai-agent/.env.example)** - Variables de entorno

### 🆘 Soporte
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Solución de problemas
- **[monitor-platform.sh](monitor-platform.sh)** - Script de monitoreo

### 🏗️ Arquitectura
- **[infra-ai-agent/catalog-info.yaml](infra-ai-agent/catalog-info.yaml)** - Catálogo Backstage
- **[infra-ai-agent/agent/](infra-ai-agent/agent/)** - Código del agente IA

## 🎯 Flujo de Uso

1. **Setup**: Seguir [SETUP.md](SETUP.md)
2. **Configurar**: API keys en archivos `.env`
3. **Iniciar**: `./start-platform.sh`
4. **Usar**: Enviar diagramas a http://localhost:8000
5. **Ver**: Resultados en http://localhost:3000
6. **Monitorear**: `./monitor-platform.sh`

## 🔗 Enlaces Útiles

- **AI Agent API**: http://localhost:8000/docs
- **Backstage UI**: http://localhost:3000
- **GitHub Repos**: 
  - [AI Agent](https://github.com/giovanemere/demo-infra-ai-agent)
  - [Templates](https://github.com/giovanemere/demo-infra-ai-agent-template-idp)
  - [Backstage](https://github.com/giovanemere/demo-infra-backstage)
  - [PostgreSQL](https://github.com/giovanemere/demo-infra-postgres)

## 📋 Documentos Principales

- **[README.md](README.md)** - Introducción y inicio rápido
- **[SETUP.md](SETUP.md)** - Guía de instalación paso a paso
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Solución de problemas
- **[REPOSITORIES.md](REPOSITORIES.md)** - URLs y configuración de repositorios

## 📊 Scripts Principales

| Script | Propósito |
|--------|-----------|
| `setup.sh` | Configuración inicial |
| `start-platform.sh` | Iniciar toda la plataforma |
| `monitor-platform.sh` | Verificar estado |
| `stop-platform.sh` | Detener servicios |

## 🎯 Casos de Uso

### Analizar Arquitectura
```bash
curl -X POST "http://localhost:8000/process-text" \
  -F "description=App web con S3, CloudFront y Lambda"
```

### Ver Catálogo
- Ir a http://localhost:3000/catalog
- Buscar componentes generados

### Monitorear Sistema
```bash
./monitor-platform.sh
```
