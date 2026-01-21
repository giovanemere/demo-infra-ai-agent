"""
Template Generator - Genera templates de Backstage desde análisis de IA
"""
import yaml
import json
import os
from typing import Dict, List, Any
from datetime import datetime
from generators.scaffolder_generator import ScaffolderGenerator

class TemplateGenerator:
    """Generador principal de templates para Backstage"""
    
    def __init__(self):
        self.scaffolder_generator = ScaffolderGenerator()
    
    def generate_from_analysis(self, analysis: Dict[str, Any], template_id: str, project_name: str) -> Dict[str, Any]:
        """Genera template completo desde análisis de IA"""
        
        # Generar template de Scaffolder
        scaffolder_template = self.scaffolder_generator.generate_scaffolder_template(
            analysis, template_id, project_name
        )
        
        # Generar archivos de contenido
        content_files = self.scaffolder_generator.generate_content_files(
            analysis, template_id, project_name
        )
        
        # Estructura completa del template
        template_structure = {
            "template_id": template_id,
            "project_name": project_name,
            "scaffolder_template": scaffolder_template,
            "content_files": content_files,
            "metadata": {
                "generated_at": datetime.now().isoformat(),
                "analysis_type": analysis.get("type", "unknown"),
                "services_detected": analysis.get("services", []),
                "architecture_type": analysis.get("architecture_type", "web-app")
            }
        }
        
        return template_structure
    
    def generate_template_files(self, template_data: Dict[str, Any], output_dir: str) -> Dict[str, str]:
        """Genera archivos físicos del template"""
        
        template_id = template_data["template_id"]
        scaffolder_template = template_data["scaffolder_template"]
        content_files = template_data["content_files"]
        
        # Crear estructura de directorios
        template_dir = os.path.join(output_dir, template_id)
        content_dir = os.path.join(template_dir, "content")
        
        os.makedirs(template_dir, exist_ok=True)
        os.makedirs(content_dir, exist_ok=True)
        
        generated_files = {}
        
        # Generar template.yaml principal
        template_yaml_path = os.path.join(template_dir, "template.yaml")
        with open(template_yaml_path, 'w', encoding='utf-8') as f:
            yaml.dump(scaffolder_template, f, default_flow_style=False, allow_unicode=True)
        generated_files["template.yaml"] = template_yaml_path
        
        # Generar archivos de contenido
        for filename, content in content_files.items():
            file_path = os.path.join(content_dir, filename)
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            generated_files[f"content/{filename}"] = file_path
        
        return generated_files
    
    def generate_aws_template(self, template_data: Dict[str, Any]) -> Dict[str, str]:
        """Genera template AWS (método legacy para compatibilidad)"""
        
        # Extraer datos del template_data
        template_name = template_data.get("template_name", "aws-template")
        services = template_data.get("services", [])
        
        # Crear análisis simulado
        analysis = {
            "services": services,
            "architecture_type": template_data.get("architecture_type", "web-app"),
            "type": "aws"
        }
        
        # Generar usando nuevo método
        template_structure = self.generate_from_analysis(analysis, template_name, template_name)
        
        # Convertir a formato con estructura correcta
        return {
            "template.yaml": yaml.dump(template_structure["scaffolder_template"], default_flow_style=False),
            "content/catalog-info.yaml": template_structure["content_files"].get("catalog-info.yaml", ""),
            "content/README.md": template_structure["content_files"].get("README.md", ""),
        }
