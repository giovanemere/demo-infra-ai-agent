# Configuration

## Environment Variables

### Required Variables

```bash
# Google Gemini API
GEMINI_API_KEY=your_gemini_api_key_here

# GitHub Integration  
GITHUB_TOKEN=your_github_token_here

# Database Configuration
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=backstage
POSTGRES_PASSWORD=your_password
POSTGRES_DB=backstage
```

### Optional Variables

```bash
# Repository Configuration
TEMPLATES_REPO=git@github.com:giovanemere/demo-infra-ai-agent-template-idp.git

# Server Configuration
HOST=0.0.0.0
PORT=8000
DEBUG=false
```

## Setup Instructions

1. **Clone repository**:
   ```bash
   git clone git@github.com:giovanemere/demo-infra-ai-agent.git
   cd demo-infra-ai-agent
   ```

2. **Setup environment**:
   ```bash
   ./setup.sh
   ```

3. **Configure API keys**:
   ```bash
   cp .env.example .env
   # Edit .env with your API keys
   ```

4. **Start service**:
   ```bash
   ./start.sh
   ```

## Database Setup

The AI Agent uses PostgreSQL for storing processing history and metadata.

### Schema
- `processing_history` - Record of all AI processing requests
- `project_metadata` - Generated project information
- `validation_results` - YAML validation results

## GitHub Integration

### Repository Structure
The AI Agent creates projects in this structure:
```
projects/
├── ai-project-1234/
│   ├── catalog-info.yaml
│   ├── README.md
│   └── docs/
└── ai-image-project-5678/
    ├── catalog-info.yaml
    ├── README.md
    └── docs/
```

### Permissions Required
- Repository read/write access
- Contents permission
- Metadata permission
