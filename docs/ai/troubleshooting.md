# Troubleshooting

## Formato de Registro
**Síntoma**: Qué error o problema se observa
**Causa Probable**: Diagnóstico del problema
**Solución**: Pasos para resolver
**Prevención**: Cómo evitar en el futuro

---

## GitHub Push Bloqueado por Token Expuesto
**Síntoma**: Error "GH013: Repository rule violations found" al hacer git push
**Causa Probable**: Token hardcodeado detectado en archivos del commit
**Solución**:
```bash
# 1. Identificar archivo problemático (GitHub indica la ruta)
# 2. Reemplazar token hardcodeado con variable de entorno
# 3. Hacer nuevo commit
git add archivo_corregido.sh
git commit --amend -m "fix: remove hardcoded token"
# 4. Recrear tag si es necesario
git tag -d v1.x.x
git tag -a v1.x.x -m "Version corregida"
# 5. Push nuevamente
git push origin master
git push origin v1.x.x
```
**Prevención**: 
- Usar siempre variables de entorno para credenciales
- Revisar archivos antes del commit
- Configurar pre-commit hooks

## Servicios No Inician Correctamente
**Síntoma**: Error al ejecutar ./start-platform.sh
**Causa Probable**: Variables de entorno faltantes o puertos ocupados
**Solución**:
```bash
# 1. Verificar .env existe y tiene todas las variables
./manage-env-configs.sh validate

# 2. Verificar puertos libres
netstat -tulpn | grep -E ':(8000|3000|7007|5432)'

# 3. Detener servicios conflictivos
./stop-platform.sh
docker-compose down

# 4. Reiniciar
./start-platform.sh
```
**Prevención**:
- Validar configuración antes de iniciar
- Usar script de verificación de prerequisitos
