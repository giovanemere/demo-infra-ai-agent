# Setup y Configuración

## Requisitos del Sistema
- Windows 11 + WSL Ubuntu
- Docker y Docker Compose
- Node.js 18+
- Python 3.8+
- Git

## Variables de Entorno Requeridas
```bash
# .env file
GITHUB_TOKEN=ghp_xxxxx
GITHUB_USER=giovanemere
GITHUB_REPO=demo-infra-ai-agent
GEMINI_API_KEY=xxxxx
POSTGRES_PASSWORD=xxxxx
```

## Instalación Inicial
```bash
# Clonar repositorio
git clone https://github.com/giovanemere/demo-infra-ai-agent.git
cd demo-infra-ai-agent

# Configurar variables
cp .env.example .env
# Editar .env con credenciales reales

# Iniciar servicios
./start-platform.sh
```

## Verificación Post-Instalación
```bash
# Verificar servicios
curl http://localhost:8000/health
curl http://localhost:3000

# Probar integración
./test-github-backstage.sh
```

## Estructura de Puertos
- 8000: AI Agent API
- 3000: Backstage Frontend
- 7007: Backstage Backend
- 5432: PostgreSQL

## Gestión de Configuraciones .env ↔ PostgreSQL

### Ubicación PostgreSQL
```bash
/home/giovanemere/docker/postgres/
├── docker-compose.yml
├── start-postgres.sh
└── README.md
```

### Credenciales PostgreSQL
- Host: localhost:5432
- Database: backstage
- User: backstage
- Password: backstage123

### Sincronización .env
El sistema mantiene respaldo de configuraciones .env en PostgreSQL:
```bash
# Guardar .env actual en DB
cd /home/giovanemere/demos/backstage-idp
./manage-config.sh save

# Restaurar .env desde DB
./manage-config.sh restore

# Backup completo (DB + archivo)
./manage-config.sh backup
```
