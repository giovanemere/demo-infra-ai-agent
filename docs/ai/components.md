# Componentes Técnicos - Infrastructure AI Platform

## AI Agent (FastAPI Service)

### Estructura del Servicio
```python
# main.py - Aplicación principal
from fastapi import FastAPI, File, UploadFile
from fastapi.staticfiles import StaticFiles
from processors import text, vision
from validators import backstage

app = FastAPI(title="Infrastructure AI Agent")
app.mount("/static", StaticFiles(directory="static"), name="static")

@app.post("/process-text")
async def process_text(description: str):
    result = text.process_with_gemini(description)
    return backstage.create_component(result)

@app.post("/process-image")
async def process_image(file: UploadFile):
    result = vision.analyze_architecture(file)
    return backstage.create_component(result)
```

### Procesadores AI

#### Text Processor
```python
# processors/text.py
import google.generativeai as genai

class TextProcessor:
    def __init__(self, api_key):
        genai.configure(api_key=api_key)
        self.model = genai.GenerativeModel('gemini-pro')
    
    def process_with_gemini(self, description):
        prompt = self._build_infrastructure_prompt(description)
        response = self.model.generate_content(prompt)
        return self._parse_response(response.text)
    
    def _build_infrastructure_prompt(self, description):
        return f"""
        Analiza esta descripción de infraestructura y extrae:
        - Componentes principales
        - Tecnologías utilizadas
        - Relaciones entre componentes
        - Puertos y configuraciones
        
        Descripción: {description}
        
        Responde en formato JSON estructurado.
        """
```

#### Vision Processor
```python
# processors/vision.py
import google.generativeai as genai
from PIL import Image

class VisionProcessor:
    def __init__(self, api_key):
        genai.configure(api_key=api_key)
        self.model = genai.GenerativeModel('gemini-pro-vision')
    
    def analyze_architecture(self, image_file):
        image = Image.open(image_file.file)
        prompt = self._build_vision_prompt()
        response = self.model.generate_content([prompt, image])
        return self._extract_components(response.text)
    
    def _build_vision_prompt(self):
        return """
        Analiza este diagrama de arquitectura e identifica:
        - Servicios y componentes
        - Bases de datos
        - APIs y endpoints
        - Flujos de datos
        - Tecnologías representadas
        
        Extrae la información en formato estructurado.
        """
```

### Validadores Backstage

```python
# validators/backstage.py
import yaml
from typing import Dict, List

class BackstageValidator:
    def create_component(self, ai_result: Dict) -> Dict:
        component = {
            "apiVersion": "backstage.io/v1alpha1",
            "kind": "Component",
            "metadata": {
                "name": self._sanitize_name(ai_result["name"]),
                "description": ai_result["description"],
                "tags": ai_result.get("technologies", [])
            },
            "spec": {
                "type": "service",
                "lifecycle": "production",
                "owner": "platform-team",
                "system": ai_result.get("system", "infrastructure")
            }
        }
        
        if "apis" in ai_result:
            component["spec"]["providesApis"] = ai_result["apis"]
        
        return component
    
    def validate_yaml(self, yaml_content: str) -> bool:
        try:
            yaml.safe_load(yaml_content)
            return True
        except yaml.YAMLError:
            return False
```

## Backstage Configuration

### App Config Principal
```yaml
# app-config.yaml
app:
  title: Infrastructure AI Platform
  baseUrl: http://localhost:3000

organization:
  name: Infrastructure AI Team

backend:
  baseUrl: http://localhost:7007
  listen:
    port: 7007
  csp:
    connect-src: ["'self'", 'http:', 'https:']
  cors:
    origin: http://localhost:3000
    methods: [GET, HEAD, PATCH, POST, PUT, DELETE]
    credentials: true
  database:
    client: pg
    connection:
      host: ${POSTGRES_HOST}
      port: ${POSTGRES_PORT}
      user: ${POSTGRES_USER}
      password: ${POSTGRES_PASSWORD}
      database: ${POSTGRES_DB}

integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}

catalog:
  import:
    entityFilename: catalog-info.yaml
    pullRequestBranchName: backstage-integration
  rules:
    - allow: [Component, System, API, Resource, Location]
  locations:
    - type: url
      target: https://github.com/giovanemere/demo-infra-ai-agent/blob/main/catalog-info.yaml
    - type: github-discovery
      target: https://github.com/giovanemere/*/blob/main/catalog-info.yaml

auth:
  providers:
    github:
      development:
        clientId: ${AUTH_GITHUB_CLIENT_ID}
        clientSecret: ${AUTH_GITHUB_CLIENT_SECRET}
```

