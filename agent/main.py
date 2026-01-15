from fastapi import FastAPI, UploadFile, File, Form
from agent.processors.vision import VisionProcessor
from agent.processors.text import TextProcessor
from agent.validators.backstage import BackstageValidator
from agent.git_client import GitClient
import tempfile
import os

app = FastAPI(title="Infra AI Agent", version="1.0.0")

# Inicializar componentes
vision = VisionProcessor()
text_processor = TextProcessor()
validator = BackstageValidator()
git_client = GitClient()

@app.post("/process-diagram")
async def process_diagram(file: UploadFile = File(...)):
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
            return {"status": "error", "message": "Generated YAML is invalid"}
        
        # Guardar en GitHub
        filename = file.filename.replace('.png', '.yaml')
        github_url = git_client.save_yaml(filename, yaml_content)
        
        return {
            "status": "success",
            "yaml_content": yaml_content,
            "github_url": github_url,
            "type": "diagram"
        }
    except Exception as e:
        return {"status": "error", "message": str(e)}
    finally:
        os.unlink(tmp_path)

@app.post("/process-text")
async def process_text(description: str = Form(...)):
    """Procesa descripción de texto y genera YAML para Backstage"""
    try:
        # Procesar con Gemini Text
        yaml_content = text_processor.analyze_text(description)
        
        # Validar YAML
        if not validator.validate_yaml(yaml_content):
            return {"status": "error", "message": "Generated YAML is invalid"}
        
        # Guardar en GitHub
        filename = f"text-architecture-{hash(description) % 10000}.yaml"
        github_url = git_client.save_yaml(filename, yaml_content)
        
        return {
            "status": "success",
            "yaml_content": yaml_content,
            "github_url": github_url,
            "type": "text"
        }
    except Exception as e:
        return {"status": "error", "message": str(e)}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "version": "1.0.0"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
