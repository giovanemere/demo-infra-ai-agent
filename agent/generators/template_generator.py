import yaml
import json
from typing import List, Dict, Any

class TemplateGenerator:
    """Generador de templates de Backstage"""
    
    def generate_template(self, name: str, title: str, description: str, 
                         technology: str, component_type: str, tags: List[str], 
                         owner: str, parameters: List[Dict[str, Any]]) -> Dict[str, str]:
        """
        Genera todos los archivos necesarios para un template de Backstage (método legacy)
        """
        
        # Generar template.yaml principal
        template_yaml = self._generate_template_yaml(
            name, title, description, technology, component_type, tags, owner, parameters
        )
        
        # Generar catalog-info.yaml template
        catalog_template = self._generate_catalog_template(component_type, technology)
        
        # Generar README.md template
        readme_template = self._generate_readme_template(title, description, technology)
        
        # Generar schema.json para validación
        schema_json = self._generate_schema(parameters)
        
        return {
            "template.yaml": template_yaml,
            "content/catalog-info.yaml": catalog_template,
            "content/README.md": readme_template,
            "schema.json": schema_json
        }
        """
        Genera template específico para soluciones AWS
        
        Args:
            template_data: Datos del template incluyendo servicios AWS
            
        Returns:
            Dict con archivos del template
        """
        
        # Generar template.yaml específico para AWS
        template_yaml = self._generate_aws_template_yaml(template_data)
        
        # Generar catalog-info.yaml con servicios AWS
        catalog_template = self._generate_aws_catalog_template(template_data)
        
        # Generar README.md con documentación AWS
        readme_template = self._generate_aws_readme_template(template_data)
        
        # Generar documentación de arquitectura
        architecture_doc = self._generate_aws_architecture_doc(template_data)
        
        # Generar schema.json
        schema_json = self._generate_schema(template_data.get('parameters', []))
        
        return {
            "template.yaml": template_yaml,
            "content/catalog-info.yaml": catalog_template,
            "content/README.md": readme_template,
            "content/docs/architecture.md": architecture_doc,
            "schema.json": schema_json
        }
    
    def _generate_aws_template_yaml(self, template_data: dict) -> str:
        """Genera template.yaml específico para AWS"""
        
        aws_services = template_data.get('aws_services', [])
        parameters = template_data.get('parameters', [])
        
        # Agregar parámetros específicos de AWS
        aws_parameters = [
            {"name": "aws_region", "title": "AWS Region", "type": "string"},
            {"name": "environment", "title": "Environment", "type": "string"},
            {"name": "project_name", "title": "Project Name", "type": "string"}
        ]
        
        # Combinar parámetros
        all_parameters = aws_parameters + parameters
        
        template_config = {
            "apiVersion": "scaffolder.backstage.io/v1beta3",
            "kind": "Template",
            "metadata": {
                "name": template_data['template_name'],
                "title": template_data['template_title'],
                "description": template_data['template_description'],
                "tags": ["aws", "infrastructure"] + template_data.get('tags', [])
            },
            "spec": {
                "owner": template_data.get('owner', 'group:default/developers'),
                "type": template_data.get('component_type', 'service'),
                "parameters": [{
                    "title": "AWS Infrastructure Configuration",
                    "required": ["project_name", "aws_region", "environment"],
                    "properties": {param['name']: {
                        "title": param['title'],
                        "type": param['type'],
                        "description": f"Configure {param['title']} for AWS deployment"
                    } for param in all_parameters}
                }],
                "steps": [
                    {
                        "id": "template",
                        "name": "Fetch AWS Template",
                        "action": "fetch:template",
                        "input": {
                            "url": "./content",
                            "values": {param['name']: f"${{{{ parameters.{param['name']} }}}}" 
                                     for param in all_parameters}
                        }
                    },
                    {
                        "id": "publish",
                        "name": "Publish to GitHub",
                        "action": "publish:github",
                        "input": {
                            "allowedHosts": ["github.com"],
                            "description": f"AWS {template_data['solution_type']} - ${{{{ parameters.project_name }}}}",
                            "repoUrl": "github.com?owner=giovanemere&repo=${{ parameters.project_name }}"
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
                ],
                "output": {
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
            }
        }
        
        return yaml.dump(template_config, default_flow_style=False, sort_keys=False)
    
    def _generate_aws_catalog_template(self, template_data: dict) -> str:
        """Genera catalog-info.yaml específico para AWS"""
        
        aws_services = template_data.get('aws_services', [])
        
        catalog_config = {
            "apiVersion": "backstage.io/v1alpha1",
            "kind": "Component",
            "metadata": {
                "name": "${{ values.project_name }}",
                "title": "${{ values.project_name | title }}",
                "description": template_data['template_description'],
                "tags": ["aws"] + template_data.get('tags', []),
                "annotations": {
                    "github.com/project-slug": "giovanemere/${{ values.project_name }}",
                    "backstage.io/techdocs-ref": "dir:.",
                    "aws.com/region": "${{ values.aws_region }}",
                    "aws.com/environment": "${{ values.environment }}",
                    "aws.com/services": ", ".join(aws_services)
                }
            },
            "spec": {
                "type": template_data.get('component_type', 'service'),
                "lifecycle": "production",
                "owner": "${{ values.owner | default('group:default/developers') }}",
                "system": f"aws-{template_data['solution_type']}"
            }
        }
        
        return yaml.dump(catalog_config, default_flow_style=False, sort_keys=False)
    
    def _generate_aws_readme_template(self, template_data: dict) -> str:
        """Genera README.md específico para AWS"""
        
        aws_services = template_data.get('aws_services', [])
        
        services_list = "\n".join([f"- **{service}**: {self._get_service_description(service)}" 
                                  for service in aws_services])
        
        readme_content = f"""# ${{{{ values.project_name | title }}}}

## 📋 Descripción
{template_data['template_description']}

## 🏗️ Arquitectura AWS

### Servicios Utilizados
{services_list}

### Región AWS
**Región**: ${{{{ values.aws_region }}}}
**Ambiente**: ${{{{ values.environment }}}}

## 🚀 Despliegue

### Prerrequisitos
- AWS CLI configurado
- Credenciales AWS válidas
- Permisos para crear recursos: {', '.join(aws_services)}

### Pasos de Despliegue
1. Clonar el repositorio
2. Configurar variables de entorno
3. Ejecutar scripts de despliegue
4. Verificar recursos en AWS Console

## 📊 Monitoreo
- **CloudWatch**: Métricas y logs
- **AWS Console**: Estado de recursos
- **Backstage**: Documentación y estado

## 🔗 Enlaces Útiles
- [AWS Console](https://console.aws.amazon.com/)
- [Documentación AWS]({self._get_aws_docs_url(template_data['solution_type'])})
- [Backstage Catalog](http://localhost:3000/catalog/default/component/${{{{ values.project_name }}}})

---
*Generado automáticamente por Infrastructure AI Platform*
*Template: {template_data['template_name']}*
"""
        
        return readme_content
    
    def _generate_aws_architecture_doc(self, template_data: dict) -> str:
        """Genera documentación de arquitectura AWS"""
        
        aws_services = template_data.get('aws_services', [])
        
        architecture_content = f"""# 🏗️ Arquitectura AWS - {template_data['template_title']}

## 📝 Descripción de la Solución
{template_data['template_description']}

## 🔧 Servicios AWS

### Componentes Principales
"""
        
        for service in aws_services:
            architecture_content += f"""
#### {service}
- **Propósito**: {self._get_service_description(service)}
- **Configuración**: Según parámetros del template
- **Integración**: {self._get_service_integration(service)}
"""
        
        architecture_content += f"""

## 🌐 Flujo de Datos
```
Usuario → {' → '.join(aws_services[:3])} → Respuesta
```

## 📊 Consideraciones de Costos
- **Servicios principales**: {', '.join(aws_services)}
- **Modelo de facturación**: Pay-as-you-use
- **Optimización**: Configuración según ambiente

## 🔒 Seguridad
- IAM roles y políticas
- Encriptación en tránsito y reposo
- VPC y security groups (si aplica)

## 📈 Escalabilidad
- Auto Scaling configurado
- Load balancing (si aplica)
- Monitoreo con CloudWatch

## 🛠️ Mantenimiento
- Actualizaciones automáticas
- Backups programados
- Monitoreo continuo

---
*Arquitectura generada automáticamente*
*Fecha: {{"{{ 'now' | date('Y-m-d H:i:s') }}}}*
"""
        
        return architecture_content
    
    def _get_service_description(self, service: str) -> str:
        """Obtiene descripción del servicio AWS"""
        descriptions = {
            "S3": "Almacenamiento de objetos escalable",
            "Lambda": "Computación serverless",
            "CloudFront": "Red de distribución de contenido (CDN)",
            "RDS": "Base de datos relacional administrada",
            "EC2": "Instancias de computación virtual",
            "API Gateway": "Gestión de APIs REST y WebSocket",
            "DynamoDB": "Base de datos NoSQL administrada",
            "ELB": "Balanceador de carga",
            "VPC": "Red privada virtual",
            "IAM": "Gestión de identidades y accesos"
        }
        return descriptions.get(service, f"Servicio AWS {service}")
    
    def _get_service_integration(self, service: str) -> str:
        """Obtiene información de integración del servicio"""
        integrations = {
            "S3": "Integrado con CloudFront para CDN",
            "Lambda": "Triggered por eventos de otros servicios",
            "CloudFront": "Distribuye contenido desde S3",
            "RDS": "Conectado a aplicaciones via VPC",
            "EC2": "Ejecuta aplicaciones en la nube",
            "API Gateway": "Expone funciones Lambda como APIs"
        }
        return integrations.get(service, "Integrado con otros servicios AWS")
    
    def _get_aws_docs_url(self, solution_type: str) -> str:
        """Obtiene URL de documentación AWS según el tipo de solución"""
        urls = {
            "web-app": "https://docs.aws.amazon.com/getting-started/latest/awsgsg-intro/",
            "serverless": "https://docs.aws.amazon.com/lambda/",
            "data-pipeline": "https://docs.aws.amazon.com/data-pipeline/",
            "microservices": "https://docs.aws.amazon.com/microservices/"
        }
        return urls.get(solution_type, "https://docs.aws.amazon.com/")
        """
        Genera todos los archivos necesarios para un template de Backstage
        """
        
        # Generar template.yaml principal
        template_yaml = self._generate_template_yaml(
            name, title, description, technology, component_type, tags, owner, parameters
        )
        
        # Generar catalog-info.yaml template
        catalog_template = self._generate_catalog_template(component_type, technology)
        
        # Generar README.md template
        readme_template = self._generate_readme_template(title, description, technology)
        
        # Generar schema.json para validación
        schema_json = self._generate_schema(parameters)
        
        return {
            "template.yaml": template_yaml,
            "content/catalog-info.yaml": catalog_template,
            "content/README.md": readme_template,
            "schema.json": schema_json
        }
    
    def _generate_template_yaml(self, name: str, title: str, description: str,
                               technology: str, component_type: str, tags: List[str],
                               owner: str, parameters: List[Dict[str, Any]]) -> str:
        """Genera el archivo template.yaml principal"""
        
        # Construir parámetros del template
        template_parameters = {
            "title": "Project Information",
            "required": ["name", "description"],
            "properties": {
                "name": {
                    "title": "Name",
                    "type": "string",
                    "description": "Unique name for the project",
                    "pattern": "^[a-zA-Z0-9-]+$"
                },
                "description": {
                    "title": "Description",
                    "type": "string",
                    "description": "Description of the project"
                },
                "owner": {
                    "title": "Owner",
                    "type": "string",
                    "description": "Owner of the component",
                    "default": owner
                }
            }
        }
        
        # Agregar parámetros personalizados
        for param in parameters:
            if param['name']:
                template_parameters["properties"][param['name']] = {
                    "title": param['title'],
                    "type": param['type'],
                    "description": f"Custom parameter: {param['title']}"
                }
        
        template_config = {
            "apiVersion": "scaffolder.backstage.io/v1beta3",
            "kind": "Template",
            "metadata": {
                "name": name,
                "title": title,
                "description": description,
                "tags": ["recommended"] + tags + [technology]
            },
            "spec": {
                "owner": owner,
                "type": component_type,
                "parameters": [template_parameters],
                "steps": [
                    {
                        "id": "template",
                        "name": "Fetch Skeleton",
                        "action": "fetch:template",
                        "input": {
                            "url": "./content",
                            "values": self._generate_template_values(parameters)
                        }
                    },
                    {
                        "id": "publish",
                        "name": "Publish",
                        "action": "publish:github",
                        "input": {
                            "allowedHosts": ["github.com"],
                            "description": "This is ${{ parameters.name }}",
                            "repoUrl": "github.com?owner=giovanemere&repo=${{ parameters.name }}"
                        }
                    },
                    {
                        "id": "register",
                        "name": "Register",
                        "action": "catalog:register",
                        "input": {
                            "repoContentsUrl": "${{ steps.publish.output.repoContentsUrl }}",
                            "catalogInfoPath": "/catalog-info.yaml"
                        }
                    }
                ],
                "output": {
                    "links": [
                        {
                            "title": "Repository",
                            "url": "${{ steps.publish.output.remoteUrl }}"
                        },
                        {
                            "title": "Open in catalog",
                            "icon": "catalog",
                            "entityRef": "${{ steps.register.output.entityRef }}"
                        }
                    ]
                }
            }
        }
        
        return yaml.dump(template_config, default_flow_style=False, sort_keys=False)
    
    def _generate_template_values(self, parameters: List[Dict[str, Any]]) -> Dict[str, str]:
        """Genera los valores del template para usar en fetch:template"""
        values = {
            "name": "${{ parameters.name }}",
            "description": "${{ parameters.description }}",
            "owner": "${{ parameters.owner }}"
        }
        
        # Agregar parámetros personalizados
        for param in parameters:
            if param['name']:
                values[param['name']] = f"${{{{ parameters.{param['name']} }}}}"
        
        return values
    
    def _generate_catalog_template(self, component_type: str, technology: str) -> str:
        """Genera el template de catalog-info.yaml"""
        
        catalog_config = {
            "apiVersion": "backstage.io/v1alpha1",
            "kind": "Component",
            "metadata": {
                "name": "${{ values.name }}",
                "description": "${{ values.description }}",
                "tags": [technology, "generated-from-template"],
                "annotations": {
                    "github.com/project-slug": "giovanemere/${{ values.name }}",
                    "backstage.io/techdocs-ref": "dir:."
                }
            },
            "spec": {
                "type": component_type,
                "lifecycle": "production",
                "owner": "${{ values.owner }}",
                "system": f"{technology}-platform"
            }
        }
        
        return yaml.dump(catalog_config, default_flow_style=False, sort_keys=False)
    
    def _generate_readme_template(self, title: str, description: str, technology: str) -> str:
        """Genera el template de README.md"""
        
        readme_content = f"""# ${{{{ values.name }}}}

## Descripción
${{{{ values.description }}}}

## Tecnología Principal
{technology.upper()}

## Template Base
Este proyecto fue generado usando el template "{title}".

### Características
- {description}
- Integración automática con Backstage
- Documentación técnica incluida
- Configuración de CI/CD lista

## Estructura del Proyecto
```
${{{{ values.name }}}}/
├── catalog-info.yaml     # Configuración de Backstage
├── README.md            # Este archivo
└── docs/               # Documentación adicional
```

## Propietario
**Owner:** ${{{{ values.owner }}}}

## Enlaces
- [Backstage Catalog](http://localhost:3000/catalog/default/component/${{{{ values.name }}}})
- [Repository](https://github.com/giovanemere/${{{{ values.name }}}})

---
*Generado automáticamente por Infrastructure AI Platform*
"""
        
        return readme_content
    
    def _generate_schema(self, parameters: List[Dict[str, Any]]) -> str:
        """Genera el esquema JSON para validación"""
        
        schema = {
            "$schema": "http://json-schema.org/draft-07/schema#",
            "type": "object",
            "properties": {
                "name": {
                    "type": "string",
                    "pattern": "^[a-zA-Z0-9-]+$",
                    "minLength": 1,
                    "maxLength": 50
                },
                "description": {
                    "type": "string",
                    "minLength": 10,
                    "maxLength": 200
                },
                "owner": {
                    "type": "string",
                    "minLength": 1
                }
            },
            "required": ["name", "description", "owner"]
        }
        
        # Agregar parámetros personalizados al schema
        for param in parameters:
            if param['name']:
                schema["properties"][param['name']] = {
                    "type": param['type']
                }
                if param['type'] == 'string':
                    schema["properties"][param['name']]["minLength"] = 1
        
        return json.dumps(schema, indent=2)
