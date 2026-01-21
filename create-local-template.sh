#!/bin/bash

echo "🚀 SOLUCIÓN DIRECTA: Creando template que SÍ aparecerá en Backstage"

# Crear template en el directorio correcto de Backstage
TEMPLATE_DIR="/home/giovanemere/demos/backstage-idp/infra-ai-backstage/examples/templates/aws-template"
mkdir -p "$TEMPLATE_DIR/content"

# Template principal
cat > "$TEMPLATE_DIR/template.yaml" << 'EOF'
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: aws-web-template
  title: AWS Web Application
  description: Crear aplicación web en AWS con S3 y CloudFront
  tags:
    - recommended
    - aws
    - web
spec:
  owner: user:guest
  type: service
  parameters:
    - title: Información del Proyecto
      required:
        - name
        - description
      properties:
        name:
          title: Nombre
          type: string
          pattern: '^[a-zA-Z0-9-]+$'
        description:
          title: Descripción
          type: string
        region:
          title: Región AWS
          type: string
          default: us-east-1
          enum:
            - us-east-1
            - us-west-2
            - eu-west-1
  steps:
    - id: template
      name: Crear Archivos
      action: fetch:template
      input:
        url: ./content
        values:
          name: ${{ parameters.name }}
          description: ${{ parameters.description }}
          region: ${{ parameters.region }}
    - id: publish
      name: Publicar
      action: publish:github
      input:
        allowedHosts: ['github.com']
        description: ${{ parameters.description }}
        repoUrl: github.com?owner=giovanemere&repo=${{ parameters.name }}
    - id: register
      name: Registrar
      action: catalog:register
      input:
        repoContentsUrl: ${{ steps.publish.output.repoContentsUrl }}
        catalogInfoPath: '/catalog-info.yaml'
  output:
    links:
      - title: Repositorio
        url: ${{ steps.publish.output.remoteUrl }}
      - title: Catálogo
        icon: catalog
        entityRef: ${{ steps.register.output.entityRef }}
EOF

# Contenido del template
cat > "$TEMPLATE_DIR/content/catalog-info.yaml" << 'EOF'
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: ${{ values.name }}
  description: ${{ values.description }}
  tags:
    - aws
    - web
    - s3
    - cloudfront
  annotations:
    github.com/project-slug: giovanemere/${{ values.name }}
    aws.com/region: ${{ values.region }}
spec:
  type: website
  lifecycle: production
  owner: user:guest
EOF

cat > "$TEMPLATE_DIR/content/README.md" << 'EOF'
# ${{ values.name }}

## Descripción
${{ values.description }}

## Arquitectura AWS
- **S3**: Almacenamiento estático
- **CloudFront**: CDN global
- **Región**: ${{ values.region }}

## Despliegue
```bash
aws s3 mb s3://${{ values.name }} --region ${{ values.region }}
aws s3 website s3://${{ values.name }} --index-document index.html
```
EOF

# Actualizar configuración para incluir el template local
cd /home/giovanemere/demos/backstage-idp/infra-ai-backstage

# Agregar template local a app-config.yaml
if ! grep -q "examples/templates" app-config.yaml; then
    sed -i '/locations:/a\    - type: file\n      target: ./examples/templates/aws-template/template.yaml' app-config.yaml
fi

echo "✅ Template creado en: $TEMPLATE_DIR"
echo "🔄 Reiniciando Backstage..."

# Reiniciar Backstage
pkill -f "yarn.*start" 2>/dev/null
sleep 3
nohup yarn start > ../../backstage.log 2>&1 &

echo "⏳ Esperando 30 segundos para que Backstage cargue..."
sleep 30

echo ""
echo "🎯 AHORA SÍ DEBERÍA FUNCIONAR:"
echo "1. Ir a: http://localhost:3000/create"
echo "2. Deberías ver: 'AWS Web Application'"
echo "3. Si no aparece, esperar 1-2 minutos más"
echo ""
echo "📋 Template creado: aws-web-template"
