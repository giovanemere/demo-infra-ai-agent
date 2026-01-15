#!/bin/bash

echo "🚀 Iniciando Infra AI Agent..."

# Verificar SSH
./check-ssh.sh
if [ $? -ne 0 ]; then
    echo "❌ Configura SSH antes de continuar"
    exit 1
fi

# Verificar .env
if [ ! -f .env ]; then
    echo "❌ Archivo .env no encontrado. Copia .env.example a .env y configura tus API keys"
    exit 1
fi

# Instalar dependencias
pip install -r requirements.txt

# Iniciar servidor
cd agent
python main.py
