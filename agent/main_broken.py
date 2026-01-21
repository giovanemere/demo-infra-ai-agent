from fastapi import FastAPI, UploadFile, File, Form, Depends, HTTPException
from fastapi.staticfiles import StaticFiles
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from processors.vision import VisionProcessor
from processors.text import TextProcessor
from validators.backstage_validator import BackstageValidator
from generators.backstage_generator import BackstageGenerator
from generators.template_generator import TemplateGenerator
from git_client import GitClient
from database import create_tables, get_db, save_analysis, get_recent_analyses, save_github_config, get_active_github_config
import tempfile
import os
import hashlib
import json
import uuid
from pydantic import BaseModel
from typing import List, Dict, Any, Optional

app = FastAPI(
    title="Infrastructure AI Agent",
    description="AI-powered infrastructure analysis and Backstage template generation",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# CORS para Backstage
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:7007"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Crear tablas al iniciar
create_tables()

# Servir archivos estáticos (solo para desarrollo)
app.mount("/static", StaticFiles(directory="static"), name="static")

# Inicializar componentes
vision = VisionProcessor()
text_processor = TextProcessor()
validator = BackstageValidator()
template_generator = TemplateGenerator()
git_client = GitClient()

# Modelos Pydantic para Backstage Integration
class ScaffolderInput(BaseModel):
    """Input model for Scaffolder actions"""
    values: Dict[str, Any]
    secrets: Optional[Dict[str, str]] = {}
    
class ScaffolderOutput(BaseModel):
    """Output model for Scaffolder actions"""
    templateId: str
    repositoryUrl: Optional[str] = None
    catalogEntityRef: Optional[str] = None
    
class AnalysisRequest(BaseModel):
    """Request model for AI analysis"""
    description: str
    project_name: Optional[str] = None
    technology: str = "aws"
    
class TemplateParameter(BaseModel):
    name: str
    title: str
    type: str

class TemplateRequest(BaseModel):
    template_name: str
    template_title: str
    template_description: str
    technology: str
    component_type: str
    tags: str
    owner: str
    parameters: List[TemplateParameter]

# Health Check
@app.get("/health")
async def health_check():
    """Health check endpoint for Backstage monitoring"""
    return {
        "status": "healthy",
        "version": "1.0.0",
        "services": {
            "gemini_ai": "connected",
            "github": "configured",
            "database": "connected"
        }
    }

# Backstage Scaffolder Actions
@app.post("/scaffolder/actions/ai-analyze-text", response_model=ScaffolderOutput)
async def scaffolder_analyze_text(input_data: ScaffolderInput, db: Session = Depends(get_db)):
    """Scaffolder action to analyze text and generate template"""
    try:
        description = input_data.values.get("description", "")
        project_name = input_data.values.get("name", f"ai-project-{uuid.uuid4().hex[:8]}")
        
        if not description:
            raise HTTPException(status_code=400, detail="Description is required")
        
        # Procesar con IA
        analysis = text_processor.process(description)
        
        # Generar template
        template_id = f"ai-template-{uuid.uuid4().hex[:8]}"
        template_data = template_generator.generate_from_analysis(analysis, template_id, project_name)
        
        # Guardar en base de datos
        save_analysis(db, "text", description, analysis, template_id)
        
        # Subir a GitHub (si está configurado)
        repo_url = None
        try:
            repo_url = git_client.create_template_repository(template_id, template_data)
        except Exception as e:
            print(f"Warning: Could not create GitHub repository: {e}")
        
        return ScaffolderOutput(
            templateId=template_id,
            repositoryUrl=repo_url,
            catalogEntityRef=f"template:default/{template_id}"
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/scaffolder/actions/ai-analyze-image", response_model=ScaffolderOutput)
async def process_image(image: UploadFile = File(...), db: Session = Depends(get_db)):
    """Procesa imagen de arquitectura y genera template de Backstage"""
    try:
        # Guardar imagen temporalmente
        with tempfile.NamedTemporaryFile(delete=False, suffix='.png') as tmp:
            content = await image.read()
            tmp.write(content)
            tmp_path = tmp.name
        
        try:
            # Procesar con Gemini Vision para extraer servicios AWS
            analysis_result = vision.analyze_architecture_for_template(tmp_path)
            
            if not analysis_result or not analysis_result.get('services'):
                save_analysis(db, 'image', image.filename, '', 
                             status='error', error_message='No AWS services detected in image')
                return {"status": "error", "message": "No se detectaron servicios AWS en la imagen"}
            
            # Generar template específico basado en los servicios detectados
            template_name = f"aws-{analysis_result['solution_type']}-{hash(image.filename) % 1000}"
            template_data = {
                "template_name": template_name,
                "template_title": analysis_result['title'],
                "template_description": analysis_result['description'],
                "technology": "aws",
                "component_type": analysis_result['component_type'],
                "tags": analysis_result['tags'],
                "owner": "group:default/developers",
                "parameters": analysis_result['parameters'],
                "aws_services": analysis_result['services']
            }
            
            # Crear template completo
            template_files = template_generator.generate_aws_template(template_data)
            github_url = git_client.save_template(template_name, template_files)
            
            # Guardar en base de datos
            analysis = save_analysis(db, 'image', image.filename, json.dumps(template_data), 
                                    github_url, f"templates/{template_name}/template.yaml")
            
            return {
                "status": "success",
                "template_name": template_name,
                "template_title": analysis_result['title'],
                "aws_services": analysis_result['services'],
                "github_url": github_url,
                "backstage_url": f"http://localhost:3000/create",
                "type": "image",
                "analysis_id": analysis.id,
                "message": f"Template AWS '{analysis_result['title']}' creado y disponible en Backstage"
            }
        finally:
            # Limpiar archivo temporal
            os.unlink(tmp_path)
            
    except Exception as e:
        # Guardar error en DB
        save_analysis(db, 'image', image.filename if image else 'unknown', '', 
                     status='error', error_message=str(e))
        return {"status": "error", "message": str(e)}

@app.post("/configure-github")
async def configure_github(
    repository_url: str = Form(...), 
    branch: str = Form("main"),
    github_token: str = Form(None),
    db: Session = Depends(get_db)
):
    """Configurar repositorio de GitHub"""
    try:
        # Hash del token para seguridad (si se proporciona)
        token_hash = None
        if github_token:
            import hashlib
            token_hash = hashlib.sha256(github_token.encode()).hexdigest()
            
            # Actualizar variable de entorno temporalmente
            os.environ['GITHUB_TOKEN'] = github_token
        
        # Guardar configuración en base de datos
        config = save_github_config(db, repository_url, branch, token_hash)
        
        return {
            "status": "success",
            "message": "Configuración de GitHub guardada correctamente",
            "config_id": config.id,
            "repository_url": repository_url,
            "branch": branch,
            "token_configured": bool(github_token)
        }
    except Exception as e:
        return {"status": "error", "message": str(e)}

@app.get("/history")
async def get_history(db: Session = Depends(get_db)):
    """Obtener historial de análisis"""
    try:
        analyses = get_recent_analyses(db, limit=10)
        return {
            "status": "success",
            "count": len(analyses),
            "analyses": [
                {
                    "id": a.id,
                    "type": a.input_type,
                    "content": a.input_content[:100] + "..." if len(a.input_content) > 100 else a.input_content,
                    "status": a.status,
                    "created_at": a.created_at.isoformat(),
                    "github_url": a.github_url
                }
                for a in analyses
            ]
        }
    except Exception as e:
        return {"status": "error", "message": str(e)}

@app.get("/", response_class=HTMLResponse)
async def read_root():
    """Servir la página principal"""
    with open("static/index.html", "r", encoding="utf-8") as f:
        return HTMLResponse(content=f.read())

@app.post("/process-diagram")
async def process_diagram(file: UploadFile = File(...), db: Session = Depends(get_db)):
    """Procesa un diagrama PNG y genera YAML para Backstage"""
    with tempfile.NamedTemporaryFile(delete=False, suffix='.png') as tmp:
        content = await file.read()
        tmp.write(content)
        tmp_path = tmp.name
    
    try:
        # Procesar con Gemini Vision
        yaml_content = vision.analyze_diagram(tmp_path)
        
        # Validar YAML
        if not validator.validate_yaml(yaml_content):
            # Guardar error en DB
            save_analysis(db, 'image', file.filename, '', 
                         status='error', error_message='Generated YAML is invalid')
            return {"status": "error", "message": "Generated YAML is invalid"}
        
        # Guardar en GitHub
        filename = file.filename.replace('.png', '.yaml')
        github_url = git_client.save_yaml(filename, yaml_content)
        
        # Guardar en base de datos
        analysis = save_analysis(db, 'image', file.filename, yaml_content, 
                                github_url, filename)
        
        return {
            "status": "success",
            "yaml_content": yaml_content,
            "github_url": github_url,
            "type": "diagram",
            "analysis_id": analysis.id
        }
    except Exception as e:
        # Guardar error en DB
        save_analysis(db, 'image', file.filename, '', 
                     status='error', error_message=str(e))
        return {"status": "error", "message": str(e)}
    finally:
        os.unlink(tmp_path)

@app.post("/process-text")
async def process_text(description: str = Form(...), db: Session = Depends(get_db)):
    """Procesa descripción de texto y genera template de Backstage"""
    try:
        # Procesar con Gemini Text para extraer servicios AWS
        analysis_result = text_processor.analyze_text_for_template(description)
        
        if not analysis_result or not analysis_result.get('services'):
            save_analysis(db, 'text', description, '', 
                         status='error', error_message='No AWS services detected in description')
            return {"status": "error", "message": "No se detectaron servicios AWS en la descripción"}
        
        # Generar template específico basado en los servicios detectados
        solution_type = analysis_result.get('solution_type', 'web-app')
        template_name = f"aws-{solution_type}-{hash(description) % 1000}"
        
        template_data = {
            "template_name": template_name,
            "template_title": analysis_result.get('title', 'AWS Application'),
            "template_description": analysis_result.get('description', description[:200]),
            "technology": "aws",
            "component_type": analysis_result.get('component_type', 'service'),
            "tags": analysis_result.get('tags', ['aws']),
            "owner": "group:default/developers",
            "parameters": analysis_result.get('parameters', []),
            "aws_services": analysis_result.get('services', [])
        }
        
        # Crear template completo
        template_files = template_generator.generate_aws_template(template_data)
        github_url = git_client.save_template(template_name, template_files)
        
        # Guardar en base de datos
        analysis = save_analysis(db, 'text', description, json.dumps(template_data), 
                                github_url, f"templates/{template_name}/template.yaml")
        
        return {
            "status": "success",
            "template_name": template_name,
            "template_title": analysis_result.get('title', 'AWS Application'),
            "aws_services": analysis_result.get('services', []),
            "github_url": github_url,
            "backstage_url": f"http://localhost:3000/create",
            "type": "text",
            "analysis_id": analysis.id,
            "message": f"Template AWS '{analysis_result.get('title', 'AWS Application')}' creado y disponible en Backstage"
        }
    except Exception as e:
        # Guardar error en DB
        save_analysis(db, 'text', description, '', 
                     status='error', error_message=str(e))
        return {"status": "error", "message": str(e)}

@app.post("/config/github")
async def save_github_configuration(
    repository_url: str = Form(...),
    branch: str = Form(default='main'),
    token: str = Form(...),
    db: Session = Depends(get_db)
):
    """Guardar configuración de GitHub"""
    try:
        # Hash del token por seguridad
        token_hash = hashlib.sha256(token.encode()).hexdigest()
        
        # Guardar configuración
        config = save_github_config(db, repository_url, branch, token_hash)
        
        return {
            "status": "success",
            "message": "Configuración de GitHub guardada",
            "config_id": config.id
        }
    except Exception as e:
        return {"status": "error", "message": str(e)}

@app.get("/api/analyses")
async def get_analyses(limit: int = 10, db: Session = Depends(get_db)):
    """Obtener análisis recientes"""
    try:
        analyses = get_recent_analyses(db, limit)
        return {
            "status": "success",
            "analyses": [
                {
                    "id": a.id,
                    "input_type": a.input_type,
                    "input_content": a.input_content[:100] + "..." if len(a.input_content) > 100 else a.input_content,
                    "filename": a.filename,
                    "github_url": a.github_url,
                    "status": a.status,
                    "created_at": a.created_at.isoformat(),
                    "processed_successfully": a.processed_successfully
                }
                for a in analyses
            ]
        }
    except Exception as e:
        return {"status": "error", "message": str(e)}

@app.get("/api/config/github")
async def get_github_configuration(db: Session = Depends(get_db)):
    """Obtener configuración activa de GitHub"""
    try:
        config = get_active_github_config(db)
        if config:
            return {
                "status": "success",
                "config": {
                    "repository_url": config.repository_url,
                    "branch": config.branch,
                    "created_at": config.created_at.isoformat()
                }
            }
        else:
            return {"status": "error", "message": "No hay configuración activa"}
    except Exception as e:
        return {"status": "error", "message": str(e)}

@app.get("/debug/minio")
async def debug_minio():
    """Debug endpoint para verificar estado de MinIO"""
    try:
        return {
            "git_client_use_minio": git_client.use_minio,
            "git_client_minio_client": git_client.minio_client is not None,
            "minio_test": "Probando conexión directa..."
        }
    except Exception as e:
        return {"error": str(e)}

@app.post("/create-template")
async def create_template(template_data: TemplateRequest, db: Session = Depends(get_db)):
    """Crear un template de Backstage personalizado"""
    try:
        # Generar template completo
        template_files = template_generator.generate_template(
            name=template_data.template_name,
            title=template_data.template_title,
            description=template_data.template_description,
            technology=template_data.technology,
            component_type=template_data.component_type,
            tags=template_data.tags.split(',') if template_data.tags else [],
            owner=template_data.owner,
            parameters=[param.dict() for param in template_data.parameters]
        )
        
        # Subir template a GitHub
        github_url = git_client.save_template(template_data.template_name, template_files)
        
        # Guardar en base de datos
        analysis = save_analysis(
            db, 
            'template', 
            template_data.template_name, 
            json.dumps(template_files), 
            github_url, 
            f"templates/{template_data.template_name}/template.yaml"
        )
        
        return {
            "status": "success",
            "template_name": template_data.template_name,
            "template_id": analysis.id,
            "github_url": github_url,
            "backstage_url": f"http://localhost:3000/create",
            "message": f"Template '{template_data.template_title}' creado y disponible en Backstage"
        }
        
    except Exception as e:
        # Guardar error en DB
        save_analysis(db, 'template', template_data.template_name, '', 
                     status='error', error_message=str(e))
        return {"status": "error", "message": str(e)}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "version": "1.0.0"}

@app.get("/api/services/status")
async def services_status():
    """Verificar estado de todos los servicios"""
    import requests
    
    services = {
        "ai_agent": {"status": "healthy", "port": 8000},
        "postgresql": {"status": "unknown", "port": 5432},
        "backstage_ui": {"status": "unknown", "port": 3000},
        "backstage_api": {"status": "unknown", "port": 7007}
    }
    
    # Verificar PostgreSQL a través de la conexión de la DB
    try:
        # Intentar obtener análisis recientes como prueba de conexión
        db = SessionLocal()
        db.query("SELECT 1").first()
        services["postgresql"]["status"] = "healthy"
        db.close()
    except Exception as e:
        # Si falla, intentar verificación básica
        try:
            import psycopg2
            conn = psycopg2.connect(
                host=os.getenv('POSTGRES_HOST', 'localhost'),
                port=os.getenv('POSTGRES_PORT', '5432'),
                user=os.getenv('POSTGRES_USER', 'backstage'),
                password=os.getenv('POSTGRES_PASSWORD', 'backstage'),
                database=os.getenv('POSTGRES_DB', 'backstage')
            )
            conn.close()
            services["postgresql"]["status"] = "healthy"
        except Exception:
            services["postgresql"]["status"] = "error"
    
    # Verificar Backstage UI
    try:
        response = requests.get("http://localhost:3000", timeout=5)
        services["backstage_ui"]["status"] = "healthy" if response.status_code == 200 else "error"
    except Exception:
        services["backstage_ui"]["status"] = "error"
    
    # Verificar Backstage API
    try:
        response = requests.get("http://localhost:7007", timeout=5)
        # 404 es normal para Backstage API root
        services["backstage_api"]["status"] = "healthy" if response.status_code in [200, 404] else "error"
    except Exception:
        services["backstage_api"]["status"] = "error"
    
    return {"status": "success", "services": services}

@app.post("/process-image")
async def process_image_endpoint(image: UploadFile = File(...), db: Session = Depends(get_db)):
    """Endpoint para procesar imagen desde el frontend"""
    try:
        # Guardar imagen temporalmente
        with tempfile.NamedTemporaryFile(delete=False, suffix=".png") as tmp_file:
            content = await image.read()
            tmp_file.write(content)
            tmp_path = tmp_file.name
        
        try:
            # Procesar imagen con IA
            analysis_result = vision.process_image(tmp_path)
            
            # Generar nombre único para el template
            template_name = f"aws-image-app-{hashlib.md5(content).hexdigest()[:8]}"
            
            # Crear datos del template
            template_data = {
                "template_name": template_name,
                "template_title": analysis_result.get('title', 'AWS Application'),
                "services": analysis_result.get('services', []),
                "architecture_type": analysis_result.get('architecture_type', 'web-app'),
                "description": analysis_result.get('description', 'Aplicación AWS generada desde imagen')
            }
            
            # Generar template completo
            template_files = template_generator.generate_aws_template(template_data)
            github_url = git_client.save_template(template_name, template_files)
            
            # Guardar análisis en DB
            analysis = save_analysis(
                db, 'image', image.filename or 'uploaded_image.png', 
                json.dumps(analysis_result), template_name, 
                status='completed'
            )
            
            return {
                "status": "success",
                "analysis_id": analysis.id,
                "project_name": template_name,
                "template_name": template_name,
                "template_title": analysis_result.get('title', 'AWS Application'),
                "aws_services": analysis_result.get('services', []),
                "github_url": github_url,
                "backstage_url": f"http://localhost:3000/create",
                "backstage_discovery": f"Servicios AWS detectados: {', '.join(analysis_result.get('services', []))}",
                "yaml_content": template_files.get('template.yaml', '# Template generado'),
                "type": "image",
                "message": f"Template AWS '{analysis_result.get('title', 'AWS Application')}' creado y disponible en Backstage"
            }
            
        finally:
            # Limpiar archivo temporal
            os.unlink(tmp_path)
            
    except Exception as e:
        # Guardar error en DB
        save_analysis(db, 'image', image.filename if image else 'unknown', '', 
                     status='error', error_message=str(e))
        return {"status": "error", "message": str(e)}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)
