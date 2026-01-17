import google.generativeai as genai
import os
from dotenv import load_dotenv

class TextProcessor:
    def __init__(self):
        # Cargar variables de entorno
        load_dotenv()
        
        api_key = os.getenv('GEMINI_API_KEY')
        if not api_key:
            raise ValueError("GEMINI_API_KEY no encontrada en variables de entorno")
        
        genai.configure(api_key=api_key)
        self.model = genai.GenerativeModel('gemini-1.5-pro')
    
    def analyze_text(self, text_description: str) -> str:
        try:
            prompt = f"""
            Eres un experto en Platform Engineering. Analiza esta descripción de arquitectura AWS y genera un catalog-info.yaml válido para Backstage.

            DESCRIPCIÓN: {text_description}

            REGLAS ESPECÍFICAS:
            1. Analiza los servicios mencionados y mapéalos correctamente:
               - API Gateway -> kind: API, type: rest-api
               - Lambda -> kind: Component, type: service
               - DynamoDB -> kind: Resource, type: database
               - RDS -> kind: Resource, type: database  
               - S3 -> kind: Resource, type: storage
               - CloudFront -> kind: Component, type: cdn
               - ELB/ALB -> kind: Component, type: load-balancer
               - EC2 -> kind: Component, type: service
               - Route53 -> kind: Resource, type: dns

            2. Crear nombres específicos basados en la descripción
            3. Incluir dependencias entre componentes
            4. Siempre incluir: owner: platform-team
            5. Añadir annotation: aws.com/cost-center: free-tier-audit
            6. Usar lifecycle apropiado: experimental, production, deprecated

            FORMATO: Solo YAML válido, sin explicaciones adicionales.
            
            Ejemplo para "API con Lambda y DynamoDB":
            ```yaml
            apiVersion: backstage.io/v1alpha1
            kind: API
            metadata:
              name: user-api
              description: API para gestión de usuarios
              annotations:
                aws.com/cost-center: free-tier-audit
            spec:
              type: rest-api
              lifecycle: production
              owner: platform-team
              system: user-management
            ---
            apiVersion: backstage.io/v1alpha1
            kind: Component
            metadata:
              name: user-lambda
              description: Lambda function para lógica de usuarios
              annotations:
                aws.com/cost-center: free-tier-audit
            spec:
              type: service
              lifecycle: production
              owner: platform-team
              system: user-management
              providesApis:
                - user-api
              dependsOn:
                - resource:user-database
            ---
            apiVersion: backstage.io/v1alpha1
            kind: Resource
            metadata:
              name: user-database
              description: DynamoDB para datos de usuarios
              annotations:
                aws.com/cost-center: free-tier-audit
                aws.com/service-type: dynamodb
            spec:
              type: database
              owner: platform-team
              system: user-management
            ```
            """
            
            response = self.model.generate_content(prompt)
            return response.text
            
        except Exception as e:
            # Fallback mejorado basado en la descripción
            return self._generate_smart_fallback(text_description)
    
    def _generate_smart_fallback(self, description: str) -> str:
        """Genera YAML inteligente basado en palabras clave"""
        desc_lower = description.lower()
        
        # Detectar servicios mencionados
        services = []
        if 'api gateway' in desc_lower or 'api' in desc_lower:
            services.append(('api', 'API Gateway'))
        if 'lambda' in desc_lower:
            services.append(('lambda', 'Lambda Function'))
        if 'dynamodb' in desc_lower:
            services.append(('dynamodb', 'DynamoDB Database'))
        if 'rds' in desc_lower or 'mysql' in desc_lower or 'postgres' in desc_lower:
            services.append(('rds', 'RDS Database'))
        if 's3' in desc_lower:
            services.append(('s3', 'S3 Storage'))
        if 'cloudfront' in desc_lower or 'cdn' in desc_lower:
            services.append(('cloudfront', 'CloudFront CDN'))
        if 'elb' in desc_lower or 'load balancer' in desc_lower or 'balanceador' in desc_lower:
            services.append(('elb', 'Load Balancer'))
        if 'ec2' in desc_lower:
            services.append(('ec2', 'EC2 Instance'))
        
        # Generar YAML basado en servicios detectados
        yaml_parts = []
        system_name = 'detected-architecture'
        
        for service_type, service_name in services:
            if service_type == 'api':
                yaml_parts.append(f"""apiVersion: backstage.io/v1alpha1
kind: API
metadata:
  name: {system_name}-api
  description: {service_name} - {description}
  annotations:
    aws.com/cost-center: free-tier-audit
spec:
  type: rest-api
  lifecycle: experimental
  owner: platform-team
  system: {system_name}""")
            
            elif service_type in ['lambda', 'ec2']:
                yaml_parts.append(f"""apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: {system_name}-{service_type}
  description: {service_name} - {description}
  annotations:
    aws.com/cost-center: free-tier-audit
    aws.com/service-type: {service_type}
spec:
  type: service
  lifecycle: experimental
  owner: platform-team
  system: {system_name}""")
            
            elif service_type in ['dynamodb', 'rds', 's3']:
                resource_type = 'database' if service_type in ['dynamodb', 'rds'] else 'storage'
                yaml_parts.append(f"""apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: {system_name}-{service_type}
  description: {service_name} - {description}
  annotations:
    aws.com/cost-center: free-tier-audit
    aws.com/service-type: {service_type}
spec:
  type: {resource_type}
  owner: platform-team
  system: {system_name}""")
            
            elif service_type in ['cloudfront', 'elb']:
                comp_type = 'cdn' if service_type == 'cloudfront' else 'load-balancer'
                yaml_parts.append(f"""apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: {system_name}-{service_type}
  description: {service_name} - {description}
  annotations:
    aws.com/cost-center: free-tier-audit
    aws.com/service-type: {service_type}
spec:
  type: {comp_type}
  lifecycle: experimental
  owner: platform-team
  system: {system_name}""")
        
        if not yaml_parts:
            # Fallback genérico
            yaml_parts.append(f"""apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: {system_name}-service
  description: {description}
  annotations:
    aws.com/cost-center: free-tier-audit
spec:
  type: service
  lifecycle: experimental
  owner: platform-team
  system: {system_name}""")
        
        return '\n---\n'.join(yaml_parts)
