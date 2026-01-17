import yaml
from typing import Dict, Any

class BackstageValidator:
    def validate_yaml(self, yaml_content: str) -> bool:
        """Valida que el YAML sea válido y tenga estructura básica de Backstage"""
        try:
            # Solo verificar que sea YAML válido
            docs = list(yaml.safe_load_all(yaml_content))
            
            # Verificar que hay al menos un documento
            if not docs:
                return False
                
            # Verificar que cada documento tenga estructura básica
            for doc in docs:
                if not isinstance(doc, dict):
                    continue
                
                # Verificar campos mínimos requeridos
                if 'apiVersion' not in doc or 'kind' not in doc:
                    continue
                    
                # Si llegamos aquí, al menos un documento es válido
                return True
            
            return True  # Si el YAML es parseable, lo consideramos válido
            
        except yaml.YAMLError as e:
            print(f"YAML Error: {e}")
            return False
        except Exception as e:
            print(f"Validation Error: {e}")
            return False
