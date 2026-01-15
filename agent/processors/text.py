import google.generativeai as genai
import os

class TextProcessor:
    def __init__(self):
        genai.configure(api_key=os.getenv('GEMINI_API_KEY'))
        self.model = genai.GenerativeModel('gemini-1.5-pro')
    
    def analyze_text(self, text_description: str) -> str:
        prompt = f"""
        Eres un experto en Platform Engineering. Analiza esta descripción de arquitectura AWS y genera un catalog-info.yaml válido para Backstage.

        DESCRIPCIÓN: {text_description}

        REGLAS:
        1. Mapea cada servicio AWS mencionado a un componente Backstage
        2. S3 Bucket -> kind: Resource, type: storage
        3. Lambda -> kind: Component, type: service  
        4. CloudFront -> kind: Component, type: cdn
        5. Route53 -> kind: Resource, type: dns
        6. Siempre incluir: owner: platform-team
        7. Añadir annotation: aws.com/cost-center: free-tier-audit

        FORMATO: Solo YAML válido, sin explicaciones adicionales.
        """
        
        response = self.model.generate_content(prompt)
        return response.text
