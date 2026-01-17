import os
import subprocess
import yaml
from typing import Optional
from datetime import datetime

class GitClient:
    def __init__(self, repo_url: str = None, local_path: str = "../templates-repo"):
        self.repo_url = repo_url or os.getenv('TEMPLATES_REPO', 
            'git@github.com:giovanemere/demo-infra-ai-agent-template-idp.git')
        self.local_path = local_path
        self._setup_repo()
    
    def _setup_repo(self):
        """Clona o actualiza el repositorio local"""
        try:
            if not os.path.exists(self.local_path):
                print(f"Clonando repositorio: {self.repo_url}")
                subprocess.run([
                    "git", "clone", self.repo_url, self.local_path
                ], check=True)
            else:
                print(f"Actualizando repositorio: {self.local_path}")
                subprocess.run([
                    "git", "pull", "origin", "main"
                ], cwd=self.local_path, check=False)  # No fallar si hay conflictos
        except subprocess.CalledProcessError as e:
            print(f"Error configurando repositorio: {e}")

    def create_project_structure(self, project_name: str, yaml_content: str, description: str):
        """Crear estructura completa de proyecto para Backstage"""
        
        # Crear directorio del proyecto
        project_dir = os.path.join(self.local_path, "projects", project_name)
        os.makedirs(project_dir, exist_ok=True)
        os.makedirs(os.path.join(project_dir, "docs"), exist_ok=True)
        
        # 1. Crear catalog-info.yaml principal
        catalog_info = f"""apiVersion: backstage.io/v1alpha1
kind: System
metadata:
  name: {project_name}
  title: {project_name.replace('-', ' ').title()}
  description: {description[:100]}...
  annotations:
    backstage.io/managed-by-location: url:https://github.com/giovanemere/demo-infra-ai-agent-template-idp/tree/main/projects/{project_name}/
    aws.com/cost-center: free-tier-audit
spec:
  owner: platform-team
  domain: cloud-infrastructure
---
{yaml_content}
"""
        
        # 2. Crear README.md
        readme_content = f"""# {project_name.replace('-', ' ').title()}

## 📋 Descripción
{description}

## 🏗️ Arquitectura AWS
Esta solución fue generada automáticamente por IA y utiliza los siguientes servicios:

{self._extract_services_from_yaml(yaml_content)}

## 📚 Documentación
- [Arquitectura Detallada](./docs/architecture.md)

## 🤖 Generado por
Infrastructure AI Platform - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

## 🚀 Despliegue en Backstage
Este proyecto se detecta automáticamente en Backstage a través del archivo `catalog-info.yaml`.
"""
        
        # 3. Crear documentación de arquitectura
        arch_doc = f"""# 🏗️ Arquitectura - {project_name.replace('-', ' ').title()}

## 📝 Descripción Original
{description}

## 🔍 Análisis de IA

### Servicios AWS Detectados
{self._extract_services_from_yaml(yaml_content)}

## 📊 Flujo de Procesamiento
```
[Lenguaje Natural] → [IA Gemini] → [YAML Backstage] → [Catálogo IDP]
```

## 📅 Información de Generación
- **Fecha**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
- **Procesador**: Gemini AI
- **Plataforma**: Infrastructure AI Platform
"""
        
        # Escribir archivos
        with open(os.path.join(project_dir, "catalog-info.yaml"), "w") as f:
            f.write(catalog_info)
            
        with open(os.path.join(project_dir, "README.md"), "w") as f:
            f.write(readme_content)
            
        with open(os.path.join(project_dir, "docs", "architecture.md"), "w") as f:
            f.write(arch_doc)
        
        return project_dir

    def _extract_services_from_yaml(self, yaml_content: str) -> str:
        """Extraer lista de servicios del YAML"""
        try:
            docs = list(yaml.safe_load_all(yaml_content))
            services = []
            for doc in docs:
                if isinstance(doc, dict):
                    name = doc.get('metadata', {}).get('name', 'unknown')
                    kind = doc.get('kind', 'Component')
                    service_type = doc.get('metadata', {}).get('annotations', {}).get('aws.com/service-type', 'service')
                    services.append(f"- **{service_type.upper()}**: {name} ({kind})")
            return "\n".join(services) if services else "- Servicios detectados automáticamente"
        except:
            return "- Servicios detectados automáticamente por IA"

    def save_project(self, project_name: str, yaml_content: str, description: str):
        """Guardar proyecto completo con estructura para auto-discovery"""
        try:
            # Crear estructura del proyecto
            project_dir = self.create_project_structure(project_name, yaml_content, description)
            
            # Configurar git user
            try:
                subprocess.run([
                    "git", "config", "user.email", "ai-agent@platform.local"
                ], cwd=self.local_path, check=True)
                subprocess.run([
                    "git", "config", "user.name", "Infrastructure AI Agent"
                ], cwd=self.local_path, check=True)
            except:
                pass
            
            # Commit y push
            subprocess.run(["git", "add", "."], cwd=self.local_path, check=True)
            
            result = subprocess.run([
                "git", "diff", "--cached", "--quiet"
            ], cwd=self.local_path, capture_output=True)
            
            if result.returncode != 0:  # Hay cambios
                subprocess.run([
                    "git", "commit", "-m", f"Add project: {project_name} (Auto-generated by AI)"
                ], cwd=self.local_path, check=True)
                subprocess.run([
                    "git", "push", "origin", "main"
                ], cwd=self.local_path, check=True)
            
            return f"https://github.com/giovanemere/demo-infra-ai-agent-template-idp/tree/main/projects/{project_name}/"
            
        except Exception as e:
            print(f"Error saving project: {e}")
            return f"local://{project_dir}"
    
    def save_yaml(self, filename: str, content: str, folder: str = "entities") -> str:
        """Guarda YAML y hace commit (método legacy)"""
        try:
            # Asegurar que el repo esté actualizado
            self._setup_repo()
            
            file_path = os.path.join(self.local_path, folder, filename)
            
            # Crear directorio si no existe
            os.makedirs(os.path.dirname(file_path), exist_ok=True)
            
            # Escribir archivo
            with open(file_path, 'w') as f:
                f.write(content)
            
            # Configurar git user si no está configurado
            try:
                subprocess.run([
                    "git", "config", "user.email", "ai-agent@platform.local"
                ], cwd=self.local_path, check=True)
                subprocess.run([
                    "git", "config", "user.name", "Infrastructure AI Agent"
                ], cwd=self.local_path, check=True)
            except:
                pass  # Ya está configurado
            
            # Git add, commit, push
            subprocess.run(["git", "add", "."], cwd=self.local_path, check=True)
            
            # Verificar si hay cambios para commitear
            result = subprocess.run([
                "git", "diff", "--cached", "--quiet"
            ], cwd=self.local_path, capture_output=True)
            
            if result.returncode != 0:  # Hay cambios
                subprocess.run([
                    "git", "commit", "-m", f"Add {filename} generated by AI Agent"
                ], cwd=self.local_path, check=True)
                subprocess.run([
                    "git", "push", "origin", "main"
                ], cwd=self.local_path, check=True)
            
            return f"https://github.com/giovanemere/demo-infra-ai-agent-template-idp/blob/main/{folder}/{filename}"
            
        except subprocess.CalledProcessError as e:
            print(f"Error guardando en Git: {e}")
            # Retornar URL local como fallback
            return f"local://{file_path}"
