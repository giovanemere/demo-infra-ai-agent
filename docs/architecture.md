# Architecture

## System Overview

The Infrastructure AI Agent is built with a modular architecture:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   FastAPI       │    │   Gemini AI     │
│   (Static)      │───▶│   Backend       │───▶│   Processing    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   PostgreSQL    │◀───│   Validators    │───▶│   GitHub        │
│   Database      │    │   & Git Client  │    │   Repository    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Components

### 1. Frontend Interface
- Static HTML/JavaScript interface
- File upload for images
- Text input for descriptions
- Real-time processing status

### 2. FastAPI Backend
- RESTful API endpoints
- Async processing
- File handling
- Response validation

### 3. AI Processors
- **Text Processor**: Analyzes infrastructure descriptions
- **Vision Processor**: Processes architecture diagrams
- **Gemini Integration**: Google AI for analysis

### 4. Validators
- YAML syntax validation
- Backstage schema compliance
- Error correction and suggestions

### 5. Git Client
- Automatic repository synchronization
- Project organization
- Commit and push automation

## Data Flow

1. **Input**: User submits text/image
2. **Processing**: AI analyzes content
3. **Generation**: Creates Backstage YAML
4. **Validation**: Ensures compliance
5. **Storage**: Saves to GitHub repository
6. **Sync**: Backstage detects changes
