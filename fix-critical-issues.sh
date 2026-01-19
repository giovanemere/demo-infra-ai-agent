#!/bin/bash

echo "🔧 Corrección mínima - 3 problemas críticos"

# 1. Corregir template inválido
echo "1️⃣ Corrigiendo template..."
if [ -d "templates-repo" ]; then
    sed -i 's/\${{ values\.name }}/{{ values.name | replace(" ", "-") | lower }}/g' templates-repo/templates/ai-project/catalog-info.yaml
    echo "✅ Template corregido"
fi

# 2. Iniciar AI Agent
echo "2️⃣ Iniciando AI Agent..."
cd infra-ai-agent
source venv/bin/activate 2>/dev/null || python -m venv venv && source venv/bin/activate
pip install -r requirements.txt -q
nohup python -m uvicorn agent.main:app --host 0.0.0.0 --port 8000 > ai-agent.log 2>&1 &
cd ..

# 3. Instalar mkdocs
echo "3️⃣ Instalando mkdocs..."
pip install mkdocs mkdocs-material -q 2>/dev/null || echo "⚠️ mkdocs no instalado"

sleep 5

# Verificar
AI_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000)
echo ""
echo "📊 Estado:"
echo "🤖 AI Agent: $AI_STATUS"
echo "🎭 Backstage: $(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000)"

if [ "$AI_STATUS" = "200" ]; then
    echo "✅ Solución completa"
else
    echo "❌ AI Agent necesita configuración manual"
fi
