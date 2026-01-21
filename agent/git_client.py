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
        
        # Inicializar MinIO de forma lazy
        self.minio_client = None
        self.use_minio = False
        self._minio_initialized = False
        
        self._setup_repo()
    
    def _ensure_minio_connection(self):
        """Asegurar conexión a MinIO (lazy initialization)"""
        if self._minio_initialized:
            return
        
        try:
            from storage.minio_client import MinIOClient
            self.minio_client = MinIOClient()
            self.use_minio = True
            print("✅ MinIO conectado - usando almacenamiento distribuido")
        except Exception as e:
            print(f"⚠️ Error conectando a MinIO: {e}")
            self.minio_client = None
            self.use_minio = False
        
        self._minio_initialized = True
    
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
        
        # Asegurar conexión a MinIO
        self._ensure_minio_connection()
        
        # 1. Subir YAML a MinIO si está disponible
        minio_metadata = None
        print(f"🔍 Debug MinIO: use_minio={self.use_minio}, minio_client={self.minio_client is not None}")
        
        if self.use_minio and self.minio_client:
            try:
                print(f"📤 Subiendo YAML a MinIO para proyecto: {project_name}")
                minio_metadata = self.minio_client.upload_yaml_definition(
                    yaml_content, 
                    project_name, 
                    source_type='text'
                )
                print(f"✅ YAML subido a MinIO: {minio_metadata['public_url']}")
            except Exception as e:
                print(f"⚠️ Error subiendo a MinIO: {e}")
                import traceback
                traceback.print_exc()
        else:
            print(f"⚠️ MinIO no disponible: use_minio={self.use_minio}, client={self.minio_client is not None}")
        
        # 2. Crear estructura local (solo metadatos, no archivos grandes)
        project_dir = os.path.join(self.local_path, "projects", project_name)
        os.makedirs(project_dir, exist_ok=True)
        os.makedirs(os.path.join(project_dir, "docs"), exist_ok=True)
        
        # 3. Crear catalog-info.yaml con referencia a MinIO
        catalog_info = self._create_catalog_info(project_name, description, yaml_content, minio_metadata)
        
        # 4. Crear README.md ligero
        readme_content = self._create_readme(project_name, description, minio_metadata)
        
        # 5. Crear documentación mínima
        arch_doc = self._create_architecture_doc(project_name, description, minio_metadata)
        
        # Escribir solo archivos esenciales localmente
        with open(os.path.join(project_dir, "catalog-info.yaml"), "w") as f:
            f.write(catalog_info)
        
        with open(os.path.join(project_dir, "README.md"), "w") as f:
            f.write(readme_content)
        
        with open(os.path.join(project_dir, "docs", "architecture.md"), "w") as f:
            f.write(arch_doc)
        
        # 6. Subir documentación completa a MinIO si está disponible
        if self.use_minio and self.minio_client:
            try:
                docs_urls = self.minio_client.upload_documentation(
                    os.path.join(project_dir, "docs"), 
                    project_name
                )
                print(f"✅ Documentación subida a MinIO: {len(docs_urls)} archivos")
            except Exception as e:
                print(f"⚠️ Error subiendo documentación: {e}")
        
        return {
            'project_dir': project_dir,
            'minio_metadata': minio_metadata,
            'local_files': ['catalog-info.yaml', 'README.md', 'docs/architecture.md']
        }
            
        with open(os.path.join(project_dir, "docs", "architecture.md"), "w") as f:
            f.write(arch_doc)
        
        return project_dir
    
    def _create_catalog_info(self, project_name: str, description: str, yaml_content: str, minio_metadata: Optional[dict]) -> str:
        """Crear catalog-info.yaml con referencias a MinIO"""
        annotations = {
            'backstage.io/managed-by-location': f'url:https://github.com/giovanemere/demo-infra-ai-agent-template-idp/tree/main/projects/{project_name}/',
            'aws.com/cost-center': 'ai-generated',
            'ai.platform/generated-at': datetime.now().isoformat()
        }
        
        # Añadir referencias a MinIO si está disponible
        if minio_metadata:
            annotations.update({
                'ai.platform/minio-yaml-url': minio_metadata['public_url'],
                'ai.platform/minio-bucket': minio_metadata['bucket'],
                'ai.platform/storage-type': 'minio'
            })
        
        annotations_yaml = '\n    '.join([f'{k}: "{v}"' for k, v in annotations.items()])
        
        return f"""apiVersion: backstage.io/v1alpha1
kind: System
metadata:
  name: {project_name}
  title: {project_name.replace('-', ' ').title()}
  description: {description[:200]}{'...' if len(description) > 200 else ''}
  annotations:
    {annotations_yaml}
spec:
  owner: platform-team
  domain: cloud-infrastructure
---
{yaml_content}
"""
    
    def _create_readme(self, project_name: str, description: str, minio_metadata: Optional[dict]) -> str:
        """Crear README.md con referencias a MinIO"""
        minio_section = ""
        if minio_metadata:
            minio_section = f"""
## 📁 Archivos en MinIO
- **YAML Completo**: [{minio_metadata['filename']}]({minio_metadata['public_url']})
- **Bucket**: {minio_metadata['bucket']}
- **Generado**: {minio_metadata['generated_at']}
"""
        
        return f"""# {project_name.replace('-', ' ').title()}

## 📋 Descripción
{description}

## 🏗️ Arquitectura AWS
Esta solución fue generada automáticamente por IA.
{minio_section}
## 📚 Documentación
- [Arquitectura Detallada](./docs/architecture.md)

## 🤖 Generado por
Infrastructure AI Platform - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

## 🚀 Despliegue en Backstage
Este proyecto se detecta automáticamente en Backstage a través del archivo `catalog-info.yaml`.
"""
    
    def _create_architecture_doc(self, project_name: str, description: str, minio_metadata: Optional[dict]) -> str:
        """Crear documentación de arquitectura"""
        storage_info = "Almacenamiento local" if not minio_metadata else f"Almacenamiento distribuido (MinIO): {minio_metadata['public_url']}"
        
        return f"""# 🏗️ Arquitectura - {project_name.replace('-', ' ').title()}

## 📝 Descripción Original
{description}

## 🔍 Análisis de IA
Procesado automáticamente por Infrastructure AI Platform usando Gemini AI.

## 📊 Flujo de Procesamiento
```
[Descripción] → [IA Gemini] → [YAML Backstage] → [MinIO Storage] → [Catálogo IDP]
```

## 💾 Almacenamiento
{storage_info}

## 📅 Información de Generación
- **Fecha**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
- **Procesador**: Gemini AI
- **Plataforma**: Infrastructure AI Platform
- **Storage**: {'MinIO' if minio_metadata else 'Local'}
"""

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
            # Crear estructura del proyecto (incluye MinIO)
            project_result = self.create_project_structure(project_name, yaml_content, description)
            
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
                commit_msg = f"Add project: {project_name} (Auto-generated by AI)"
                if project_result.get('minio_metadata'):
                    commit_msg += f" - Files in MinIO: {project_result['minio_metadata']['public_url']}"
                
                subprocess.run([
                    "git", "commit", "-m", commit_msg
                ], cwd=self.local_path, check=True)
                subprocess.run([
                    "git", "push", "origin", "main"
                ], cwd=self.local_path, check=True)
                
                print(f"✅ Proyecto subido a GitHub: {project_name}")
                if project_result.get('minio_metadata'):
                    print(f"✅ Archivos en MinIO: {project_result['minio_metadata']['public_url']}")
            
            return f"https://github.com/giovanemere/demo-infra-ai-agent-template-idp/tree/main/projects/{project_name}/"
            
        except Exception as e:
            print(f"Error saving project: {e}")
            # Aún así devolver la URL de GitHub esperada
            return f"https://github.com/giovanemere/demo-infra-ai-agent-template-idp/tree/main/projects/{project_name}/"
    
    def save_template(self, template_name: str, template_files: dict) -> str:
        """Guardar template completo en el repositorio de templates"""
        try:
            # Crear directorio del template
            template_dir = os.path.join(self.local_path, "templates", template_name)
            os.makedirs(template_dir, exist_ok=True)
            os.makedirs(os.path.join(template_dir, "content"), exist_ok=True)
            
            # Escribir todos los archivos del template
            for file_path, content in template_files.items():
                full_path = os.path.join(template_dir, file_path)
                
                # Crear directorios si no existen
                os.makedirs(os.path.dirname(full_path), exist_ok=True)
                
                with open(full_path, "w", encoding="utf-8") as f:
                    f.write(content)
            
            # Commit y push
            self._commit_and_push(f"Add template: {template_name}")
            
            # Retornar URL del template
            return f"https://github.com/giovanemere/demo-infra-ai-agent-template-idp/tree/main/templates/{template_name}"
            
        except Exception as e:
            print(f"Error guardando template: {e}")
            raise e

    def _commit_and_push(self, commit_message: str):
        """Hacer commit y push de los cambios"""
        try:
            # Configurar git user
            subprocess.run([
                "git", "config", "user.email", "ai-agent@platform.local"
            ], cwd=self.local_path, check=True)
            subprocess.run([
                "git", "config", "user.name", "Infrastructure AI Agent"
            ], cwd=self.local_path, check=True)
            
            # Git add, commit, push
            subprocess.run(["git", "add", "."], cwd=self.local_path, check=True)
            
            # Verificar si hay cambios para commitear
            result = subprocess.run([
                "git", "diff", "--cached", "--quiet"
            ], cwd=self.local_path, capture_output=True)
            
            if result.returncode != 0:  # Hay cambios
                subprocess.run([
                    "git", "commit", "-m", commit_message
                ], cwd=self.local_path, check=True)
                subprocess.run([
                    "git", "push", "origin", "main"
                ], cwd=self.local_path, check=True)
                print(f"✅ Cambios subidos a GitHub: {commit_message}")
            else:
                print("ℹ️ No hay cambios para subir")
                
        except subprocess.CalledProcessError as e:
            print(f"Error en commit/push: {e}")
            raise e

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
