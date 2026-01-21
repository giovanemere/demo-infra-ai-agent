import google.generativeai as genai
import os
from dotenv import load_dotenv
from generators.backstage_generator import BackstageGenerator
from validators.backstage_validator import BackstageValidator

class TextProcessor:
    def __init__(self):
        # Cargar variables de entorno
        load_dotenv()
        
        api_key = os.getenv('GEMINI_API_KEY')
        if not api_key:
            raise ValueError("GEMINI_API_KEY no encontrada en variables de entorno")
        
        genai.configure(api_key=api_key)
        self.model = genai.GenerativeModel('gemini-1.5-pro')
        
        # Inicializar generador y validador
        self.backstage_generator = BackstageGenerator()
        self.validator = BackstageValidator()
    
    def analyze_text_for_template(self, text_description: str) -> dict:
        """
        Analiza descripción de texto AWS y extrae servicios para crear template
        
        Args:
            text_description: Descripción de la arquitectura AWS
            
        Returns:
            Dict con servicios AWS detectados y metadatos para template
        """
        try:
            prompt = f"""
            Analiza esta descripción de arquitectura AWS y extrae:
            
            1. SERVICIOS AWS mencionados (nombres exactos como S3, Lambda, CloudFront, etc.)
            2. TIPO DE SOLUCIÓN (web-app, data-pipeline, serverless, microservices, etc.)
            3. TÍTULO descriptivo de la solución
            4. DESCRIPCIÓN técnica mejorada
            5. PARÁMETROS necesarios para el template
            6. TAGS relevantes
            
            Descripción: "{text_description}"
            
            Responde en formato JSON:
            {{
                "services": ["S3", "CloudFront", "Lambda", "RDS"],
                "solution_type": "web-app",
                "title": "AWS Web Application with CDN",
                "description": "Aplicación web serverless con S3, CloudFront y Lambda para alta disponibilidad",
                "component_type": "service",
                "tags": ["aws", "serverless", "web", "cdn"],
                "parameters": [
                    {{"name": "environment", "title": "Environment", "type": "string"}},
                    {{"name": "region", "title": "AWS Region", "type": "string"}},
                    {{"name": "domain_name", "title": "Domain Name", "type": "string"}}
                ]
            }}
            """
            
            response = self.model.generate_content(prompt)
            
            # Extraer JSON de la respuesta
            import json
            import re
            
            json_match = re.search(r'\{.*\}', response.text, re.DOTALL)
            if json_match:
                result = json.loads(json_match.group())
                
                # Validar que tenga servicios AWS
                if result.get('services') and len(result['services']) > 0:
                    return result
            
        except Exception as e:
            print(f"Error analyzing text: {e}")
        
        # Usar fallback si falla el análisis con IA
        return self._generate_fallback_template(text_description)
    
    def _generate_fallback_template(self, description: str) -> dict:
        """Genera template básico cuando falla el análisis"""
        # Detectar servicios comunes en el texto
        services = []
        if 's3' in description.lower(): services.append('S3')
        if 'lambda' in description.lower(): services.append('Lambda')
        if 'cloudfront' in description.lower(): services.append('CloudFront')
        if 'rds' in description.lower(): services.append('RDS')
        if 'ec2' in description.lower(): services.append('EC2')
        if 'api gateway' in description.lower(): services.append('API Gateway')
        
        if not services:
            services = ['S3', 'Lambda', 'CloudFront']
        
        return {
            "services": services,
            "solution_type": "web-app",
            "title": "AWS Application",
            "description": description[:200] + "..." if len(description) > 200 else description,
            "component_type": "service",
            "tags": ["aws", "generated"],
            "parameters": [
                {"name": "environment", "title": "Environment", "type": "string"},
                {"name": "region", "title": "AWS Region", "type": "string"}
            ]
        }
        """
        Analiza descripción de texto y genera YAML Backstage válido
        
        Args:
            text_description: Descripción de la arquitectura
            
        Returns:
            YAML válido para Backstage
        """
        try:
            # 1. Generar definiciones usando el generador estándar
            definitions = self.backstage_generator.generate_from_description(
                text_description, 
                source_type='text'
            )
            
            # 2. Convertir a YAML
            yaml_content = self.backstage_generator.to_yaml(definitions)
            
            # 3. Validar YAML generado
            is_valid, errors, parsed = self.validator.validate_yaml(yaml_content)
            
            if not is_valid:
                print(f"YAML generado tiene errores: {errors}")
                # Intentar corregir automáticamente
                yaml_content = self.validator.fix_common_issues(yaml_content)
                
                # Validar nuevamente
                is_valid, errors, parsed = self.validator.validate_yaml(yaml_content)
                if not is_valid:
                    print(f"No se pudieron corregir todos los errores: {errors}")
                    # Usar fallback con IA como respaldo
                    return self._analyze_with_ai_fallback(text_description)
            
            return yaml_content
            
        except Exception as e:
            print(f"Error en análisis estándar: {e}")
            # Fallback a IA si falla el generador estándar
            return self._analyze_with_ai_fallback(text_description)
    
    def _analyze_with_ai_fallback(self, text_description: str) -> str:
        """Fallback usando IA cuando falla el generador estándar"""
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
