# API Reference

## Endpoints

### POST /process-text
Process infrastructure description text.

**Request Body:**
```json
{
  "description": "Web application with S3, CloudFront and Lambda"
}
```

**Response:**
```json
{
  "status": "success",
  "yaml_content": "apiVersion: backstage.io/v1alpha1...",
  "project_id": "ai-project-1234",
  "github_url": "https://github.com/..."
}
```

### POST /process-image
Process infrastructure diagram image.

**Request:**
- Multipart form data with image file

**Response:**
```json
{
  "status": "success", 
  "yaml_content": "apiVersion: backstage.io/v1alpha1...",
  "project_id": "ai-image-project-5678",
  "github_url": "https://github.com/..."
}
```

### GET /health
Health check endpoint.

**Response:**
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "timestamp": "2026-01-19T15:00:00Z"
}
```

### GET /docs
Interactive API documentation (Swagger UI).

## Error Responses

All endpoints may return error responses:

```json
{
  "status": "error",
  "message": "Description of the error",
  "code": "ERROR_CODE"
}
```

## Rate Limiting

- 100 requests per minute per IP
- 10 concurrent requests per IP
