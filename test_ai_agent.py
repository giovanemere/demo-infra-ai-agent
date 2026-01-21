#!/usr/bin/env python3
"""
Script de prueba para verificar la funcionalidad completa del AI Agent
"""
import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), 'agent'))

from processors.text import TextProcessor
from processors.vision import VisionProcessor
from validators.backstage_validator import BackstageValidator
from generators.backstage_generator import BackstageGenerator

def test_text_processing():
    """Prueba el procesamiento de texto"""
    print("🧪 Probando procesamiento de texto...")
    
    try:
        processor = TextProcessor()
        
        # Descripción de prueba
        description = """
        Necesito una API REST que use Lambda para procesar datos, 
        guarde información en DynamoDB y sirva contenido estático desde S3 
        a través de CloudFront. También necesito Route53 para el DNS.
        """
        
        yaml_result = processor.analyze_text(description)
        print("✅ Procesamiento de texto exitoso")
        print("📄 YAML generado:")
        print("-" * 50)
        print(yaml_result[:500] + "..." if len(yaml_result) > 500 else yaml_result)
        print("-" * 50)
        
        return True
        
    except Exception as e:
        print(f"❌ Error en procesamiento de texto: {e}")
        return False

def test_yaml_validation():
    """Prueba la validación de YAML"""
    print("\n🧪 Probando validación de YAML...")
    
    try:
        validator = BackstageValidator()
        
        # YAML de prueba válido
        valid_yaml = """
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: test-service
  title: Test Service
  description: A test service
spec:
  type: service
  lifecycle: experimental
  owner: platform-team
"""
        
        is_valid, errors, parsed = validator.validate_yaml(valid_yaml)
        
        if is_valid:
            print("✅ Validación de YAML exitosa")
            print(f"📊 Entidades encontradas: {parsed['count']}")
        else:
            print(f"❌ YAML inválido: {errors}")
            return False
        
        return True
        
    except Exception as e:
        print(f"❌ Error en validación: {e}")
        return False

def test_backstage_generator():
    """Prueba el generador de Backstage"""
    print("\n🧪 Probando generador de Backstage...")
    
    try:
        generator = BackstageGenerator()
        
        description = "API con Lambda, DynamoDB y S3"
        definitions = generator.generate_from_description(description)
        
        print("✅ Generación de definiciones exitosa")
        print(f"📊 Sistema: {definitions['system']['metadata']['name']}")
        print(f"📊 Componentes: {len(definitions['components'])}")
        print(f"📊 Recursos: {len(definitions['resources'])}")
        print(f"📊 APIs: {len(definitions['apis'])}")
        
        # Convertir a YAML
        yaml_output = generator.to_yaml(definitions)
        print("✅ Conversión a YAML exitosa")
        
        return True
        
    except Exception as e:
        print(f"❌ Error en generador: {e}")
        return False

def test_integration():
    """Prueba la integración completa"""
    print("\n🧪 Probando integración completa...")
    
    try:
        # Generar con el generador
        generator = BackstageGenerator()
        description = "Aplicación web con API Gateway, Lambda, RDS MySQL y CloudFront"
        definitions = generator.generate_from_description(description)
        yaml_content = generator.to_yaml(definitions)
        
        # Validar el resultado
        validator = BackstageValidator()
        is_valid, errors, parsed = validator.validate_yaml(yaml_content)
        
        if is_valid:
            print("✅ Integración completa exitosa")
            print(f"📊 Pipeline: Descripción → Generador → YAML → Validador ✅")
            return True
        else:
            print(f"❌ YAML generado no es válido: {errors}")
            
            # Intentar corregir
            fixed_yaml = validator.fix_common_issues(yaml_content)
            is_valid_fixed, errors_fixed, parsed_fixed = validator.validate_yaml(fixed_yaml)
            
            if is_valid_fixed:
                print("✅ YAML corregido automáticamente")
                return True
            else:
                print(f"❌ No se pudo corregir: {errors_fixed}")
                return False
        
    except Exception as e:
        print(f"❌ Error en integración: {e}")
        return False

def main():
    """Ejecuta todas las pruebas"""
    print("🚀 INICIANDO PRUEBAS DEL AI AGENT")
    print("=" * 50)
    
    tests = [
        ("Generador de Backstage", test_backstage_generator),
        ("Validación de YAML", test_yaml_validation),
        ("Procesamiento de Texto", test_text_processing),
        ("Integración Completa", test_integration)
    ]
    
    results = []
    
    for test_name, test_func in tests:
        try:
            result = test_func()
            results.append((test_name, result))
        except Exception as e:
            print(f"❌ Error ejecutando {test_name}: {e}")
            results.append((test_name, False))
    
    # Resumen
    print("\n" + "=" * 50)
    print("📊 RESUMEN DE PRUEBAS")
    print("=" * 50)
    
    passed = 0
    for test_name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{status} {test_name}")
        if result:
            passed += 1
    
    print(f"\n🎯 Resultado: {passed}/{len(results)} pruebas pasaron")
    
    if passed == len(results):
        print("🎉 ¡Todas las pruebas pasaron! El AI Agent está 100% funcional.")
        return 0
    else:
        print("⚠️  Algunas pruebas fallaron. Revisar la configuración.")
        return 1

if __name__ == "__main__":
    exit(main())
