import google.generativeai as genai
from PIL import Image
import os

class VisionProcessor:
    def __init__(self):
        genai.configure(api_key=os.getenv('GEMINI_API_KEY'))
        # Usar modelo disponible para visión
        try:
            self.model = genai.GenerativeModel('gemini-1.5-flash')
        except:
            try:
                self.model = genai.GenerativeModel('gemini-pro-vision')
            except:
                self.model = None
    
    def analyze_diagram(self, image_path: str) -> str:
        if not self.model:
            # Fallback si no hay modelo de visión disponible
            return self._generate_fallback_yaml(image_path)
        
        try:
            image = Image.open(image_path)
            
            prompt = """
            Eres un experto en Platform Engineering. Analiza este diagrama de arquitectura AWS y genera un catalog-info.yaml válido para Backstage.

            REGLAS:
            1. Mapea cada servicio AWS a un componente Backstage
            2. S3 Bucket -> kind: Resource, type: storage
            3. Lambda -> kind: Component, type: service  
            4. CloudFront -> kind: Component, type: cdn
            5. Route53 -> kind: Resource, type: dns
            6. Siempre incluir: owner: platform-team
            7. Añadir annotation: aws.com/cost-center: free-tier-audit

            FORMATO: Solo YAML válido, sin explicaciones adicionales.
            """
            
            response = self.model.generate_content([prompt, image])
            return response.text
            
        except Exception as e:
            print(f"Error procesando imagen con Gemini: {e}")
            return self._generate_fallback_yaml(image_path)
    
    def _generate_fallback_yaml(self, image_path: str) -> str:
        """Genera YAML de ejemplo cuando no se puede procesar la imagen"""
        image_name = os.path.basename(image_path).replace('.png', '').replace('.jpg', '').replace('.jpeg', '')
        
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
