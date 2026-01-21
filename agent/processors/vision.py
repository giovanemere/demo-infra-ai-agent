import google.generativeai as genai
from PIL import Image
import os
from generators.backstage_generator import BackstageGenerator
from validators.backstage_validator import BackstageValidator

class VisionProcessor:
    def __init__(self):
        genai.configure(api_key=os.getenv('GEMINI_API_KEY'))
        # Usar modelo disponible para visión
        try:
            self.model = genai.GenerativeModel('gemini-2.5-flash')
        except:
            try:
                self.model = genai.GenerativeModel('gemini-flash-latest')
            except:
                try:
                    self.model = genai.GenerativeModel('gemini-pro-latest')
                except:
                    self.model = None
        
        # Inicializar generador y validador
        self.backstage_generator = BackstageGenerator()
        self.validator = BackstageValidator()
    
    def analyze_architecture_for_template(self, image_path: str) -> dict:
        """
        Analiza imagen de arquitectura AWS y extrae servicios para crear template
        
        Args:
            image_path: Ruta a la imagen del diagrama
            
        Returns:
            Dict con servicios AWS detectados y metadatos para template
        """
        if not self.model:
            return self._generate_fallback_template()
        
        try:
            image = Image.open(image_path)
            
            prompt = """
            Analiza esta imagen de arquitectura AWS y extrae:
            
            1. SERVICIOS AWS detectados (nombres exactos como S3, Lambda, CloudFront, etc.)
            2. TIPO DE SOLUCIÓN (web-app, data-pipeline, serverless, etc.)
            3. TÍTULO descriptivo de la solución
            4. DESCRIPCIÓN técnica
            5. PARÁMETROS necesarios para el template
            6. TAGS relevantes
            
            Responde en formato JSON:
            {
                "services": ["S3", "CloudFront", "Lambda", "RDS"],
                "solution_type": "web-app",
                "title": "AWS Web Application with CDN",
                "description": "Aplicación web serverless con S3, CloudFront y Lambda",
                "component_type": "service",
                "tags": ["aws", "serverless", "web", "cdn"],
                "parameters": [
                    {"name": "environment", "title": "Environment", "type": "string"},
                    {"name": "region", "title": "AWS Region", "type": "string"}
                ]
            }
            """
            
            response = self.model.generate_content([prompt, image])
            
            # Extraer JSON de la respuesta
            import json
            import re
            
            json_match = re.search(r'\{.*\}', response.text, re.DOTALL)
            if json_match:
                result = json.loads(json_match.group())
                
                # Validar que tenga servicios AWS
                if result.get('services') and len(result['services']) > 0:
                    return result
            
            return self._generate_fallback_template()
            
        except Exception as e:
            print(f"Error analyzing image: {e}")
            return self._generate_fallback_template()
    
    def _generate_fallback_template(self) -> dict:
        """Genera template básico cuando falla el análisis"""
        return {
            "services": ["S3", "Lambda", "CloudFront"],
            "solution_type": "web-app",
            "title": "AWS Web Application",
            "description": "Aplicación web básica con servicios AWS",
            "component_type": "service",
            "tags": ["aws", "web", "serverless"],
            "parameters": [
                {"name": "environment", "title": "Environment", "type": "string"},
                {"name": "region", "title": "AWS Region", "type": "string"}
            ]
        }
        """
        Analiza diagrama de arquitectura y genera YAML Backstage válido
        
        Args:
            image_path: Ruta a la imagen del diagrama
            
        Returns:
            YAML válido para Backstage
        """
        if not self.model:
            # Usar generador estándar como fallback
            return self._generate_from_image_name(image_path)
        
        try:
            image = Image.open(image_path)
            
            # 1. Extraer descripción de la imagen usando IA
            description = self._extract_description_from_image(image)
            
            # 2. Generar definiciones usando el generador estándar
            definitions = self.backstage_generator.generate_from_description(
                description, 
                source_type='image'
            )
            
            # 3. Convertir a YAML
            yaml_content = self.backstage_generator.to_yaml(definitions)
            
            # 4. Validar YAML generado
            is_valid, errors, parsed = self.validator.validate_yaml(yaml_content)
            
            if not is_valid:
                print(f"YAML generado tiene errores: {errors}")
                # Intentar corregir automáticamente
                yaml_content = self.validator.fix_common_issues(yaml_content)
                
                # Validar nuevamente
                is_valid, errors, parsed = self.validator.validate_yaml(yaml_content)
                if not is_valid:
                    print(f"No se pudieron corregir todos los errores: {errors}")
                    # Usar fallback
                    return self._generate_from_image_name(image_path)
            
            return yaml_content
            
        except Exception as e:
            print(f"Error procesando imagen: {e}")
            return self._generate_from_image_name(image_path)
    
    def _extract_description_from_image(self, image: Image) -> str:
        """Extrae descripción textual de la imagen usando IA"""
        try:
            prompt = """
            Analiza este diagrama de arquitectura AWS y describe en texto plano los servicios y conexiones que ves.
            
            Enfócate en:
            1. Servicios AWS identificados (Lambda, S3, CloudFront, etc.)
            2. Flujo de datos entre servicios
            3. Propósito general de la arquitectura
            
            Responde solo con la descripción en texto, sin formato YAML.
            """
            
            response = self.model.generate_content([prompt, image])
            return response.text.strip()
            
        except Exception as e:
            print(f"Error extrayendo descripción de imagen: {e}")
            return "Arquitectura AWS con múltiples servicios interconectados"
    
    def _generate_from_image_name(self, image_path: str) -> str:
        """Genera YAML basado en el nombre de la imagen como fallback"""
        image_name = os.path.basename(image_path).replace('.png', '').replace('.jpg', '').replace('.jpeg', '')
        
        # Crear descripción básica basada en el nombre del archivo
        description = f"Arquitectura AWS basada en imagen: {image_name}"
        
        # Usar el generador estándar
        definitions = self.backstage_generator.generate_from_description(
            description, 
            source_type='image'
        )
        
        return self.backstage_generator.to_yaml(definitions)
        
        return f"""apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: diagram-architecture-{image_name}
  description: Arquitectura generada desde diagrama de imagen
  annotations:
    aws.com/cost-center: free-tier-audit
    backstage.io/source-image: {image_name}
spec:
  type: service
  lifecycle: experimental
  owner: platform-team
  system: web-platform
---
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: cloud-storage-{image_name}
  description: Almacenamiento en la nube
  annotations:
    aws.com/cost-center: free-tier-audit
spec:
  type: storage
  owner: platform-team
  system: web-platform
---
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: api-service-{image_name}
  description: Servicio API de la arquitectura
  annotations:
    aws.com/cost-center: free-tier-audit
spec:
  type: service
  lifecycle: experimental
  owner: platform-team
  system: web-platform"""
    def process_image(self, image_path: str) -> dict:
        """
        Procesa imagen de arquitectura y devuelve análisis estructurado
        
        Args:
            image_path: Ruta a la imagen
            
        Returns:
            dict: Análisis estructurado con servicios AWS detectados
        """
        try:
            # Usar el método existente de análisis
            analysis = self.analyze_architecture_for_template(image_path)
            
            # Estructurar respuesta
            return {
                "title": analysis.get("title", "AWS Application"),
                "description": analysis.get("description", "Aplicación AWS generada desde imagen"),
                "services": analysis.get("services", []),
                "architecture_type": analysis.get("architecture_type", "web-app"),
                "components": analysis.get("components", []),
                "type": "image_analysis"
            }
            
        except Exception as e:
            return {
                "title": "AWS Application",
                "description": f"Error al procesar imagen: {str(e)}",
                "services": ["S3", "Lambda"],  # Servicios por defecto
                "architecture_type": "web-app",
                "components": [],
                "type": "image_analysis",
                "error": str(e)
            }