### Package.json Backstage
```json
{
  "name": "infra-ai-backstage",
  "version": "1.0.0",
  "private": true,
  "engines": {
    "node": "18 || 20"
  },
  "scripts": {
    "dev": "concurrently \"yarn start\" \"yarn start-backend\"",
    "start": "yarn workspace app start",
    "start-backend": "yarn workspace backend start",
    "build": "backstage-cli repo build --all",
    "build-image": "yarn build && yarn build-backend",
    "tsc": "tsc",
    "tsc:full": "tsc --skipLibCheck false --incremental false",
    "clean": "backstage-cli repo clean",
    "test": "backstage-cli repo test",
    "test:all": "backstage-cli repo test --coverage",
    "lint": "backstage-cli repo lint --since origin/main",
    "lint:all": "backstage-cli repo lint",
    "prettier:check": "prettier --check .",
    "new": "backstage-cli new --scope internal"
  },
  "workspaces": {
    "packages": [
      "packages/*",
      "plugins/*"
    ]
  },
  "dependencies": {
    "@backstage/cli": "^0.25.2"
  },
  "devDependencies": {
    "@backstage/cli": "^0.25.2",
    "@spotify/prettier-config": "^12.0.0",
    "concurrently": "^8.0.0",
    "lerna": "^7.3.0",
    "node-gyp": "^9.0.0",
    "prettier": "^2.3.2",
    "typescript": "~5.2.0"
  }
}
```

## PostgreSQL Configuration Manager

### Script de Gestión
```bash
#!/bin/bash
# manage-config.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_MANAGER="$SCRIPT_DIR/config-manager.js"

case "$1" in
    backup)
        echo "Backing up .env files to PostgreSQL..."
        node "$CONFIG_MANAGER" backup
        ;;
    restore)
        echo "Restoring .env files from PostgreSQL..."
        node "$CONFIG_MANAGER" restore
        ;;
    *)
        echo "Usage: $0 {backup|restore}"
        exit 1
        ;;
esac
```

