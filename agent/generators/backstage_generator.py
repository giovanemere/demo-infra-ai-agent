"""
Generador de definiciones Backstage estándar para Infrastructure AI Platform
"""
import yaml
from typing import Dict, List, Any, Optional
from datetime import datetime
import hashlib

class BackstageGenerator:
    """Genera definiciones Backstage válidas desde descripciones de IA"""
    
    def __init__(self):
        self.aws_service_mappings = {
            # APIs
            'api gateway': {'kind': 'API', 'type': 'rest-api', 'category': 'api'},
            'apigw': {'kind': 'API', 'type': 'rest-api', 'category': 'api'},
            
            # Compute Services
            'lambda': {'kind': 'Component', 'type': 'service', 'category': 'compute'},
            'ec2': {'kind': 'Component', 'type': 'service', 'category': 'compute'},
            'ecs': {'kind': 'Component', 'type': 'service', 'category': 'compute'},
            'fargate': {'kind': 'Component', 'type': 'service', 'category': 'compute'},
            
            # Databases
            'dynamodb': {'kind': 'Resource', 'type': 'database', 'category': 'storage'},
            'rds': {'kind': 'Resource', 'type': 'database', 'category': 'storage'},
            'aurora': {'kind': 'Resource', 'type': 'database', 'category': 'storage'},
            'mysql': {'kind': 'Resource', 'type': 'database', 'category': 'storage'},
            'postgres': {'kind': 'Resource', 'type': 'database', 'category': 'storage'},
            
            # Storage
            's3': {'kind': 'Resource', 'type': 'storage', 'category': 'storage'},
            'efs': {'kind': 'Resource', 'type': 'storage', 'category': 'storage'},
            
            # Networking
            'cloudfront': {'kind': 'Component', 'type': 'cdn', 'category': 'network'},
            'elb': {'kind': 'Component', 'type': 'load-balancer', 'category': 'network'},
            'alb': {'kind': 'Component', 'type': 'load-balancer', 'category': 'network'},
            'nlb': {'kind': 'Component', 'type': 'load-balancer', 'category': 'network'},
            'route53': {'kind': 'Resource', 'type': 'dns', 'category': 'network'},
            'vpc': {'kind': 'Resource', 'type': 'network', 'category': 'network'},
            
            # Messaging
            'sqs': {'kind': 'Resource', 'type': 'queue', 'category': 'messaging'},
            'sns': {'kind': 'Resource', 'type': 'topic', 'category': 'messaging'},
            'eventbridge': {'kind': 'Resource', 'type': 'event-bus', 'category': 'messaging'},
            
            # Monitoring
            'cloudwatch': {'kind': 'Resource', 'type': 'monitoring', 'category': 'observability'},
            'x-ray': {'kind': 'Resource', 'type': 'tracing', 'category': 'observability'},
        }
    
    def generate_from_description(self, description: str, source_type: str = 'text') -> Dict[str, Any]:
        """
        Genera definiciones Backstage completas desde descripción
        
        Args:
            description: Descripción de la arquitectura
            source_type: 'text' o 'image'
        
        Returns:
            Dict con system, components, resources, apis
        """
        # Detectar servicios AWS
        detected_services = self._detect_aws_services(description)
        
        # Generar nombre del sistema
        system_name = self._generate_system_name(description)
        
        # Crear definiciones
        result = {
            'system': self._create_system(system_name, description, source_type),
            'components': [],
            'resources': [],
            'apis': []
        }
        
        # Generar entidades por servicio detectado
        for service_name, service_info in detected_services.items():
            entity = self._create_entity(service_name, service_info, system_name, description, source_type)
            
            if entity['kind'] == 'Component':
                result['components'].append(entity)
            elif entity['kind'] == 'Resource':
                result['resources'].append(entity)
            elif entity['kind'] == 'API':
                result['apis'].append(entity)
        
        # Establecer dependencias
        self._establish_dependencies(result)
        
        return result
    
    def _detect_aws_services(self, description: str) -> Dict[str, Dict]:
        """Detecta servicios AWS en la descripción"""
        desc_lower = description.lower()
        detected = {}
        
        for service_key, mapping in self.aws_service_mappings.items():
            if service_key in desc_lower:
                # Generar nombre único para el servicio
                service_id = f"{service_key.replace(' ', '-')}-{abs(hash(description)) % 1000}"
                detected[service_id] = {
                    'service_type': service_key,
                    'mapping': mapping,
                    'description_context': self._extract_context(description, service_key)
                }
        
        return detected
    
    def _generate_system_name(self, description: str) -> str:
        """Genera nombre del sistema basado en la descripción"""
        # Extraer palabras clave
        keywords = []
        desc_lower = description.lower()
        
        # Buscar patrones comunes
        if 'api' in desc_lower:
            keywords.append('api')
        if 'web' in desc_lower or 'website' in desc_lower:
            keywords.append('web')
        if 'mobile' in desc_lower or 'app' in desc_lower:
            keywords.append('app')
        if 'data' in desc_lower or 'analytics' in desc_lower:
            keywords.append('data')
        if 'ml' in desc_lower or 'machine learning' in desc_lower or 'ai' in desc_lower:
            keywords.append('ml')
        
        # Generar nombre
        if keywords:
            base_name = '-'.join(keywords[:2])  # Máximo 2 keywords
        else:
            base_name = 'infrastructure'
        
        # Añadir hash para unicidad
        hash_suffix = abs(hash(description)) % 1000
        return f"{base_name}-system-{hash_suffix}"
    
    def _create_system(self, system_name: str, description: str, source_type: str) -> Dict[str, Any]:
        """Crea definición del sistema principal"""
        return {
            'apiVersion': 'backstage.io/v1alpha1',
            'kind': 'System',
            'metadata': {
                'name': system_name,
                'title': system_name.replace('-', ' ').title(),
                'description': description[:200] + ('...' if len(description) > 200 else ''),
                'tags': self._generate_tags(description),
                'annotations': {
                    'ai.platform/source-type': source_type,
                    'ai.platform/generated-at': datetime.now().isoformat(),
                    'ai.platform/source-description': description[:500],
                    'ai.platform/complexity-level': self._assess_complexity(description),
                    'aws.com/cost-center': 'ai-generated',
                    'backstage.io/managed-by-location': f'url:https://github.com/giovanemere/demo-infra-ai-agent-template-idp/tree/main/systems/{system_name}/'
                }
            },
            'spec': {
                'owner': 'platform-team',
                'domain': 'cloud-infrastructure'
            }
        }
    
    def _create_entity(self, service_id: str, service_info: Dict, system_name: str, description: str, source_type: str) -> Dict[str, Any]:
        """Crea entidad individual (Component, Resource, API)"""
        mapping = service_info['mapping']
        service_type = service_info['service_type']
        context = service_info['description_context']
        
        entity = {
            'apiVersion': 'backstage.io/v1alpha1',
            'kind': mapping['kind'],
            'metadata': {
                'name': service_id,
                'title': f"{service_type.title()} - {service_id}",
                'description': f"{service_type.upper()} service: {context}",
                'tags': [
                    'aws',
                    service_type.replace(' ', '-'),
                    mapping['category'],
                    'ai-generated'
                ],
                'annotations': {
                    'ai.platform/source-type': source_type,
                    'ai.platform/generated-at': datetime.now().isoformat(),
                    'ai.platform/aws-service': service_type,
                    'ai.platform/service-category': mapping['category'],
                    'aws.com/service-type': service_type.replace(' ', '-'),
                    'aws.com/cost-center': 'ai-generated'
                }
            },
            'spec': {
                'type': mapping['type'],
                'lifecycle': 'experimental',
                'owner': 'platform-team',
                'system': system_name
            }
        }
        
        return entity
    
    def _establish_dependencies(self, result: Dict[str, Any]):
        """Establece dependencias lógicas entre entidades"""
        components = result['components']
        resources = result['resources']
        apis = result['apis']
        
        # Lógica de dependencias comunes
        for component in components:
            service_type = component['metadata']['annotations'].get('ai.platform/aws-service', '')
            
            # Lambda típicamente depende de bases de datos
            if 'lambda' in service_type:
                db_resources = [r for r in resources if 'database' in r['spec']['type']]
                if db_resources:
                    component['spec']['dependsOn'] = [f"resource:default/{r['metadata']['name']}" for r in db_resources[:2]]
                
                # Lambda típicamente provee APIs
                if apis:
                    component['spec']['providesApis'] = [apis[0]['metadata']['name']]
            
            # Load balancers dependen de servicios
            elif 'load-balancer' in component['spec']['type']:
                service_components = [c for c in components if c['spec']['type'] == 'service' and c != component]
                if service_components:
                    component['spec']['dependsOn'] = [f"component:default/{c['metadata']['name']}" for c in service_components[:2]]
    
    def _extract_context(self, description: str, service_key: str) -> str:
        """Extrae contexto específico del servicio de la descripción"""
        sentences = description.split('.')
        for sentence in sentences:
            if service_key.lower() in sentence.lower():
                return sentence.strip()[:100]
        return f"AWS {service_key} service"
    
    def _generate_tags(self, description: str) -> List[str]:
        """Genera tags relevantes basados en la descripción"""
        tags = ['aws', 'ai-generated']
        desc_lower = description.lower()
        
        # Tags por dominio
        if any(word in desc_lower for word in ['api', 'rest', 'graphql']):
            tags.append('api')
        if any(word in desc_lower for word in ['web', 'frontend', 'ui']):
            tags.append('frontend')
        if any(word in desc_lower for word in ['backend', 'server', 'service']):
            tags.append('backend')
        if any(word in desc_lower for word in ['data', 'analytics', 'etl']):
            tags.append('data')
        if any(word in desc_lower for word in ['ml', 'ai', 'machine learning']):
            tags.append('ml')
        if any(word in desc_lower for word in ['mobile', 'app', 'ios', 'android']):
            tags.append('mobile')
        
        return tags
    
    def _assess_complexity(self, description: str) -> str:
        """Evalúa la complejidad de la arquitectura"""
        desc_lower = description.lower()
        service_count = sum(1 for service in self.aws_service_mappings.keys() if service in desc_lower)
        
        if service_count <= 2:
            return 'simple'
        elif service_count <= 5:
            return 'medium'
        else:
            return 'complex'
    
    def to_yaml(self, definitions: Dict[str, Any]) -> str:
        """Convierte las definiciones a YAML válido para Backstage"""
        yaml_parts = []
        
        # Sistema principal
        yaml_parts.append(yaml.dump(definitions['system'], default_flow_style=False, sort_keys=False))
        
        # Componentes
        for component in definitions['components']:
            yaml_parts.append(yaml.dump(component, default_flow_style=False, sort_keys=False))
        
        # Recursos
        for resource in definitions['resources']:
            yaml_parts.append(yaml.dump(resource, default_flow_style=False, sort_keys=False))
        
        # APIs
        for api in definitions['apis']:
            yaml_parts.append(yaml.dump(api, default_flow_style=False, sort_keys=False))
        
        return '\n---\n'.join(yaml_parts)
