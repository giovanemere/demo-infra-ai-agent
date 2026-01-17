from fastapi import FastAPI, UploadFile, File, Form, Depends
from fastapi.staticfiles import StaticFiles
from fastapi.responses import HTMLResponse, JSONResponse
from sqlalchemy.orm import Session
from processors.vision import VisionProcessor
from processors.text import TextProcessor
from validators.backstage import BackstageValidator
from git_client import GitClient
from database import create_tables, get_db, save_analysis, get_recent_analyses, save_github_config, get_active_github_config
import tempfile
import os
import hashlib

app = FastAPI(title="Infra AI Agent", version="1.0.0")

# Crear tablas al iniciar
create_tables()

# Servir archivos estáticos
app.mount("/static", StaticFiles(directory="static"), name="static")

# Inicializar componentes
vision = VisionProcessor()
text_processor = TextProcessor()
validator = BackstageValidator()
git_client = GitClient()

@app.post("/process-image")
async def process_image(image: UploadFile = File(...), db: Session = Depends(get_db)):
    """Procesa imagen de arquitectura y genera YAML para Backstage"""
    try:
        # Guardar imagen temporalmente
        with tempfile.NamedTemporaryFile(delete=False, suffix='.png') as tmp:
            content = await image.read()
            tmp.write(content)
            tmp_path = tmp.name
        
        try:
            # Procesar con Gemini Vision
            yaml_content = vision.analyze_diagram(tmp_path)
            
            # Validación básica
            if not yaml_content or len(yaml_content.strip()) < 10:
                save_analysis(db, 'image', image.filename, '', 
                             status='error', error_message='Generated YAML is empty or too short')
                return {"status": "error", "message": "Generated YAML is empty or too short"}
            
            # Generar nombre de proyecto basado en la imagen
            project_name = f"ai-image-project-{hash(image.filename) % 10000}"
            
            # Crear estructura completa del proyecto
            github_url = git_client.save_project(project_name, yaml_content, f"Análisis de imagen: {image.filename}")
            
            # Guardar en base de datos
            analysis = save_analysis(db, 'image', image.filename, yaml_content, 
                                    github_url, f"{project_name}/catalog-info.yaml")
            
            return {
                "status": "success",
                "yaml_content": yaml_content,
                "github_url": github_url,
                "project_name": project_name,
                "type": "image",
                "analysis_id": analysis.id,
                "backstage_discovery": f"Proyecto creado con estructura completa para auto-discovery en Backstage"
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
    """Procesa descripción de texto y genera YAML para Backstage"""
    try:
        # Procesar con Gemini Text
        yaml_content = text_processor.analyze_text(description)
        
        # Validación más flexible - solo verificar que no esté vacío
        if not yaml_content or len(yaml_content.strip()) < 10:
            # Guardar error en DB
            save_analysis(db, 'text', description, '', 
                         status='error', error_message='Generated YAML is empty or too short')
            return {"status": "error", "message": "Generated YAML is empty or too short"}
        
        # Generar nombre de proyecto basado en la descripción
        project_name = f"ai-project-{hash(description) % 10000}"
        
        # Crear estructura completa del proyecto
        github_url = git_client.save_project(project_name, yaml_content, description)
        
        # Guardar en base de datos
        analysis = save_analysis(db, 'text', description, yaml_content, 
                                github_url, f"{project_name}/catalog-info.yaml")
        
        return {
            "status": "success",
            "yaml_content": yaml_content,
            "github_url": github_url,
            "project_name": project_name,
            "type": "text",
            "analysis_id": analysis.id,
            "backstage_discovery": f"Proyecto creado con estructura completa para auto-discovery en Backstage"
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

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
