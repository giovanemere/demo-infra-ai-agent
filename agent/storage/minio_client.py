"""
Cliente MinIO para Infrastructure AI Platform
Maneja almacenamiento de archivos temporales y documentación generada
"""
import os
import json
import tempfile
from datetime import datetime
from typing import Optional, Dict, Any
from minio import Minio
from minio.error import S3Error
import yaml

class MinIOClient:
    """Cliente para gestionar archivos en MinIO"""
    
    def __init__(self, 
                 endpoint: str = "localhost:9000",
                 access_key: str = "backstage", 
                 secret_key: str = "backstage123",
                 secure: bool = False):
        """
        Inicializar cliente MinIO
        
        Args:
            endpoint: Endpoint de MinIO (default: localhost:9000)
            access_key: Access key (default: backstage)
            secret_key: Secret key (default: backstage123)
            secure: Usar HTTPS (default: False)
        """
        self.client = Minio(
            endpoint=endpoint,
            access_key=access_key,
            secret_key=secret_key,
            secure=secure
        )
        
        self.buckets = {
            'docs': 'backstage-docs',
            'assets': 'backstage-assets', 
            'temp': 'backstage-temp'
        }
        
        # Verificar conexión
        self._ensure_buckets_exist()
    
    def _ensure_buckets_exist(self):
        """Asegurar que los buckets existen"""
        try:
            for bucket_name in self.buckets.values():
                if not self.client.bucket_exists(bucket_name):
                    self.client.make_bucket(bucket_name)
                    print(f"✅ Bucket creado: {bucket_name}")
        except S3Error as e:
            print(f"⚠️ Error verificando buckets: {e}")
    
    def upload_yaml_definition(self, yaml_content: str, project_name: str, source_type: str = 'text') -> Dict[str, str]:
        """
        Subir definición YAML generada por IA
        
        Args:
            yaml_content: Contenido YAML
            project_name: Nombre del proyecto
            source_type: 'text' o 'image'
            
        Returns:
            Dict con URLs y metadata
        """
        try:
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            filename = f"{project_name}_{timestamp}.yaml"
            object_name = f"generated/{source_type}/{filename}"
            
            # Crear archivo temporal
            with tempfile.NamedTemporaryFile(mode='w', suffix='.yaml', delete=False) as tmp_file:
                tmp_file.write(yaml_content)
                tmp_path = tmp_file.name
            
            try:
                # Subir a MinIO
                self.client.fput_object(
                    bucket_name=self.buckets['docs'],
                    object_name=object_name,
                    file_path=tmp_path,
                    content_type='application/x-yaml'
                )
                
                # Generar URLs
                public_url = f"http://localhost:9000/{self.buckets['docs']}/{object_name}"
                
                # Crear metadata
                metadata = {
                    'project_name': project_name,
                    'source_type': source_type,
                    'generated_at': datetime.now().isoformat(),
                    'filename': filename,
                    'object_name': object_name,
                    'public_url': public_url,
                    'bucket': self.buckets['docs']
                }
                
                # Subir metadata como JSON
                metadata_name = f"generated/{source_type}/{project_name}_{timestamp}_metadata.json"
                self._upload_json(metadata, metadata_name, self.buckets['docs'])
                
                print(f"✅ YAML subido: {public_url}")
                return metadata
                
            finally:
                # Limpiar archivo temporal
                os.unlink(tmp_path)
                
        except S3Error as e:
            print(f"❌ Error subiendo YAML: {e}")
            raise
    
    def upload_temp_file(self, file_path: str, prefix: str = 'temp') -> str:
        """
        Subir archivo temporal (imágenes, etc.)
        
        Args:
            file_path: Ruta del archivo
            prefix: Prefijo para organización
            
        Returns:
            URL pública del archivo
        """
        try:
            filename = os.path.basename(file_path)
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            object_name = f"{prefix}/{timestamp}_{filename}"
            
            # Detectar content type
            content_type = 'application/octet-stream'
            if filename.lower().endswith(('.png', '.jpg', '.jpeg')):
                content_type = 'image/jpeg' if filename.lower().endswith(('.jpg', '.jpeg')) else 'image/png'
            elif filename.lower().endswith('.yaml'):
                content_type = 'application/x-yaml'
            elif filename.lower().endswith('.json'):
                content_type = 'application/json'
            
            # Subir archivo
            self.client.fput_object(
                bucket_name=self.buckets['temp'],
                object_name=object_name,
                file_path=file_path,
                content_type=content_type
            )
            
            public_url = f"http://localhost:9000/{self.buckets['temp']}/{object_name}"
            print(f"✅ Archivo temporal subido: {public_url}")
            return public_url
            
        except S3Error as e:
            print(f"❌ Error subiendo archivo temporal: {e}")
            raise
    
    def upload_documentation(self, docs_dir: str, project_name: str) -> Dict[str, str]:
        """
        Subir documentación completa de un proyecto
        
        Args:
            docs_dir: Directorio con documentación
            project_name: Nombre del proyecto
            
        Returns:
            Dict con URLs de documentos subidos
        """
        try:
            uploaded_docs = {}
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            
            for root, dirs, files in os.walk(docs_dir):
                for file in files:
                    if file.endswith(('.md', '.yaml', '.json', '.html')):
                        file_path = os.path.join(root, file)
                        relative_path = os.path.relpath(file_path, docs_dir)
                        object_name = f"projects/{project_name}/{timestamp}/{relative_path}"
                        
                        # Detectar content type
                        content_type = 'text/plain'
                        if file.endswith('.md'):
                            content_type = 'text/markdown'
                        elif file.endswith('.yaml'):
                            content_type = 'application/x-yaml'
                        elif file.endswith('.json'):
                            content_type = 'application/json'
                        elif file.endswith('.html'):
                            content_type = 'text/html'
                        
                        # Subir archivo
                        self.client.fput_object(
                            bucket_name=self.buckets['docs'],
                            object_name=object_name,
                            file_path=file_path,
                            content_type=content_type
                        )
                        
                        public_url = f"http://localhost:9000/{self.buckets['docs']}/{object_name}"
                        uploaded_docs[relative_path] = public_url
            
            print(f"✅ Documentación subida: {len(uploaded_docs)} archivos")
            return uploaded_docs
            
        except S3Error as e:
            print(f"❌ Error subiendo documentación: {e}")
            raise
    
    def _upload_json(self, data: Dict[str, Any], object_name: str, bucket: str):
        """Subir datos JSON a MinIO"""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as tmp_file:
            json.dump(data, tmp_file, indent=2, default=str)
            tmp_path = tmp_file.name
        
        try:
            self.client.fput_object(
                bucket_name=bucket,
                object_name=object_name,
                file_path=tmp_path,
                content_type='application/json'
            )
        finally:
            os.unlink(tmp_path)
    
    def list_generated_files(self, source_type: Optional[str] = None) -> list:
        """
        Listar archivos generados
        
        Args:
            source_type: Filtrar por 'text' o 'image' (opcional)
            
        Returns:
            Lista de archivos generados
        """
        try:
            prefix = f"generated/{source_type}/" if source_type else "generated/"
            objects = self.client.list_objects(
                bucket_name=self.buckets['docs'],
                prefix=prefix,
                recursive=True
            )
            
            files = []
            for obj in objects:
                if obj.object_name.endswith('.yaml'):
                    files.append({
                        'name': obj.object_name,
                        'size': obj.size,
                        'last_modified': obj.last_modified,
                        'url': f"http://localhost:9000/{self.buckets['docs']}/{obj.object_name}"
                    })
            
            return files
            
        except S3Error as e:
            print(f"❌ Error listando archivos: {e}")
            return []
    
    def cleanup_temp_files(self, older_than_hours: int = 24):
        """
        Limpiar archivos temporales antiguos
        
        Args:
            older_than_hours: Eliminar archivos más antiguos que X horas
        """
        try:
            from datetime import timedelta
            cutoff_time = datetime.now() - timedelta(hours=older_than_hours)
            
            objects = self.client.list_objects(
                bucket_name=self.buckets['temp'],
                recursive=True
            )
            
            deleted_count = 0
            for obj in objects:
                if obj.last_modified < cutoff_time:
                    self.client.remove_object(self.buckets['temp'], obj.object_name)
                    deleted_count += 1
            
            print(f"✅ Limpieza completada: {deleted_count} archivos temporales eliminados")
            
        except S3Error as e:
            print(f"❌ Error en limpieza: {e}")
    
    def get_stats(self) -> Dict[str, Any]:
        """Obtener estadísticas de uso"""
        try:
            stats = {}
            
            for bucket_type, bucket_name in self.buckets.items():
                objects = list(self.client.list_objects(bucket_name, recursive=True))
                total_size = sum(obj.size for obj in objects)
                
                stats[bucket_type] = {
                    'bucket_name': bucket_name,
                    'file_count': len(objects),
                    'total_size_mb': round(total_size / (1024 * 1024), 2),
                    'files': [obj.object_name for obj in objects[:5]]  # Primeros 5
                }
            
            return stats
            
        except S3Error as e:
            print(f"❌ Error obteniendo estadísticas: {e}")
            return {}
