"""
Validador de YAML Backstage para Infrastructure AI Platform
"""
import yaml
import re
from typing import Dict, List, Any, Tuple, Optional

class BackstageValidator:
    """Valida que el YAML generado sea compatible con Backstage"""
    
    def __init__(self):
        self.valid_kinds = {
            'Component', 'API', 'Resource', 'System', 'Domain', 
            'Location', 'Template', 'User', 'Group'
        }
        
        self.valid_component_types = {
            'service', 'website', 'library', 'documentation', 
            'tool', 'dashboard', 'ml-model', 'data-pipeline',
            'mobile-feature', 'backend-service', 'frontend',
            'load-balancer', 'cdn'
        }
        
        self.valid_resource_types = {
            'database', 'storage', 'queue', 'topic', 'stream',
            'cluster', 'environment', 'monitoring', 'tracing',
            'dns', 'network', 'event-bus'
        }
        
        self.valid_api_types = {
            'rest-api', 'graphql', 'grpc', 'websocket', 'webhook'
        }
        
        self.valid_lifecycles = {
            'experimental', 'production', 'deprecated'
        }
        
        self.required_fields = {
            'Component': ['metadata.name', 'spec.type', 'spec.owner'],
            'API': ['metadata.name', 'spec.type', 'spec.owner'],
            'Resource': ['metadata.name', 'spec.type', 'spec.owner'],
            'System': ['metadata.name', 'spec.owner'],
            'Domain': ['metadata.name', 'spec.owner']
        }
    
    def validate_yaml(self, yaml_content: str) -> Tuple[bool, List[str], Dict[str, Any]]:
        """
        Valida YAML de Backstage
        
        Returns:
            (is_valid, errors, parsed_entities)
        """
        errors = []
        entities = []
        
        try:
            # Parsear YAML (puede contener múltiples documentos)
            documents = list(yaml.safe_load_all(yaml_content))
            
            if not documents:
                return False, ["YAML vacío o inválido"], {}
            
            for i, doc in enumerate(documents):
                if doc is None:
                    continue
                    
                entity_errors = self._validate_entity(doc, i)
                errors.extend(entity_errors)
                entities.append(doc)
            
            if not entities:
                errors.append("No se encontraron entidades válidas")
            
            is_valid = len(errors) == 0
            
            return is_valid, errors, {'entities': entities, 'count': len(entities)}
            
        except yaml.YAMLError as e:
            return False, [f"Error de sintaxis YAML: {str(e)}"], {}
        except Exception as e:
            return False, [f"Error inesperado: {str(e)}"], {}
    
    def _validate_entity(self, entity: Dict[str, Any], index: int) -> List[str]:
        """Valida una entidad individual"""
        errors = []
        prefix = f"Entidad {index + 1}: "
        
        # Validar estructura básica
        if not isinstance(entity, dict):
            errors.append(f"{prefix}Debe ser un objeto")
            return errors
        
        # Validar apiVersion
        api_version = entity.get('apiVersion')
        if not api_version:
            errors.append(f"{prefix}Falta 'apiVersion'")
        elif not api_version.startswith('backstage.io/'):
            errors.append(f"{prefix}apiVersion debe comenzar con 'backstage.io/'")
        
        # Validar kind
        kind = entity.get('kind')
        if not kind:
            errors.append(f"{prefix}Falta 'kind'")
        elif kind not in self.valid_kinds:
            errors.append(f"{prefix}kind '{kind}' no válido. Válidos: {', '.join(self.valid_kinds)}")
        
        # Validar metadata
        metadata = entity.get('metadata', {})
        if not isinstance(metadata, dict):
            errors.append(f"{prefix}metadata debe ser un objeto")
        else:
            errors.extend(self._validate_metadata(metadata, prefix))
        
        # Validar spec
        spec = entity.get('spec', {})
        if not isinstance(spec, dict):
            errors.append(f"{prefix}spec debe ser un objeto")
        else:
            errors.extend(self._validate_spec(spec, kind, prefix))
        
        # Validar campos requeridos
        if kind in self.required_fields:
            for field_path in self.required_fields[kind]:
                if not self._has_nested_field(entity, field_path):
                    errors.append(f"{prefix}Falta campo requerido: {field_path}")
        
        return errors
    
    def _validate_metadata(self, metadata: Dict[str, Any], prefix: str) -> List[str]:
        """Valida sección metadata"""
        errors = []
        
        # Validar name
        name = metadata.get('name')
        if not name:
            errors.append(f"{prefix}metadata.name es requerido")
        elif not isinstance(name, str):
            errors.append(f"{prefix}metadata.name debe ser string")
        elif not re.match(r'^[a-z0-9-]+$', name):
            errors.append(f"{prefix}metadata.name debe contener solo letras minúsculas, números y guiones")
        
        # Validar title (opcional pero recomendado)
        title = metadata.get('title')
        if title and not isinstance(title, str):
            errors.append(f"{prefix}metadata.title debe ser string")
        
        # Validar description (opcional pero recomendado)
        description = metadata.get('description')
        if description and not isinstance(description, str):
            errors.append(f"{prefix}metadata.description debe ser string")
        
        # Validar tags
        tags = metadata.get('tags')
        if tags:
            if not isinstance(tags, list):
                errors.append(f"{prefix}metadata.tags debe ser una lista")
            else:
                for i, tag in enumerate(tags):
                    if not isinstance(tag, str):
                        errors.append(f"{prefix}metadata.tags[{i}] debe ser string")
        
        # Validar annotations
        annotations = metadata.get('annotations')
        if annotations:
            if not isinstance(annotations, dict):
                errors.append(f"{prefix}metadata.annotations debe ser un objeto")
            else:
                for key, value in annotations.items():
                    if not isinstance(key, str) or not isinstance(value, str):
                        errors.append(f"{prefix}metadata.annotations debe contener solo strings")
        
        return errors
    
    def _validate_spec(self, spec: Dict[str, Any], kind: str, prefix: str) -> List[str]:
        """Valida sección spec según el kind"""
        errors = []
        
        # Validar owner (requerido para todos)
        owner = spec.get('owner')
        if not owner:
            errors.append(f"{prefix}spec.owner es requerido")
        elif not isinstance(owner, str):
            errors.append(f"{prefix}spec.owner debe ser string")
        
        # Validar lifecycle (opcional pero común)
        lifecycle = spec.get('lifecycle')
        if lifecycle and lifecycle not in self.valid_lifecycles:
            errors.append(f"{prefix}spec.lifecycle '{lifecycle}' no válido. Válidos: {', '.join(self.valid_lifecycles)}")
        
        # Validaciones específicas por kind
        if kind == 'Component':
            errors.extend(self._validate_component_spec(spec, prefix))
        elif kind == 'API':
            errors.extend(self._validate_api_spec(spec, prefix))
        elif kind == 'Resource':
            errors.extend(self._validate_resource_spec(spec, prefix))
        elif kind == 'System':
            errors.extend(self._validate_system_spec(spec, prefix))
        
        return errors
    
    def _validate_component_spec(self, spec: Dict[str, Any], prefix: str) -> List[str]:
        """Valida spec de Component"""
        errors = []
        
        # Validar type
        comp_type = spec.get('type')
        if not comp_type:
            errors.append(f"{prefix}spec.type es requerido para Component")
        elif comp_type not in self.valid_component_types:
            errors.append(f"{prefix}spec.type '{comp_type}' no válido para Component")
        
        # Validar system (opcional pero recomendado)
        system = spec.get('system')
        if system and not isinstance(system, str):
            errors.append(f"{prefix}spec.system debe ser string")
        
        # Validar dependsOn
        depends_on = spec.get('dependsOn')
        if depends_on:
            if not isinstance(depends_on, list):
                errors.append(f"{prefix}spec.dependsOn debe ser una lista")
            else:
                for i, dep in enumerate(depends_on):
                    if not isinstance(dep, str):
                        errors.append(f"{prefix}spec.dependsOn[{i}] debe ser string")
        
        # Validar providesApis
        provides_apis = spec.get('providesApis')
        if provides_apis:
            if not isinstance(provides_apis, list):
                errors.append(f"{prefix}spec.providesApis debe ser una lista")
            else:
                for i, api in enumerate(provides_apis):
                    if not isinstance(api, str):
                        errors.append(f"{prefix}spec.providesApis[{i}] debe ser string")
        
        return errors
    
    def _validate_api_spec(self, spec: Dict[str, Any], prefix: str) -> List[str]:
        """Valida spec de API"""
        errors = []
        
        # Validar type
        api_type = spec.get('type')
        if not api_type:
            errors.append(f"{prefix}spec.type es requerido para API")
        elif api_type not in self.valid_api_types:
            errors.append(f"{prefix}spec.type '{api_type}' no válido para API")
        
        return errors
    
    def _validate_resource_spec(self, spec: Dict[str, Any], prefix: str) -> List[str]:
        """Valida spec de Resource"""
        errors = []
        
        # Validar type
        resource_type = spec.get('type')
        if not resource_type:
            errors.append(f"{prefix}spec.type es requerido para Resource")
        elif resource_type not in self.valid_resource_types:
            errors.append(f"{prefix}spec.type '{resource_type}' no válido para Resource")
        
        return errors
    
    def _validate_system_spec(self, spec: Dict[str, Any], prefix: str) -> List[str]:
        """Valida spec de System"""
        errors = []
        
        # Validar domain (opcional)
        domain = spec.get('domain')
        if domain and not isinstance(domain, str):
            errors.append(f"{prefix}spec.domain debe ser string")
        
        return errors
    
    def _has_nested_field(self, obj: Dict[str, Any], field_path: str) -> bool:
        """Verifica si existe un campo anidado (ej: metadata.name)"""
        parts = field_path.split('.')
        current = obj
        
        for part in parts:
            if not isinstance(current, dict) or part not in current:
                return False
            current = current[part]
        
        return current is not None
    
    def fix_common_issues(self, yaml_content: str) -> str:
        """Intenta corregir problemas comunes en el YAML"""
        try:
            documents = list(yaml.safe_load_all(yaml_content))
            fixed_documents = []
            
            for doc in documents:
                if doc is None:
                    continue
                
                # Corregir apiVersion si falta
                if 'apiVersion' not in doc:
                    doc['apiVersion'] = 'backstage.io/v1alpha1'
                
                # Corregir metadata.name si tiene caracteres inválidos
                if 'metadata' in doc and 'name' in doc['metadata']:
                    name = doc['metadata']['name']
                    if isinstance(name, str):
                        # Convertir a formato válido
                        fixed_name = re.sub(r'[^a-z0-9-]', '-', name.lower())
                        fixed_name = re.sub(r'-+', '-', fixed_name)  # Múltiples guiones -> uno
                        fixed_name = fixed_name.strip('-')  # Remover guiones al inicio/final
                        doc['metadata']['name'] = fixed_name
                
                # Añadir owner por defecto si falta
                if 'spec' in doc and 'owner' not in doc['spec']:
                    doc['spec']['owner'] = 'platform-team'
                
                # Añadir lifecycle por defecto si falta
                if 'spec' in doc and 'lifecycle' not in doc['spec']:
                    doc['spec']['lifecycle'] = 'experimental'
                
                fixed_documents.append(doc)
            
            # Convertir de vuelta a YAML
            yaml_parts = []
            for doc in fixed_documents:
                yaml_parts.append(yaml.dump(doc, default_flow_style=False, sort_keys=False))
            
            return '\n---\n'.join(yaml_parts)
            
        except Exception:
            # Si no se puede corregir, devolver original
            return yaml_content
