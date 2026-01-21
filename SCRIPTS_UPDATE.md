# Actualización de Scripts - Gestión Mejorada de Todos los Servicios

## Cambios Realizados

### 1. **start-platform.sh** - Mejorado
- ✅ Función `stop_service()` para detener servicios de forma segura
- ✅ Verificación de puertos libres antes de iniciar servicios
- ✅ Limpieza de cache de Backstage antes del inicio
- ✅ Timeout en el inicio de Backstage (300 segundos)
- ✅ Verificación mejorada del estado de Backstage con diagnósticos
- ✅ Uso de `--frozen-lockfile` para yarn install

### 2. **stop-platform.sh** - Mejorado
- ✅ Función `stop_service_safe()` con verificación de puertos
- ✅ Cleanup más robusto con kill -9 si es necesario
- ✅ Verificación final de puertos liberados
- ✅ Colores y logging mejorado

### 3. **task-runner.sh** - Nuevas Funciones
- ✅ `restart-backstage` - Reinicia solo Backstage
- ✅ `stop-backstage` - Detiene solo Backstage  
- ✅ `start-backstage` - Inicia solo Backstage
- ✅ `restart-ai` - Reinicia solo AI Agent
- ✅ `stop-ai` - Detiene solo AI Agent
- ✅ `start-ai` - Inicia solo AI Agent
- ✅ `restart-minio` - Reinicia solo MinIO
- ✅ `stop-minio-local` - Detiene solo MinIO
- ✅ `start-minio-local` - Inicia solo MinIO
- ✅ `quick` - Estado rápido de servicios

### 4. **quick-status.sh** - Nuevo Script
- ✅ Verificación rápida del estado de todos los servicios
- ✅ Comprobación de puertos y respuestas HTTP
- ✅ Verificación de archivos PID y procesos activos
- ✅ URLs disponibles

## Comandos Disponibles

### Gestión Completa
```bash
./task-runner.sh start          # Iniciar toda la plataforma
./task-runner.sh stop           # Detener todos los servicios
./task-runner.sh quick          # Estado rápido
./task-runner.sh status         # Estado completo
```

### Gestión Individual por Servicio
```bash
# Backstage (Puerto 3000)
./task-runner.sh restart-backstage  # Reiniciar solo Backstage
./task-runner.sh stop-backstage     # Detener solo Backstage
./task-runner.sh start-backstage    # Iniciar solo Backstage

# AI Agent (Puerto 8000)
./task-runner.sh restart-ai         # Reiniciar solo AI Agent
./task-runner.sh stop-ai            # Detener solo AI Agent
./task-runner.sh start-ai           # Iniciar solo AI Agent

# MinIO (Puerto 9000)
./task-runner.sh restart-minio      # Reiniciar solo MinIO
./task-runner.sh stop-minio-local   # Detener solo MinIO
./task-runner.sh start-minio-local  # Iniciar solo MinIO
```

### Scripts Directos
```bash
./start-platform.sh            # Inicio completo mejorado
./stop-platform.sh             # Parada completa mejorada
./quick-status.sh              # Estado rápido
```

## Mejoras Implementadas

### Gestión de Procesos
- Detección y terminación segura de procesos
- Verificación de puertos antes de iniciar servicios
- Cleanup de procesos zombie y Docker containers
- Manejo de archivos PID

### Por Servicio

#### Backstage (Puerto 3000)
- Limpieza de cache antes del inicio
- Timeout configurable para el inicio
- Verificación del proceso durante el inicio
- Diagnósticos en caso de fallo

#### AI Agent (Puerto 8000)
- Gestión de entorno virtual Python
- Verificación de dependencias
- Logs específicos del servicio
- Health check endpoint

#### MinIO (Puerto 9000)
- Soporte para Docker y binario local
- Gestión de contenedores Docker
- Credenciales configurables
- Health check endpoint

### Monitoreo
- Estado rápido de servicios
- Verificación de respuestas HTTP
- Información de PIDs y procesos
- URLs disponibles

## Resolución de Problemas por Puerto

### Puerto 3000 (Backstage) Ocupado
```bash
./task-runner.sh restart-backstage
```

### Puerto 8000 (AI Agent) Ocupado
```bash
./task-runner.sh restart-ai
```

### Puerto 9000 (MinIO) Ocupado
```bash
./task-runner.sh restart-minio
```

### Estado General
```bash
./task-runner.sh quick
```

### Reinicio Completo
```bash
./task-runner.sh stop
./task-runner.sh start
```

## Servicios Verificados ✅

- **PostgreSQL** (Puerto 5432) - Base de datos
- **AI Agent** (Puerto 8000) - API y procesamiento IA
- **MinIO** (Puerto 9000) - Almacenamiento de objetos
- **Backstage** (Puerto 3000) - Portal de desarrolladores

Los scripts ahora manejan robustamente todos los puertos y servicios, con gestión individual y colectiva.
