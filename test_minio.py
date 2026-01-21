#!/usr/bin/env python3
"""
Script de prueba para MinIO con Infrastructure AI Platform
"""
import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), 'agent'))

from storage.minio_client import MinIOClient

def test_minio_connection():
    """Probar conexión a MinIO"""
    print("🧪 Probando conexión a MinIO...")
    
    try:
        client = MinIOClient()
        print("✅ Conexión a MinIO exitosa")
        return client
    except Exception as e:
        print(f"❌ Error conectando a MinIO: {e}")
        return None

def test_yaml_upload(client):
    """Probar subida de YAML"""
    print("\n🧪 Probando subida de YAML...")
    
    try:
        yaml_content = """apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: test-minio-component
  title: Test MinIO Component
  description: Componente de prueba para MinIO
  annotations:
    ai.platform/source-type: text
    ai.platform/generated-at: "2026-01-20T17:00:00"
spec:
  type: service
  lifecycle: experimental
  owner: platform-team
  system: test-system
"""
        
        metadata = client.upload_yaml_definition(
            yaml_content, 
            "test-minio-project", 
            source_type="text"
        )
        
        print("✅ YAML subido exitosamente")
        print(f"📄 URL: {metadata['public_url']}")
        print(f"📁 Bucket: {metadata['bucket']}")
        return True
        
    except Exception as e:
        print(f"❌ Error subiendo YAML: {e}")
        return False

def test_stats(client):
    """Probar estadísticas"""
    print("\n🧪 Probando estadísticas...")
    
    try:
        stats = client.get_stats()
        print("✅ Estadísticas obtenidas")
        
        for bucket_type, info in stats.items():
            print(f"📊 {bucket_type.upper()}:")
            print(f"   📁 Bucket: {info['bucket_name']}")
            print(f"   📄 Archivos: {info['file_count']}")
            print(f"   💾 Tamaño: {info['total_size_mb']} MB")
        
        return True
        
    except Exception as e:
        print(f"❌ Error obteniendo estadísticas: {e}")
        return False

def test_list_files(client):
    """Probar listado de archivos"""
    print("\n🧪 Probando listado de archivos...")
    
    try:
        files = client.list_generated_files()
        print(f"✅ Archivos listados: {len(files)}")
        
        for file_info in files[:3]:  # Mostrar primeros 3
            print(f"📄 {file_info['name']}")
            print(f"   🔗 URL: {file_info['url']}")
            print(f"   📅 Modificado: {file_info['last_modified']}")
        
        return True
        
    except Exception as e:
        print(f"❌ Error listando archivos: {e}")
        return False

def main():
    """Ejecutar todas las pruebas de MinIO"""
    print("🚀 INICIANDO PRUEBAS DE MINIO")
    print("=" * 50)
    
    # Probar conexión
    client = test_minio_connection()
    if not client:
        print("❌ No se puede continuar sin conexión a MinIO")
        return 1
    
    # Ejecutar pruebas
    tests = [
        ("Subida de YAML", lambda: test_yaml_upload(client)),
        ("Estadísticas", lambda: test_stats(client)),
        ("Listado de archivos", lambda: test_list_files(client))
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
    print("📊 RESUMEN DE PRUEBAS MINIO")
    print("=" * 50)
    
    passed = 0
    for test_name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{status} {test_name}")
        if result:
            passed += 1
    
    print(f"\n🎯 Resultado: {passed}/{len(results)} pruebas pasaron")
    
    if passed == len(results):
        print("🎉 ¡MinIO está completamente funcional!")
        print("\n🌐 Acceso a MinIO Console: http://localhost:9001")
        print("🔐 Usuario: backstage | Password: backstage123")
        return 0
    else:
        print("⚠️  Algunas pruebas fallaron. Revisar la configuración de MinIO.")
        return 1

if __name__ == "__main__":
    exit(main())
