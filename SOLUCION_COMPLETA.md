# 🚀 Solución Completa: Templates AWS en Backstage

## ✅ Problemas Resueltos

### 1. **start-platform.sh Actualizado**
- ✅ **PostgreSQL**: Inicia automáticamente (puerto 5432)
- ✅ **MinIO**: Almacenamiento distribuido (puerto 9000/9001)
- ✅ **AI Agent**: Procesamiento IA (puerto 8000)
- ✅ **Backstage**: Catálogo IDP (puerto 3000)

### 2. **Templates AWS Disponibles**
- ✅ **ai-infrastructure-project**: Template base de infraestructura
- ✅ **aws-simple-web-app**: Aplicación web con S3 + CloudFront
- ✅ **aws-web-app**: Template generado automáticamente por IA

### 3. **Configuración Backstage Corregida**
- ✅ **Auto-discovery**: Detecta templates automáticamente desde GitHub
- ✅ **Catalog Integration**: Sincronización cada 2 minutos
- ✅ **Template Registration**: Registro automático de nuevos templates

## 🚀 Comandos de Inicio

### **Inicio Completo de la Plataforma**
```bash
cd /home/giovanemere/demos
./start-platform.sh
```

### **Servicios Iniciados**
```
✅ PostgreSQL funcionando en :5432
✅ MinIO funcionando en :9000
✅ AI Agent funcionando en :8000
✅ Backstage funcionando en :3000 (puede tardar 30-60 segundos)
```

### **Verificar Templates**
```bash
./check-templates.sh
```

## 🌐 URLs de Acceso

| Servicio | URL | Función |
|----------|-----|---------|
| **AI Agent** | http://localhost:8000 | Crear templates automáticamente |
| **Backstage** | http://localhost:3000 | Catálogo principal |
| **Create Component** | http://localhost:3000/create | **Ver y usar templates** |
| **MinIO Console** | http://localhost:9001 | Gestión de archivos |

## 🎯 Cómo Ver los Templates en Backstage

### **Método 1: Acceso Directo**
1. Abrir http://localhost:3000
2. Hacer clic en **"Create Component"** en el menú lateral
3. Los templates aparecerán automáticamente

### **Método 2: Registro Manual (si no aparecen)**
1. Ir a http://localhost:3000/catalog
2. Hacer clic en **"Register Existing Component"**
3. Pegar la URL: 
   ```
   https://github.com/giovanemere/demo-infra-ai-agent-template-idp/blob/main/catalog-info.yaml
   ```
4. Hacer clic en **"Analyze"** y luego **"Import"**

### **Método 3: Registro Individual de Templates**
```bash
# Registrar template específico
curl -X POST "http://localhost:7007/api/catalog/locations" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "url",
    "target": "https://github.com/giovanemere/demo-infra-ai-agent-template-idp/blob/main/templates/aws-simple-web-app/template.yaml"
  }'
```

## 📋 Templates Disponibles

### **1. AWS Simple Web App**
- **Servicios**: S3 + CloudFront
- **Uso**: Aplicaciones web estáticas
- **Parámetros**: Región AWS, Ambiente, Dominio

### **2. AI Infrastructure Project**
- **Servicios**: Infraestructura general
- **Uso**: Proyectos de infraestructura
- **Parámetros**: Nombre, Descripción, Tecnología

### **3. Templates Generados por IA**
- **Creación**: Automática desde descripciones/imágenes
- **Servicios**: Detectados automáticamente (S3, Lambda, RDS, etc.)
- **Documentación**: Generada automáticamente

## 🔧 Crear Nuevos Templates

### **Método 1: Desde Descripción de Texto**
```bash
curl -X POST "http://localhost:8000/process-text" \
  -F "description=Aplicación serverless con Lambda, API Gateway y DynamoDB"
```

### **Método 2: Desde Imagen de Arquitectura**
```bash
curl -X POST "http://localhost:8000/process-image" \
  -F "file=@aws-architecture.png"
```

### **Método 3: Template Manual**
```bash
curl -X POST "http://localhost:8000/create-template" \
  -H "Content-Type: application/json" \
  -d '{
    "template_name": "aws-microservices",
    "template_title": "AWS Microservices Platform",
    "template_description": "Plataforma de microservicios con ECS y API Gateway",
    "technology": "aws",
    "component_type": "service",
    "tags": "aws, microservices, ecs",
    "owner": "group:default/developers",
    "parameters": [
      {"name": "cluster_name", "title": "ECS Cluster Name", "type": "string"}
    ]
  }'
```

## 🔄 Flujo Completo de Uso

### **1. Crear Template con IA**
```
Descripción AWS → AI Agent → Template Generado → GitHub → Backstage
```

### **2. Usar Template en Backstage**
```
Backstage Create → Seleccionar Template → Configurar → Deploy a GitHub
```

### **3. Resultado Final**
```
Nuevo Repositorio → Código AWS → Documentación → Catálogo Backstage
```

## 📊 Monitoreo y Logs

### **Verificar Estado de Servicios**
```bash
# Estado completo
curl http://localhost:8000/api/services/status

# Logs individuales
tail -f infra-ai-agent/ai-agent.log    # AI Agent
tail -f backstage.log                  # Backstage
tail -f minio.log                      # MinIO
```

### **Verificar Templates**
```bash
# Templates en GitHub
curl -s https://api.github.com/repos/giovanemere/demo-infra-ai-agent-template-idp/contents/templates

# Templates en Backstage (requiere autenticación)
curl http://localhost:7007/api/catalog/entities?filter=kind=template
```

## 🛠️ Troubleshooting

### **Si Backstage no muestra templates:**
1. Esperar 2-5 minutos para sincronización automática
2. Verificar logs: `tail -f backstage.log`
3. Registrar manualmente la ubicación (Método 2 arriba)
4. Reiniciar Backstage: `pkill -f yarn && cd backstage-idp/infra-ai-backstage && yarn start`

### **Si AI Agent no responde:**
1. Verificar: `curl http://localhost:8000/health`
2. Ver logs: `tail -f infra-ai-agent/ai-agent.log`
3. Reiniciar: `./start-platform.sh`

### **Si MinIO no funciona:**
1. Verificar: `nc -z localhost 9000`
2. Instalar MinIO: `wget https://dl.min.io/server/minio/release/linux-amd64/minio && chmod +x minio && sudo mv minio /usr/local/bin/`

## 🎯 Próximos Pasos

1. **Abrir Backstage**: http://localhost:3000
2. **Ir a Create Component**: http://localhost:3000/create
3. **Seleccionar un template AWS**
4. **Configurar parámetros**
5. **Crear proyecto**
6. **Ver resultado en el catálogo**

---
*Plataforma completamente funcional con templates AWS automáticos*
*Versión: v1.3.0 - Templates AWS + MinIO + PostgreSQL*
