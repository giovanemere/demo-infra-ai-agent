"""
Scaffolder Generator - Genera templates específicos para Backstage Scaffolder
"""
import yaml
import json
from typing import Dict, List, Any
from datetime import datetime

class ScaffolderGenerator:
    """Generador de templates para Backstage Scaffolder"""
    
    def __init__(self):
        self.aws_services_mapping = {
            "s3": {"type": "storage", "category": "object-storage"},
            "lambda": {"type": "compute", "category": "serverless"},
            "cloudfront": {"type": "cdn", "category": "content-delivery"},
            "rds": {"type": "database", "category": "relational"},
            "dynamodb": {"type": "database", "category": "nosql"},
            "api_gateway": {"type": "api", "category": "gateway"},
            "ec2": {"type": "compute", "category": "virtual-machine"},
            "ecs": {"type": "container", "category": "orchestration"},
            "eks": {"type": "container", "category": "kubernetes"},
            "sqs": {"type": "messaging", "category": "queue"},
            "sns": {"type": "messaging", "category": "notification"}
        }
    
    def generate_scaffolder_template(self, analysis: Dict[str, Any], template_id: str, project_name: str) -> Dict[str, Any]:
        """Genera un template completo para Backstage Scaffolder"""
        
        services = analysis.get("services", [])
        architecture_type = analysis.get("architecture_type", "web-app")
        
        # Generar metadata del template
        template_metadata = self._generate_template_metadata(template_id, project_name, services, architecture_type)
        
        # Generar parámetros del template
        parameters = self._generate_template_parameters(services, architecture_type)
        
        # Generar steps del scaffolder
        steps = self._generate_scaffolder_steps(services, architecture_type)
        
        # Generar outputs
        outputs = self._generate_template_outputs()
        
        # Construir template completo
        template = {
            "apiVersion": "scaffolder.backstage.io/v1beta3",
            "kind": "Template",
            "metadata": template_metadata,
            "spec": {
                "owner": "group:default/developers",
                "type": "service",
                "parameters": parameters,
                "steps": steps,
                "output": outputs
            }
        }
        
        return template
    
    def _generate_template_metadata(self, template_id: str, project_name: str, services: List[str], architecture_type: str) -> Dict[str, Any]:
        """Genera metadata del template"""
        
        # Generar tags basados en servicios detectados
        tags = ["recommended", "aws", architecture_type]
        for service in services:
            if service.lower() in self.aws_services_mapping:
                service_info = self.aws_services_mapping[service.lower()]
                tags.extend([service.lower(), service_info["category"]])
        
        # Remover duplicados
        tags = list(set(tags))
        
        return {
            "name": template_id,
            "title": f"AWS {project_name.replace('-', ' ').title()}",
            "description": f"Aplicación AWS {architecture_type} con {', '.join(services[:3])}{'...' if len(services) > 3 else ''}",
            "tags": tags,
            "annotations": {
                "backstage.io/managed-by-location": f"url:https://github.com/giovanemere/demo-infra-ai-agent-template-idp/blob/main/templates/{template_id}/template.yaml",
                "github.com/project-slug": f"giovanemere/demo-infra-ai-agent-template-idp"
            }
        }
    
    def _generate_template_parameters(self, services: List[str], architecture_type: str) -> List[Dict[str, Any]]:
        """Genera parámetros del template"""
        
        parameters = [
            {
                "title": "Configuración del Proyecto",
                "required": ["name", "description"],
                "properties": {
                    "name": {
                        "title": "Nombre del Proyecto",
                        "type": "string",
                        "description": "Nombre único para el proyecto",
                        "pattern": "^[a-zA-Z0-9-]+$",
                        "maxLength": 50
                    },
                    "description": {
                        "title": "Descripción",
                        "type": "string",
                        "description": "Descripción breve del proyecto",
                        "maxLength": 200
                    }
                }
            },
            {
                "title": "Configuración AWS",
                "required": ["aws_region", "environment"],
                "properties": {
                    "aws_region": {
                        "title": "Región AWS",
                        "type": "string",
                        "description": "Región donde desplegar la infraestructura",
                        "default": "us-east-1",
                        "enum": [
                            "us-east-1",
                            "us-west-2", 
                            "eu-west-1",
                            "ap-southeast-1"
                        ]
                    },
                    "environment": {
                        "title": "Ambiente",
                        "type": "string",
                        "description": "Ambiente de despliegue",
                        "default": "dev",
                        "enum": ["dev", "staging", "prod"]
                    }
                }
            }
        ]
        
        # Agregar parámetros específicos por servicio
        service_params = self._generate_service_parameters(services)
        if service_params:
            parameters.append(service_params)
        
        return parameters
    
    def _generate_service_parameters(self, services: List[str]) -> Dict[str, Any]:
        """Genera parámetros específicos por servicio"""
        
        properties = {}
        
        for service in services:
            service_lower = service.lower()
            
            if service_lower == "rds":
                properties.update({
                    "db_instance_class": {
                        "title": "Clase de Instancia RDS",
                        "type": "string",
                        "default": "db.t3.micro",
                        "enum": ["db.t3.micro", "db.t3.small", "db.t3.medium"]
                    },
                    "db_engine": {
                        "title": "Motor de Base de Datos",
                        "type": "string",
                        "default": "mysql",
                        "enum": ["mysql", "postgres", "mariadb"]
                    }
                })
            
            elif service_lower == "lambda":
                properties.update({
                    "lambda_runtime": {
                        "title": "Runtime de Lambda",
                        "type": "string",
                        "default": "python3.9",
                        "enum": ["python3.9", "python3.11", "nodejs18.x", "nodejs20.x"]
                    }
                })
            
            elif service_lower == "s3":
                properties.update({
                    "s3_versioning": {
                        "title": "Habilitar Versionado S3",
                        "type": "boolean",
                        "default": True
                    }
                })
        
        if properties:
            return {
                "title": "Configuración de Servicios",
                "properties": properties
            }
        
        return None
    
    def _generate_scaffolder_steps(self, services: List[str], architecture_type: str) -> List[Dict[str, Any]]:
        """Genera steps del scaffolder"""
        
        steps = [
            {
                "id": "fetch",
                "name": "Fetch Template",
                "action": "fetch:template",
                "input": {
                    "url": "./content",
                    "values": {
                        "name": "${{ parameters.name }}",
                        "description": "${{ parameters.description }}",
                        "aws_region": "${{ parameters.aws_region }}",
                        "environment": "${{ parameters.environment }}"
                    }
                }
            },
            {
                "id": "publish",
                "name": "Publish to GitHub",
                "action": "publish:github",
                "input": {
                    "allowedHosts": ["github.com"],
                    "description": "AWS Infrastructure: ${{ parameters.description }}",
                    "repoUrl": "github.com?owner=giovanemere&repo=${{ parameters.name }}",
                    "defaultBranch": "main"
                }
            },
            {
                "id": "register",
                "name": "Register in Catalog",
                "action": "catalog:register",
                "input": {
                    "repoContentsUrl": "${{ steps.publish.output.repoContentsUrl }}",
                    "catalogInfoPath": "/catalog-info.yaml"
                }
            }
        ]
        
        return steps
    
    def _generate_template_outputs(self) -> Dict[str, Any]:
        """Genera outputs del template"""
        
        return {
            "links": [
                {
                    "title": "Repository",
                    "url": "${{ steps.publish.output.remoteUrl }}"
                },
                {
                    "title": "Open in Catalog",
                    "icon": "catalog",
                    "entityRef": "${{ steps.register.output.entityRef }}"
                },
                {
                    "title": "AWS Console",
                    "url": "https://console.aws.amazon.com/",
                    "icon": "cloud"
                }
            ]
        }
    
    def generate_content_files(self, analysis: Dict[str, Any], template_id: str, project_name: str) -> Dict[str, str]:
        """Genera archivos de contenido para el template"""
        
        services = analysis.get("services", [])
        architecture_type = analysis.get("architecture_type", "web-app")
        
        files = {}
        
        # Generar catalog-info.yaml
        files["catalog-info.yaml"] = self._generate_catalog_info(project_name, services, architecture_type)
        
        # Generar README.md
        files["README.md"] = self._generate_readme(project_name, services, architecture_type)
        
        # Generar archivos específicos por tipo de arquitectura
        if architecture_type == "serverless":
            files["serverless.yml"] = self._generate_serverless_config(services)
        elif "terraform" in analysis.get("tools", []):
            files["main.tf"] = self._generate_terraform_config(services)
        
        return files
    
    def _generate_catalog_info(self, project_name: str, services: List[str], architecture_type: str) -> str:
        """Genera catalog-info.yaml para el proyecto"""
        
        catalog_info = {
            "apiVersion": "backstage.io/v1alpha1",
            "kind": "Component",
            "metadata": {
                "name": "${{ values.name }}",
                "title": "${{ values.name | title }}",
                "description": "${{ values.description }}",
                "tags": ["aws", architecture_type] + [s.lower() for s in services[:5]],
                "annotations": {
                    "github.com/project-slug": "giovanemere/${{ values.name }}",
                    "aws.com/region": "${{ values.aws_region }}",
                    "aws.com/environment": "${{ values.environment }}"
                }
            },
            "spec": {
                "type": "service",
                "lifecycle": "experimental",
                "owner": "group:default/developers",
                "system": "infrastructure-ai-platform"
            }
        }
        
        return yaml.dump(catalog_info, default_flow_style=False)
    
    def _generate_readme(self, project_name: str, services: List[str], architecture_type: str) -> str:
        """Genera README.md para el proyecto"""
        
        services_list = "\n".join([f"- **{service}**: {self._get_service_description(service)}" for service in services])
        
        readme = f"""# ${{{{ values.name | title }}}}

${{{{ values.description }}}}

## 🏗️ Arquitectura AWS

### Servicios Utilizados
{services_list}

### Configuración
- **Región AWS**: `${{{{ values.aws_region }}}}`
- **Ambiente**: `${{{{ values.environment }}}}`

## 🚀 Despliegue

### Prerrequisitos
1. AWS CLI configurado
2. Credenciales AWS válidas
3. Terraform instalado (opcional)

### Pasos de Despliegue
1. Clonar el repositorio
2. Configurar variables de entorno AWS
3. Ejecutar scripts de despliegue
4. Verificar recursos en AWS Console

### Variables de Entorno
```bash
export AWS_REGION=${{{{ values.aws_region }}}}
export ENVIRONMENT=${{{{ values.environment }}}}
export PROJECT_NAME=${{{{ values.name }}}}
```

## 📊 Monitoreo

### CloudWatch Dashboards
- Métricas de aplicación
- Logs centralizados
- Alertas configuradas

## 🔧 Desarrollo Local

### Instalación
```bash
npm install
# o
yarn install
```

### Desarrollo
```bash
npm run dev
# o
yarn dev
```

---
*Generado por Infrastructure AI Platform*
"""
        
        return readme
    
    def _get_service_description(self, service: str) -> str:
        """Obtiene descripción del servicio AWS"""
        
        descriptions = {
            "S3": "Almacenamiento de objetos escalable",
            "Lambda": "Computación serverless",
            "CloudFront": "Red de distribución de contenido (CDN)",
            "RDS": "Base de datos relacional administrada",
            "DynamoDB": "Base de datos NoSQL",
            "API Gateway": "Gestión de APIs REST",
            "EC2": "Instancias virtuales",
            "ECS": "Orquestación de contenedores",
            "EKS": "Kubernetes administrado",
            "SQS": "Cola de mensajes",
            "SNS": "Servicio de notificaciones"
        }
        
        return descriptions.get(service, f"Servicio AWS {service}")
    
    def _generate_serverless_config(self, services: List[str]) -> str:
        """Genera configuración serverless.yml"""
        
        config = {
            "service": "${{ values.name }}",
            "frameworkVersion": "3",
            "provider": {
                "name": "aws",
                "runtime": "python3.9",
                "region": "${{ values.aws_region }}",
                "stage": "${{ values.environment }}"
            },
            "functions": {
                "api": {
                    "handler": "handler.main",
                    "events": [
                        {
                            "http": {
                                "path": "/{proxy+}",
                                "method": "ANY"
                            }
                        }
                    ]
                }
            }
        }
        
        return yaml.dump(config, default_flow_style=False)
    
    def _generate_terraform_config(self, services: List[str]) -> str:
        """Genera configuración básica de Terraform"""
        
        terraform_config = f"""# Terraform configuration for ${{{{ values.name }}}}

terraform {{
  required_version = ">= 1.0"
  required_providers {{
    aws = {{
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }}
  }}
}}

provider "aws" {{
  region = var.aws_region
}}

variable "aws_region" {{
  description = "AWS region"
  type        = string
  default     = "${{{{ values.aws_region }}}}"
}}

variable "environment" {{
  description = "Environment name"
  type        = string
  default     = "${{{{ values.environment }}}}"
}}

variable "project_name" {{
  description = "Project name"
  type        = string
  default     = "${{{{ values.name }}}}"
}}

# Resources will be added based on detected services
"""
        
        return terraform_config
