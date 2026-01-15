import google.generativeai as genai
from PIL import Image
import os

class VisionProcessor:
    def __init__(self):
        genai.configure(api_key=os.getenv('GEMINI_API_KEY'))
        self.model = genai.GenerativeModel('gemini-1.5-pro')
    
    def analyze_diagram(self, image_path: str) -> str:
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
        
        Ejemplo:
        ```yaml
        apiVersion: backstage.io/v1alpha1
        kind: Component
        metadata:
          name: static-blog
          description: Blog estático en AWS
          annotations:
            aws.com/cost-center: free-tier-audit
        spec:
          type: website
          lifecycle: production
          owner: platform-team
        ---
        apiVersion: backstage.io/v1alpha1
        kind: Resource
        metadata:
          name: blog-storage
          annotations:
            aws.com/cost-center: free-tier-audit
        spec:
          type: storage
          owner: platform-team
        ```
        """
        
        response = self.model.generate_content([prompt, image])
        return response.text
