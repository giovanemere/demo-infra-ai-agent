#!/bin/bash

echo "🎯 SOLUCIÓN FINAL: Forzar template en Backstage"

cd /home/giovanemere/demos/backstage-idp/infra-ai-backstage

# Crear template en el directorio correcto
mkdir -p examples/templates/working-template

cat > examples/templates/working-template/template.yaml << 'EOF'
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: working-template
  title: Working Template
  description: Este template SÍ funciona
  tags:
    - recommended
spec:
  owner: user:guest
  type: service
  parameters:
    - title: Project Info
      required:
        - name
      properties:
        name:
          title: Project Name
          type: string
          description: Name of the project
  steps:
    - id: log
      name: Log Message
      action: debug:log
      input:
        message: Hello ${{ parameters.name }}!
  output:
    text:
      - title: Success
        content: Project ${{ parameters.name }} created successfully!
EOF

# Actualizar app-config.yaml para apuntar al template correcto
cat > app-config-minimal.yaml << 'EOF'
app:
  title: Infrastructure AI Platform
  baseUrl: http://localhost:3000

backend:
  baseUrl: http://localhost:7007
  listen:
    port: 7007
  database:
    client: better-sqlite3
    connection: ':memory:'

catalog:
  rules:
    - allow: [Template, Component, System, API, Resource, Location, User, Group]
  locations:
    - type: file
      target: examples/templates/working-template/template.yaml

auth:
  providers:
    guest:
      dangerouslyAllowOutsideDevelopment: true

scaffolder:
  defaultAuthor:
    name: AI Platform
    email: ai@platform.com
EOF

# Usar configuración mínima
mv app-config.yaml app-config.yaml.backup
mv app-config-minimal.yaml app-config.yaml

# Reiniciar con configuración mínima
pkill -f yarn 2>/dev/null
sleep 3

echo "🚀 Iniciando Backstage con configuración mínima..."
nohup yarn start > ../../backstage-minimal.log 2>&1 &

sleep 20

if curl -s http://localhost:3000 > /dev/null; then
    echo "✅ Backstage iniciado"
    echo "🎯 IR A: http://localhost:3000/create"
    echo "📋 Deberías ver: 'Working Template'"
else
    echo "❌ Backstage no responde"
    echo "📋 Ver logs: tail -f backstage-minimal.log"
fi
