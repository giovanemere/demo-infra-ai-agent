# Decisiones Técnicas

## Formato de Registro
**Fecha**: YYYY-MM-DD
**Contexto**: Situación que requiere decisión
**Decisión**: Qué se decidió hacer
**Alternativas**: Otras opciones consideradas
**Consecuencias**: Impacto esperado

---

## 2026-01-20: Estructura de Documentación AI
**Contexto**: Necesidad de mantener contexto entre sesiones de desarrollo
**Decisión**: Crear carpeta docs/ai/ con archivos estructurados (contexto.md, setup.md, comandos.md, decisiones.md, troubleshooting.md)
**Alternativas**: 
- Usar solo README.md
- Documentación en wiki externa
- Comentarios en código únicamente
**Consecuencias**: 
- ✅ Contexto preservado entre sesiones
- ✅ Conocimiento accesible para todo el equipo
- ✅ Historial de decisiones rastreable
- ❌ Requiere disciplina para mantener actualizado

## 2026-01-20: Eliminación de Tokens Hardcodeados
**Contexto**: GitHub bloqueó push por token expuesto en test-github-backstage.sh
**Decisión**: Migrar todos los tokens a variables de entorno desde .env
**Alternativas**:
- Usar GitHub Secrets
- Tokens temporales
- Configuración por archivo separado
**Consecuencias**:
- ✅ Mayor seguridad
- ✅ Cumple políticas de GitHub
- ✅ Configuración centralizada
- ❌ Requiere configuración manual del .env
