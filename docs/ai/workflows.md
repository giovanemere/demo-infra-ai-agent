# Flujos de Trabajo - Infrastructure AI Platform

## Flujo Principal: Análisis de Infraestructura

### 1. Procesamiento de Texto
```
Usuario → Frontend → /process-text → Gemini AI → GitHub → Backstage
```

**Pasos detallados**:
1. Usuario ingresa descripción de infraestructura
2. Frontend envía POST a `/process-text`
3. AI Agent procesa con Gemini API
4. Genera archivos YAML para Backstage
5. Crea repositorio en GitHub
6. Backstage auto-descubre el componente

### 2. Procesamiento de Imágenes
```
Usuario → Frontend → /process-image → Gemini Vision → GitHub → Backstage
```

**Pasos detallados**:
1. Usuario sube imagen de arquitectura
2. Frontend envía POST a `/process-image`
3. Gemini Vision analiza la imagen
4. Extrae componentes y relaciones
5. Genera definiciones Backstage
6. Actualiza catálogo automáticamente

## Flujo de Configuración

### Sincronización .env ↔ PostgreSQL
```bash
# Backup .env → PostgreSQL
./manage-config.sh backup

# Restore PostgreSQL → .env
./manage-config.sh restore
```

**Proceso interno**:
1. `manage-config.sh` ejecuta `config-manager.js`
2. Node.js lee/escribe archivos .env
3. Conecta a PostgreSQL usando `pg` client
4. Sincroniza configuraciones bidireccional

### Gestión Multi-Repositorio
```bash
# Sincronizar todos los repos
./sync-all-repositories.sh

# Verificar estado completo
./verify-complete-solution.sh
```

## Flujo de Desarrollo

### Task Runner Dinámico
```bash
# Listar tareas disponibles
./task-runner.sh

# Ejecutar tarea específica
./task-runner.sh start
./task-runner.sh test
./task-runner.sh backup
```

**Tareas disponibles**:
- `check`: Verificar prerequisitos
- `status`: Estado de servicios
- `start`: Iniciar plataforma
- `stop`: Detener servicios
- `test`: Ejecutar pruebas
- `backup`: Backup configuraciones
- `sync`: Sincronizar repos
- `diagnose`: Diagnóstico sistema
- `env`: Gestión variables entorno
- `commit`: Git commit interactivo
- `push`: Git push con validación
- `tag`: Crear tags versionado
- `deploy`: Despliegue automatizado
- `pull`: Actualizar repos

### Flujo Git Integrado
```bash
# Commit interactivo
./task-runner.sh commit

# Push con validación
./task-runner.sh push

# Crear tag de versión
./task-runner.sh tag
```

## Flujo de Validación

### Verificación Sistema Completo
```bash
# Verificar prerequisitos
./check-prerequisites.sh

# Validar conectividad GitHub-Backstage
./test-github-backstage.sh

# Estado completo de la solución
./verify-complete-solution.sh
```

### Validaciones Backstage
```bash
# Verificar autenticación GitHub
cd backstage-idp/scripts
./validate-github-auth.sh

# Verificar sincronización catálogo
./verify-catalog-sync.sh

# Check sistema general
./system-check.sh
```

## Flujo de Datos AI

### Procesamiento con Gemini
```python
# text.py - Procesamiento de texto
def process_text_with_gemini(description):
    prompt = f"Analiza esta infraestructura: {description}"
    response = gemini_client.generate_content(prompt)
    return parse_infrastructure_components(response)

# vision.py - Procesamiento de imágenes
def process_image_with_gemini(image_data):
    response = gemini_client.generate_content([
        "Analiza esta arquitectura de infraestructura",
        image_data
    ])
    return extract_components_from_vision(response)
```

### Generación de Artefactos
```python
# Generar catalog-info.yaml
def generate_catalog_info(components):
    return {
        "apiVersion": "backstage.io/v1alpha1",
        "kind": "Component",
        "metadata": {
            "name": components["name"],
            "description": components["description"]
        },
        "spec": {
            "type": "service",
            "lifecycle": "production",
            "owner": "platform-team"
        }
    }
```

## Flujo de Integración GitHub

### Creación Automática de Repositorios
```python
# git_client.py
def create_repository_with_files(repo_name, files):
    # Crear repositorio
    repo = github_client.create_repo(repo_name)
    
    # Subir archivos
    for file_path, content in files.items():
        repo.create_file(file_path, "Initial commit", content)
    
    return repo.html_url
```

### Auto-discovery en Backstage
```yaml
# app-config.yaml
catalog:
  locations:
    - type: github-discovery
      target: https://github.com/giovanemere/*/blob/main/catalog-info.yaml
  rules:
    - allow: [Component, System, API, Resource]
```

## Flujo de Monitoreo

### Health Checks
```bash
# Verificar servicios activos
curl http://localhost:8000/health
curl http://localhost:3000/api/catalog/health
curl http://localhost:7007/api/catalog/health
```

### Logs y Diagnóstico
```bash
# Logs AI Agent
tail -f infra-ai-agent/logs/app.log

# Logs Backstage
tail -f backstage-idp/infra-ai-backstage/backstage.log

# Diagnóstico completo
./task-runner.sh diagnose
```

## Flujo de Backup y Restore

### Backup Completo
```bash
# Backup configuraciones
./task-runner.sh backup

# Backup manual con timestamp
./manage-env-configs.sh backup
```

### Restore de Configuraciones
```bash
# Restore desde PostgreSQL
./manage-config.sh restore

# Restore desde archivo específico
./manage-env-configs.sh restore backup-20240120-111314.env
```
