# Plan de Corrección: Sistema de Templates y API Gemini

**Fecha:** 3 de Enero de 2026  
**Estado:** En Ejecución

---

## 🎯 Resumen Ejecutivo

Dos problemas críticos están afectando la experiencia de onboarding:

1. **Templates Faltantes**: El fingerprint `404862177` (y potencialmente otros) no existe en assets
2. **Gemini API Error**: Modelo "gemini-1.5-flash" no disponible en API v1beta

**Impacto**: Los usuarios no pueden completar onboarding exitosamente.

---

## 🔍 PROBLEMA 1: Templates Faltantes

### Diagnóstico

**Error en Log:**
```
Template not found for fingerprint: 404862177
```

**Causa Raíz:**
- Sistema genera fingerprint desde perfil: `${intent}_${maturity}_${motivations}_${challenge}`
- Solo 59 templates existen en `assets/habit_templates_v2/`
- Template matrix actual: 60 combinaciones estratégicas
- **Gap**: Perfil del usuario produce fingerprint no cubierto

**Perfil que falló:**
```dart
{
  "intent": "wellness",
  "motivations": ["physicalHealth", "reduceStress", "betterSleep"],
  "challenge": "lackOfMotivation",
  "supportLevel": "weak"
}
```

**Fingerprint generado:** `wellness__physicalHealth_reduceStress_betterSleep_lackOfMotivation`
- Hashcode Dart: `404862177`

### Solución

#### Opción A: Cobertura Total (Recomendado para Corto Plazo)
Generar templates para TODAS las combinaciones realistas:

**Dimensiones:**
- Intents: 3 (faithBased, wellness, both)
- Motivations: ~20 combinaciones comunes por intent
- Challenges: 6 (lackOfTime, lackOfMotivation, givingUp, dontKnowStart, stressAnxiety, burnout)
- Support Levels: 3 (weak, normal, strong)
- Maturity Levels: 5 (null, new, growing, mature, passionate)

**Estimado:** ~300-400 templates (2-3 MB adicionales en APK)

#### Opción B: Template Scoring + Fallback (Recomendado para Largo Plazo)
1. Mantener ~150 templates estratégicos
2. Implementar `TemplateScoringEngine` para encontrar template más cercano (threshold ≥0.75)
3. Si score < 0.75, usar generación dinámica desde catálogo sin AI

### Plan de Implementación

**Fase 1: Fix Inmediato (Hoy)**
1. Analizar fingerprints más comunes en producción/logs
2. Generar los 10-20 templates más solicitados
3. Desplegar versión parche

**Fase 2: Cobertura Expandida (Esta Semana)**
1. Expandir TEMPLATE_MATRIX a ~150 combinaciones
2. Regenerar todos los templates
3. Validar fingerprints con `verify_fingerprints.py`

**Fase 3: Sistema Robusto (Próxima Semana)**
1. Implementar TemplateScoringEngine en runtime
2. Agregar fallback con selector de catálogo
3. Logging de fingerprints faltantes para futuras iteraciones

---

## 🔍 PROBLEMA 2: Error de API Gemini

### Diagnóstico

**Error en Log:**
```
models/gemini-1.5-flash is not found for API version v1beta, 
or is not supported for generateContent
```

**Configuración Actual:**
- Package: `google_generative_ai: ^0.4.0`
- Modelo: `gemini-1.5-flash`
- API Key: ✅ Válido (AIzaSy...)

**Causa Probable:**
La versión 0.4.0 del paquete puede:
1. Usar un endpoint de API diferente
2. Requerir nombre de modelo diferente
3. Tener bug con ciertos modelos

### Investigación Necesaria

**Modelo Correcto según Versión:**
```dart
// Posibles variantes a probar:
- gemini-1.5-flash-latest
- gemini-1.5-flash-001
- gemini-1.5-pro
- gemini-pro (legacy)
```

