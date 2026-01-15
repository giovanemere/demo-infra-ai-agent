#!/bin/bash

echo "🔑 Verificando configuración SSH para GitHub..."

# Verificar si existe clave SSH
if [ ! -f ~/.ssh/id_rsa ] && [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "❌ No se encontró clave SSH. Genera una con:"
    echo "ssh-keygen -t ed25519 -C 'your_email@example.com'"
    exit 1
fi

# Verificar conexión SSH a GitHub
echo "🔍 Probando conexión SSH a GitHub..."
ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"

if [ $? -eq 0 ]; then
    echo "✅ SSH configurado correctamente para GitHub"
else
    echo "❌ Error en configuración SSH. Verifica:"
    echo "1. Clave SSH agregada a GitHub: https://github.com/settings/keys"
    echo "2. SSH Agent ejecutándose: eval \$(ssh-agent -s) && ssh-add ~/.ssh/id_ed25519"
fi