### Node.js Config Manager
```javascript
// config-manager.js
const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

class ConfigManager {
    constructor() {
        this.client = new Client({
            host: process.env.POSTGRES_HOST || 'localhost',
            port: process.env.POSTGRES_PORT || 5432,
            user: process.env.POSTGRES_USER || 'backstage',
            password: process.env.POSTGRES_PASSWORD || 'backstage123',
            database: process.env.POSTGRES_DB || 'backstage'
        });
    }

    async backup() {
        await this.client.connect();
        
        // Crear tabla si no existe
        await this.client.query(`
            CREATE TABLE IF NOT EXISTS config_backups (
                id SERIAL PRIMARY KEY,
                file_path VARCHAR(255) NOT NULL,
                content TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        `);

        // Backup archivos .env
        const envFiles = this.findEnvFiles();
        for (const filePath of envFiles) {
            const content = fs.readFileSync(filePath, 'utf8');
            await this.client.query(
                'INSERT INTO config_backups (file_path, content) VALUES ($1, $2)',
                [filePath, content]
            );
        }

        await this.client.end();
        console.log(`Backed up ${envFiles.length} .env files`);
    }

    async restore() {
        await this.client.connect();
        
        const result = await this.client.query(`
            SELECT DISTINCT ON (file_path) file_path, content 
            FROM config_backups 
            ORDER BY file_path, created_at DESC
        `);

        for (const row of result.rows) {
            fs.writeFileSync(row.file_path, row.content);
            console.log(`Restored: ${row.file_path}`);
        }

        await this.client.end();
    }

    findEnvFiles() {
        const envFiles = [];
        const searchDirs = [
            '../infra-ai-agent',
            './infra-ai-backstage',
            '../'
        ];

        for (const dir of searchDirs) {
            const envPath = path.join(__dirname, dir, '.env');
            if (fs.existsSync(envPath)) {
                envFiles.push(envPath);
            }
        }

        return envFiles;
    }
}

// Ejecutar según argumento
const action = process.argv[2];
const manager = new ConfigManager();

if (action === 'backup') {
    manager.backup().catch(console.error);
} else if (action === 'restore') {
    manager.restore().catch(console.error);
} else {
    console.log('Usage: node config-manager.js {backup|restore}');
}
```

## Task Runner System

### Script Principal
```bash
#!/bin/bash
# task-runner.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Descubrimiento dinámico de tareas
discover_tasks() {
    echo "Available tasks:"
    echo "  check     - Check prerequisites"
    echo "  status    - Show services status"
    echo "  start     - Start platform"
    echo "  stop      - Stop platform"
    echo "  test      - Run tests"
    echo "  backup    - Backup configurations"
    echo "  sync      - Sync repositories"
    echo "  diagnose  - System diagnostics"
    echo "  env       - Environment management"
    echo "  commit    - Interactive git commit"
    echo "  push      - Git push with validation"
    echo "  tag       - Create version tag"
    echo "  deploy    - Deploy platform"
    echo "  pull      - Update repositories"
}

# Funciones de tareas
task_start() {
    echo "Starting Infrastructure AI Platform..."
    ./start-platform.sh
}

task_stop() {
    echo "Stopping Infrastructure AI Platform..."
    ./stop-platform.sh
}

task_check() {
    echo "Checking prerequisites..."
    ./check-prerequisites.sh
}

task_backup() {
    echo "Creating configuration backup..."
    cd backstage-idp && ./manage-config.sh backup
}

task_commit() {
    echo "Interactive git commit..."
    git add .
    echo "Enter commit message:"
    read -r commit_msg
    git commit -m "$commit_msg"
}

task_tag() {
    echo "Creating version tag..."
    echo "Current version: $(git describe --tags --abbrev=0 2>/dev/null || echo 'v0.0.0')"
    echo "Enter new version (e.g., v1.2.1):"
    read -r version
    git tag -a "$version" -m "Release $version"
    echo "Created tag: $version"
}

# Ejecutar tarea
if [ $# -eq 0 ]; then
    discover_tasks
else
    task_name="task_$1"
    if declare -f "$task_name" > /dev/null; then
        "$task_name"
    else
        echo "Unknown task: $1"
        discover_tasks
    fi
fi
```

## Docker Configuration

### Docker Compose
```yaml
# docker-compose.yml
version: '3.8'

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_USER: backstage
      POSTGRES_PASSWORD: backstage123
      POSTGRES_DB: backstage
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  backstage:
    build: 
      context: ./infra-ai-backstage
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
      - "7007:7007"
    environment:
      - POSTGRES_HOST=postgres
      - POSTGRES_PORT=5432
      - POSTGRES_USER=backstage
      - POSTGRES_PASSWORD=backstage123
      - POSTGRES_DB=backstage
    depends_on:
      - postgres
    volumes:
      - ./infra-ai-backstage:/app

volumes:
  postgres_data:
```

### Dockerfile Backstage
```dockerfile
# Dockerfile
FROM node:18-alpine

WORKDIR /app

# Copiar archivos de configuración
COPY package*.json ./
COPY yarn.lock ./

# Instalar dependencias
RUN yarn install --frozen-lockfile

# Copiar código fuente
COPY . .

# Build de la aplicación
RUN yarn build:backend
RUN yarn build

# Exponer puertos
EXPOSE 3000 7007

# Comando de inicio
CMD ["yarn", "dev"]
```