**Documentación Oficial:**
- https://ai.google.dev/gemini-api/docs/models/gemini
- Package changelog: https://pub.dev/packages/google_generative_ai/changelog

### Solución

#### Paso 1: Diagnosticar Modelo Correcto
```bash
# Ejecutar script de diagnóstico
export GEMINI_API_KEY="AIzaSyCkB-YYzW7v69CAyYsrviqoQ07B19c_6uM"
cd /home/develop4god/Projects/habitus_faith
dart scripts/diagnose_gemini.dart
```

#### Paso 2: Actualizar Configuración
Una vez identificado el modelo correcto, actualizar:
```dart
// lib/core/config/ai_config.dart
static const String defaultModel = 'gemini-1.5-flash-latest'; // O el que funcione
```

#### Paso 3: Considerar Upgrade de Package
```yaml
# pubspec.yaml
google_generative_ai: ^0.4.6  # Última versión estable
```

#### Paso 4: Agregar Manejo de Errores Robusto
```dart
// gemini_service.dart
try {
  final response = await _model.generateContent(...);
} on GenerativeAIException catch (e) {
  if (e.message.contains('not found')) {
    _logger.e('Model not available. Check configuration.');
    // Fallback to catalog-based generation
    return _generateFromCatalog(profile);
  }
  rethrow;
}
```

---

## 📋 PLAN DE ACCIÓN COMPLETO

### Día 1 (Hoy - 3 Enero 2026)

- [x] Crear diagnóstico completo
- [ ] Ejecutar `diagnose_gemini.dart` para identificar modelo correcto
- [ ] Generar template para fingerprint `404862177`
- [ ] Actualizar configuración de Gemini si es necesario
- [ ] Test de onboarding end-to-end

### Día 2-3 (4-5 Enero)

- [ ] Expandir TEMPLATE_MATRIX a 150 combinaciones estratégicas
- [ ] Regenerar todos los templates
- [ ] Implementar TemplateScoringEngine en runtime
- [ ] Agregar logging de fingerprints faltantes

### Día 4-5 (6-7 Enero)

- [ ] Implementar fallback con catalog-based generation
- [ ] Agregar tests unitarios para scoring engine
- [ ] Agregar tests de integración para onboarding
- [ ] Documentar sistema de templates

### Semana 2 (8-12 Enero)

- [ ] Monitorear logs de producción para fingerprints faltantes
- [ ] Iterar generación de templates según uso real
- [ ] Optimizar tamaño de assets si es necesario
- [ ] Preparar release notes

---

## 🧪 Tests de Validación

### Test 1: Template Coverage
```bash
cd scripts
python3 test_integration.py --verify-coverage
```

### Test 2: Fingerprint Consistency
```bash
python3 verify_fingerprints.py
```

### Test 3: Gemini API
```bash
dart diagnose_gemini.dart
```

### Test 4: End-to-End Onboarding
```dart
flutter test integration_test/onboarding_test.dart
```

---

## 📊 Métricas de Éxito

- ✅ 0 errores de "Template not found" en onboarding
- ✅ <100ms de latencia en carga de templates
- ✅ Gemini API solo se usa para casos edge (<5% de usuarios)
- ✅ 100% de perfiles tienen template o fallback válido
- ✅ Tamaño de assets <5MB

---

## 🔗 Referencias

- [Template Scoring Engine](../lib/core/services/templates/template_scoring_engine.dart)
- [Template Loader](../lib/core/services/habit_template_loader.dart)
- [Gemini Service](../lib/core/services/ai/gemini_service.dart)
- [Onboarding Models](../lib/features/habits/presentation/onboarding/onboarding_models.dart)
- [Generate Templates Script](../scripts/generate_templates_v2.py)
- [Habit Catalog](../scripts/habit_catalog.py)

---

**Última Actualización:** 2026-01-03 18:30:00  
**Responsable:** AI Agent  
**Status:** 🟡 En Progreso

