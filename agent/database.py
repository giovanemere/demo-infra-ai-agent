from sqlalchemy import create_engine, Column, Integer, String, Text, DateTime, Boolean
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from datetime import datetime
import os

# Configuración de base de datos
DATABASE_URL = f"postgresql://{os.getenv('POSTGRES_USER', 'backstage')}:{os.getenv('POSTGRES_PASSWORD', 'backstage123')}@{os.getenv('POSTGRES_HOST', 'localhost')}:{os.getenv('POSTGRES_PORT', '5432')}/{os.getenv('POSTGRES_DB', 'backstage')}"

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

class ArchitectureAnalysis(Base):
    __tablename__ = "architecture_analyses"
    
    id = Column(Integer, primary_key=True, index=True)
    input_type = Column(String(50), nullable=False)  # 'text' or 'image'
    input_content = Column(Text, nullable=False)  # descripción o nombre de archivo
    yaml_content = Column(Text, nullable=False)
    github_url = Column(String(500))
    filename = Column(String(200))
    status = Column(String(50), default='success')
    error_message = Column(Text)
    created_at = Column(DateTime, default=datetime.utcnow)
    processed_successfully = Column(Boolean, default=True)

class GitHubConfig(Base):
    __tablename__ = "github_configs"
    
    id = Column(Integer, primary_key=True, index=True)
    repository_url = Column(String(500), nullable=False)
    branch = Column(String(100), default='main')
    token_hash = Column(String(200))  # Hash del token por seguridad
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow)

# Crear tablas
def create_tables():
    Base.metadata.create_all(bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Funciones de utilidad
def save_analysis(db, input_type: str, input_content: str, yaml_content: str, 
                 github_url: str = None, filename: str = None, 
                 status: str = 'success', error_message: str = None):
    """Guardar análisis en la base de datos"""
    analysis = ArchitectureAnalysis(
        input_type=input_type,
        input_content=input_content,
        yaml_content=yaml_content,
        github_url=github_url,
        filename=filename,
        status=status,
        error_message=error_message,
        processed_successfully=(status == 'success')
    )
    db.add(analysis)
    db.commit()
    db.refresh(analysis)
    return analysis

def get_recent_analyses(db, limit: int = 10):
    """Obtener análisis recientes"""
    return db.query(ArchitectureAnalysis).order_by(
        ArchitectureAnalysis.created_at.desc()
    ).limit(limit).all()

def save_github_config(db, repository_url: str, branch: str = 'main', token_hash: str = None):
    """Guardar configuración de GitHub"""
    # Desactivar configuraciones anteriores
    db.query(GitHubConfig).update({GitHubConfig.is_active: False})
    
    config = GitHubConfig(
        repository_url=repository_url,
        branch=branch,
        token_hash=token_hash,
        is_active=True
    )
    db.add(config)
    db.commit()
    db.refresh(config)
    return config

def get_active_github_config(db):
    """Obtener configuración activa de GitHub"""
    return db.query(GitHubConfig).filter(GitHubConfig.is_active == True).first()
