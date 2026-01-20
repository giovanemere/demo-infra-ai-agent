#!/bin/bash

# =============================================================================
# Backup y Restore de Configuraciones .env (Usando archivos)
# =============================================================================

BACKUP_DIR="/home/giovanemere/demos/.env-backups"
mkdir -p "$BACKUP_DIR"

# Función para hacer backup de .env
backup_env_configs() {
    echo "💾 Haciendo backup de configuraciones .env..."
    
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    
    # Backup AI Agent .env
    if [ -f "infra-ai-agent/.env" ]; then
        cp infra-ai-agent/.env "$BACKUP_DIR/ai-agent_${TIMESTAMP}.env"
        cp infra-ai-agent/.env "$BACKUP_DIR/ai-agent_latest.env"
        echo "✅ AI Agent .env respaldado"
    fi
    
    # Backup Backstage .env
    if [ -f "backstage-idp/infra-ai-backstage/.env" ]; then
        cp backstage-idp/infra-ai-backstage/.env "$BACKUP_DIR/backstage_${TIMESTAMP}.env"
        cp backstage-idp/infra-ai-backstage/.env "$BACKUP_DIR/backstage_latest.env"
        echo "✅ Backstage .env respaldado"
    fi
    
    echo "📁 Backups guardados en: $BACKUP_DIR"
}

# Función para restaurar .env
restore_env_configs() {
    echo "🔄 Restaurando configuraciones .env..."
    
    # Restaurar AI Agent .env
    if [ -f "$BACKUP_DIR/ai-agent_latest.env" ]; then
        cp "$BACKUP_DIR/ai-agent_latest.env" infra-ai-agent/.env
        echo "✅ AI Agent .env restaurado"
    else
        echo "⚠️  No se encontró backup de AI Agent"
    fi
    
    # Restaurar Backstage .env
    if [ -f "$BACKUP_DIR/backstage_latest.env" ]; then
        cp "$BACKUP_DIR/backstage_latest.env" backstage-idp/infra-ai-backstage/.env
        echo "✅ Backstage .env restaurado"
    else
        echo "⚠️  No se encontró backup de Backstage"
    fi
}

# Función para listar backups
list_backups() {
    echo "📋 Backups disponibles:"
    ls -la "$BACKUP_DIR"
}

# Función principal
case "$1" in
    backup)
        backup_env_configs
        ;;
    restore)
        restore_env_configs
        ;;
    list)
        list_backups
        ;;
    *)
        echo "Uso: $0 {backup|restore|list}"
        echo "  backup  - Guardar configuraciones .env"
        echo "  restore - Restaurar configuraciones .env"
        echo "  list    - Listar backups disponibles"
        exit 1
        ;;
esac
