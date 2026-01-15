import yaml
from typing import Dict, Any

class BackstageValidator:
    def validate_yaml(self, yaml_content: str) -> bool:
        """Valida que el YAML sea válido y tenga estructura básica de Backstage"""
        try:
            docs = list(yaml.safe_load_all(yaml_content))
            
            for doc in docs:
                if not isinstance(doc, dict):
                    return False
                
                # Verificar campos requeridos
                required_fields = ['apiVersion', 'kind', 'metadata', 'spec']
                if not all(field in doc for field in required_fields):
                    return False
                
                # Verificar que tenga owner
                if 'owner' not in doc.get('spec', {}):
                    return False
            
            return True
        except yaml.YAMLError:
            return False
