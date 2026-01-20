# Contexto del Proyecto - Infrastructure AI Platform

## Información General
- **Proyecto**: Infrastructure AI Platform
- **Versión Actual**: v1.2.0
- **Fecha Última Actualización**: 2026-01-20
- **Entorno**: Windows 11 + WSL Ubuntu + VS Code Remote-WSL
- **Directorio Base**: /home/giovanemere/demos

## Arquitectura Multi-Repositorio
```
/home/giovanemere/demos/ (workspace principal)
├── demos/ (repo principal - scripts de orquestación)
├── backstage-idp/ (repo Backstage IDP)
├── infra-ai-agent/ (repo AI Agent + FastAPI)
│   └── templates-repo/ (repo templates Backstage)
├── catalog-repo/ (repo catálogo Backstage)
└── /home/giovanemere/docker/postgres/ (PostgreSQL externo)
```

## Repositorios GitHub
1. **demos** → `demo-infra-ai-agent` (principal)
2. **backstage-idp** → `demo-infra-backstage`
3. **infra-ai-agent** → `demo-infra-ai-agent`
4. **templates-repo** → `demo-infra-ai-agent-template-idp`
5. **catalog-repo** → `demo-infra-ai-agent-template-idp`

## Arquitectura de Servicios
```
Usuario → AI Agent (:8000) → Gemini AI → GitHub → Backstage (:3000)
                ↓
        PostgreSQL (:5432) ← Config Sync
```

## URLs Principales
- AI Agent: http://localhost:8000
- Backstage: http://localhost:3000
- Documentación API: http://localhost:8000/docs

## Componentes por Repositorio
- **demos/**: Scripts de orquestación, documentación AI
- **backstage-idp/**: Configuración Backstage, gestión .env↔DB
- **infra-ai-agent/**: Servicio FastAPI, frontend, lógica AI
- **templates-repo/**: Templates para generación de código
- **catalog-repo/**: Catálogo de componentes Backstage

## Estado Actual
- ✅ Versión v1.2.0 desplegada
- ✅ Scripts de seguridad implementados
- ✅ Integración GitHub-Backstage funcional
- ✅ TechDocs operativo
- ✅ Variables de entorno desde .env

## Scripts Principales
- `task-runner.sh`: Sistema dinámico de tareas (NUEVO)
- `start-platform.sh`: Iniciar toda la plataforma
- `stop-platform.sh`: Detener servicios
- `test-github-backstage.sh`: Verificar conectividad
- `manage-env-configs.sh`: Gestionar configuraciones
- `check-prerequisites.sh`: Verificar prerequisitos del sistema
- `verify-complete-solution.sh`: Estado completo del proyecto
- `diagnose-backstage.sh`: Diagnosticar problemas Backstage

## Documentación Disponible

- **setup.md**: Guía de instalación y configuración inicial
- **comandos.md**: Lista completa de comandos y scripts disponibles
- **decisiones.md**: Registro de decisiones técnicas y arquitectónicas
- **troubleshooting.md**: Guía de resolución de problemas comunes
- **architecture.md**: Arquitectura detallada del sistema completo
- **workflows.md**: Flujos de trabajo y procesos del sistema
- **components.md**: Documentación técnica de componentes individuales
