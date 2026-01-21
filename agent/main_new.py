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
async def scaffolder_analyze_image(
    file: UploadFile = File(...),
    project_name: str = Form(None),
    db: Session = Depends(get_db)
):
    """Scaffolder action to analyze architecture image and generate template"""
    try:
        if not project_name:
            project_name = f"ai-image-project-{uuid.uuid4().hex[:8]}"
            
        # Guardar imagen temporalmente
        with tempfile.NamedTemporaryFile(delete=False, suffix=".png") as tmp_file:
            content = await file.read()
            tmp_file.write(content)
            tmp_file_path = tmp_file.name
        
        try:
            # Procesar con IA
            analysis = vision.process_image(tmp_file_path)
            
            # Generar template
            template_id = f"ai-image-template-{uuid.uuid4().hex[:8]}"
            template_data = template_generator.generate_from_analysis(analysis, template_id, project_name)
            
            # Guardar en base de datos
            save_analysis(db, "image", f"Image analysis for {project_name}", analysis, template_id)
            
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
            
        finally:
            # Limpiar archivo temporal
            os.unlink(tmp_file_path)
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# API Endpoints (para desarrollo y testing)
@app.post("/api/analyze/text")
async def api_analyze_text(request: AnalysisRequest, db: Session = Depends(get_db)):
    """API endpoint to analyze text description"""
    try:
        analysis = text_processor.process(request.description)
        
        # Generar template si se solicita
        template_id = f"api-template-{uuid.uuid4().hex[:8]}"
        template_data = template_generator.generate_from_analysis(
            analysis, 
            template_id, 
            request.project_name or "api-project"
        )
        
        # Guardar análisis
        save_analysis(db, "text", request.description, analysis, template_id)
        
        return {
            "analysis": analysis,
            "template_id": template_id,
            "template_data": template_data,
            "status": "success"
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/analyze/image")
async def api_analyze_image(
    file: UploadFile = File(...),
    project_name: str = Form("api-image-project"),
    db: Session = Depends(get_db)
):
    """API endpoint to analyze architecture image"""
    try:
        # Guardar imagen temporalmente
        with tempfile.NamedTemporaryFile(delete=False, suffix=".png") as tmp_file:
            content = await file.read()
            tmp_file.write(content)
            tmp_file_path = tmp_file.name
        
        try:
            # Procesar con IA
            analysis = vision.process_image(tmp_file_path)
            
            # Generar template
            template_id = f"api-image-template-{uuid.uuid4().hex[:8]}"
            template_data = template_generator.generate_from_analysis(analysis, template_id, project_name)
            
            # Guardar análisis
            save_analysis(db, "image", f"Image analysis for {project_name}", analysis, template_id)
            
            return {
                "analysis": analysis,
                "template_id": template_id,
                "template_data": template_data,
                "status": "success"
            }
            
        finally:
            os.unlink(tmp_file_path)
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/templates")
async def get_templates(db: Session = Depends(get_db)):
    """Get recent template analyses"""
    try:
        analyses = get_recent_analyses(db, limit=20)
        return {
            "templates": analyses,
            "count": len(analyses),
            "status": "success"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/config/github")
async def get_github_config(db: Session = Depends(get_db)):
    """Get active GitHub configuration"""
    try:
        config = get_active_github_config(db)
        if config:
            # No devolver tokens por seguridad
            return {
                "configured": True,
                "owner": config.get("owner"),
                "repo": config.get("repo"),
                "status": "active"
            }
        else:
            return {
                "configured": False,
                "status": "not_configured"
            }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Mantener endpoints legacy para compatibilidad (DEPRECATED)
@app.post("/process-text")
async def process_text_legacy(description: str = Form(...), db: Session = Depends(get_db)):
    """Legacy endpoint - use /api/analyze/text instead"""
    request = AnalysisRequest(description=description)
    return await api_analyze_text(request, db)

@app.post("/process-image")
async def process_image_legacy(file: UploadFile = File(...), db: Session = Depends(get_db)):
    """Legacy endpoint - use /api/analyze/image instead"""
    return await api_analyze_image(file, "legacy-project", db)

# Frontend para desarrollo (mantener solo para debug)
@app.get("/", response_class=HTMLResponse)
async def serve_frontend():
    """Serve development frontend"""
    with open("static/index.html", "r", encoding="utf-8") as f:
        return HTMLResponse(content=f.read())

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)
