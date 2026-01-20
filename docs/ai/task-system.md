# Sistema de Tareas Dinámicas

## Descripción
El `task-runner.sh` es un sistema unificado que permite ejecutar todas las tareas del proyecto de forma dinámica y organizada.

## Uso Básico
```bash
./task-runner.sh <tarea>
```

## Tareas Disponibles

### 🔍 check - Verificar Prerequisites
```bash
./task-runner.sh check
```
- Verifica Python, Node.js, Docker, Git
- Comprueba dependencias instaladas
- Valida configuración del sistema

### 📊 status - Estado Completo
```bash
./task-runner.sh status
```
- Estructura de directorios
- Estado de servicios
- Configuraciones activas
- Conectividad GitHub-Backstage

### 🚀 start - Iniciar Plataforma
```bash
./task-runner.sh start
```
- Inicia PostgreSQL
- Inicia AI Agent
- Inicia Backstage
- Verifica servicios

### 🛑 stop - Detener Servicios
```bash
./task-runner.sh stop
```
- Detiene todos los contenedores
- Limpia procesos activos

### 🧪 test - Probar Conectividad
```bash
./task-runner.sh test
```
- Verifica token GitHub
- Prueba API Backstage
- Valida catálogo

### 💾 backup - Backup Configuraciones
```bash
./task-runner.sh backup
```
- Backup archivos .env
- Backup configuración PostgreSQL
- Crea timestamps

### 🔄 sync - Sincronizar Repositorios
```bash
./task-runner.sh sync
```
- Actualiza todos los repos
- Sincroniza cambios
- Verifica estado Git

### 🔧 diagnose - Diagnosticar Problemas
```bash
./task-runner.sh diagnose
```
- Diagnóstico Backstage
- Verificación sistema
- Logs de errores

### ⚙️ env - Gestionar Variables
```bash
./task-runner.sh env
```
- Valida variables requeridas
- Verifica configuración
- Reporta problemas

### 📝 commit - Commit Interactivo
```bash
./task-runner.sh commit
```
- Muestra estado de archivos
- Solicita mensaje de commit
- Ejecuta git add + commit

### 🚀 push - Subir Cambios
```bash
./task-runner.sh push
```
- Sube cambios al repositorio remoto
- Usa la rama actual

### 🏷️ tag - Crear Tag de Versión
```bash
./task-runner.sh tag v1.3.0
```
- Crea tag anotado
- Sube tag a GitHub
- Solicita versión si no se especifica

### 🚢 deploy - Deploy Completo
```bash
./task-runner.sh deploy v1.3.0
```
- Ejecuta commit interactivo
- Crea tag de versión (opcional)
- Sube todos los cambios

### ⬇️ pull - Actualizar Repositorios
```bash
./task-runner.sh pull
```
- Actualiza repositorio principal
- Actualiza todos los sub-repositorios
- Maneja errores graciosamente

## Ventajas del Sistema
- **Unificado**: Un solo punto de entrada
- **Dinámico**: Fácil agregar nuevas tareas
- **Consistente**: Mismo formato para todas las operaciones
- **Documentado**: Ayuda integrada
- **Robusto**: Manejo de errores y validaciones
