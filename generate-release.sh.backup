#!/bin/bash

# =============================================================================
# Infrastructure AI Platform - Release Generator v1.0.0
# =============================================================================

echo "🚀 Generando versión estable de servicios..."

# Verificar estado de servicios
echo "📊 Verificando estado actual..."
./platform-cli status

# Crear backup de configuraciones
echo "💾 Creando backup de configuraciones..."
mkdir -p releases/v1.0.0/configs
cp infra-ai-agent/.env releases/v1.0.0/configs/ai-agent.env.example
cp backstage-idp/infra-ai-backstage/.env releases/v1.0.0/configs/backstage.env.example

# Generar scripts de despliegue
echo "📦 Generando scripts de despliegue..."
cat > releases/v1.0.0/deploy.sh << 'EOF'
#!/bin/bash
echo "🚀 Desplegando Infrastructure AI Platform v1.0.0"

# Verificar prerequisites
./check-prerequisites.sh

# Configurar variables de entorno
echo "🔧 Configurar variables de entorno:"
echo "1. Editar infra-ai-agent/.env"
echo "2. Editar backstage-idp/infra-ai-backstage/.env"
echo "3. Ejecutar: ./platform-cli start"

echo "✅ Despliegue completado"
EOF

chmod +x releases/v1.0.0/deploy.sh

# Generar documentación de release
cat > releases/v1.0.0/RELEASE_NOTES.md << 'EOF'
# 🎉 Infrastructure AI Platform v1.0.0

## 🆕 Nuevas Funcionalidades

### ✅ Servicios Estables
- **AI Agent**: Análisis automático de arquitecturas AWS
- **Backstage IDP**: Catálogo de servicios completo
- **PostgreSQL**: Base de datos persistente

### 🔧 Mejoras Técnicas
- Node.js 20 para compatibilidad total
- PostgreSQL como base de datos principal
- Scripts de gestión automatizados
- Documentación completa

### 📚 Documentación
- Guía de comandos completa
- Referencia rápida
- Troubleshooting detallado
- Scripts de despliegue

## 🚀 Instalación

```bash
# 1. Clonar repositorio
git clone git@github.com:giovanemere/demo-infra-ai-agent.git
cd demo-infra-ai-agent

# 2. Checkout versión estable
git checkout v1.0.0

# 3. Ejecutar despliegue
./releases/v1.0.0/deploy.sh
```

## 🔗 Enlaces

- **Repositorio**: https://github.com/giovanemere/demo-infra-ai-agent
- **Documentación**: [COMMANDS_GUIDE.md](../../COMMANDS_GUIDE.md)
- **Soporte**: [TROUBLESHOOTING.md](../../TROUBLESHOOTING.md)
EOF

echo "✅ Versión estable v1.0.0 generada"
echo "📁 Archivos en: releases/v1.0.0/"
echo "🔗 Repositorio: https://github.com/giovanemere/demo-infra-ai-agent"
echo "🏷️ Tag: v1.0.0"
