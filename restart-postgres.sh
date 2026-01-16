#!/bin/bash
# Reiniciar PostgreSQL
echo "🔄 Reiniciando PostgreSQL..."

# Detener contenedor
docker stop backstage-postgres
docker rm backstage-postgres

# Iniciar nuevo contenedor
docker run -d --name backstage-postgres \
  -e POSTGRES_USER=backstage \
  -e POSTGRES_PASSWORD=backstage \
  -e POSTGRES_DB=backstage \
  -p 5432:5432 \
  postgres:13

echo "✅ PostgreSQL reiniciado en puerto 5432"
