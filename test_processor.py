#!/usr/bin/env python3

import sys
import os
sys.path.append('/home/giovanemere/demos/infra-ai-agent/agent')

from processors.text import TextProcessor

# Probar el procesador de texto
processor = TextProcessor()
description = "Una aplicación web serverless con S3 para almacenamiento estático, CloudFront como CDN, Lambda para el backend API, y RDS MySQL para la base de datos."

try:
    result = processor.analyze_text_for_template(description)
    print("Resultado del análisis:")
    print(result)
except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()
