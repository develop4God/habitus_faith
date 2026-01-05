# 🔴 PROBLEMAS CRÍTICOS DETECTADOS + SOLUCIONES

**Fecha:** 3 de Enero 2026, 19:06  
**Basado en logs reales de producción**

---

## 🐛 PROBLEMAS DETECTADOS EN LOG

### 1. ❌ Template Faltante #2: Fingerprint `1070993398`
```
⚠️ Template not found for fingerprint: 1070993398
```

**Perfil:**
- Intent: `wellness`
- Motivations: `["timeManagement", "physicalHealth", "reduceStress"]`
- Challenge: `givingUp`
- Support: `weak`

**✅ Solución:** Agregado a matriz de templates expandida

---

### 2. ❌ Error en Scoring Engine: Templates con "faith" en vez de "faithBased"
```
[SCORING] Error scoring template faith_passionate_dontKnowStart_low_growInFaith_closerToGod: 
FormatException: Invalid intent "faith" in pattern ID. Valid values: faithBased, wellness, both
```

**Causa:** Templates externos (de GitHub) usan nomenclatura incorrecta

**✅ Solución:** El scoring engine ahora valida y salta templates inválidos. Los templates locales usan "faithBased" correcto.

---

### 3. ❌ TemplateFallbackService Error: AssetManifest.json no disponible
```
Error in findSimilarTemplate: Unable to load asset: "AssetManifest.json".
The asset does not exist or has empty data.
```

**Causa:** Flutter en versiones recientes usa `AssetManifest.bin` en vez de JSON

**✅ Solución:** Refactorizado TemplateFallbackService para:
- No depender de AssetManifest.json
- Temporalmente retornar lista vacía (fallback a Gemini)
- TODO: Generar manifest de fingerprints en build time

---

### 4. ❌ Gemini API: Modelo no encontrado (PERSISTE)
```
models/gemini-1.5-flash-latest is not found for API version v1beta
```

**Intentos:**
- ❌ `gemini-1.5-flash-latest` → No funciona
- ❌ `gemini-1.5-flash` → A probar
- ⚠️ Paquete `google_generative_ai: ^0.4.0` puede estar desactualizado

**✅ Soluciones Aplicadas:**
1. Revertido modelo a `gemini-1.5-flash` (sin -latest)
2. Actualizado paquete a `^0.4.6` (última versión estable)
3. Mejorado error handling para mensajes claros

**🔧 Plan B si sigue fallando:**
1. Probar `gemini-1.5-pro`
2. Probar `gemini-pro` (legacy)
3. Verificar permisos de API key en Google AI Studio
4. Considerar actualizar a `google_generative_ai: ^0.5.0+` cuando esté disponible

---

## ✅ CORRECCIONES IMPLEMENTADAS

### A. Scripts Python Actualizados

**1. generate_templates_v2.py**
- Wellness templates: 42 → 45 (agregados 3 más)
- Nuevo: `timeManagement + physicalHealth + reduceStress + givingUp + weak`
- Total estimado: ~125 templates

### B. Código Dart Actualizado

**1. template_fallback_service.dart**
- ✅ Removida dependencia de AssetManifest.json
- ✅ Agregado método `_getAvailableTemplateFingerprints()`  
- ✅ Graceful degradation cuando no hay lista de templates
- 🔜 TODO: Generar manifest en build time

**2. ai_config.dart**
- ✅ Revertido a `gemini-1.5-flash` (más compatible)
- ✅ Comentarios actualizados con alternativas

**3. env_config.dart**
- ✅ Default actualizado a match ai_config

**4. gemini_service.dart**
- ✅ Ya tiene error handling mejorado
- ✅ Detecta "not found" y "not supported"
- ✅ Mensajes claros al usuario

### C. Dependencias

**pubspec.yaml**
- ✅ Actualizado `google_generative_ai: ^0.4.6`

### D. Scripts de Deployment

**apply_all_fixes.sh**
- ✅ Agregado `flutter pub upgrade google_generative_ai`
- ✅ Regenera todos los templates
- ✅ Limpia y reconstruye

---

## 🧪 PLAN DE TESTING ACTUALIZADO

### Test 1: Regenerar Templates
```bash
cd /home/develop4god/Projects/habitus_faith/scripts
python3 generate_templates_v2.py --max 130
```

**Verificar:**
- [ ] Se generan ~125 templates
- [ ] Existe `1070993398.json`
- [ ] Todos validan correctamente

---

### Test 2: Verificar Gemini API (CRÍTICO)
```bash
export GEMINI_API_KEY="AIzaSyCkB-YYzW7v69CAyYsrviqoQ07B19c_6uM"
cd /home/develop4god/Projects/habitus_faith
dart scripts/diagnose_gemini.dart
```

**Esperado:**
```
✅ SUCCESS - Response: Hello
✅ This model works! Use: "gemini-1.5-flash"
```

**Si falla TODO:**
→ API key puede no tener acceso a Gemini 1.5
→ Verificar en https://aistudio.google.com/app/apikey
→ Probar con modelo legacy: `gemini-pro`

---

### Test 3: Build & Test Manual
```bash
flutter clean
flutter pub get
flutter run
```

**Escenario Crítico:**
1. Onboarding → Wellness
2. Motivations: Time Management, Physical Health, Reduce Stress
3. Challenge: Giving Up
4. Support: Weak
5. ✅ Debe cargar template `1070993398` instantáneamente

---

## 📊 ANÁLISIS DE LOGS

### Flujo Actual (del log)
```
1. [SCORING] Starting template matching ← Scoring engine externo (GitHub)
2. [SCORING] Error: Invalid intent "faith" ← Templates GitHub corruptos
3. [SCORING] No match found (best: 0.470) ← Score muy bajo
4. Template Loader: fingerprint 1070993398 ← Template no existe
5. [Template FALLBACK] Searching... ← Fallback service intenta
6. Error: AssetManifest.json not found ← Falla fallback
7. [Cache MISS] Calling Gemini API ← Último recurso
8. Gemini Error: model not found ← API falla
9. ⚠️ Usando fallback genérico ← Sistema degradado
10. 0 hábitos cargados ← FALLO TOTAL
```

### Flujo Ideal (después del fix)
```
1. Template Loader: fingerprint 1070993398 ✅
2. Template HIT: Exact match ✅
3. Hábitos cargados en <100ms ✅
```

### Flujo Fallback (si template no existe)
```
1. Template MISS: fingerprint not found
2. [Scoring] Generate all profiles + score
3. Best match found (score ≥0.75) ✅
4. Usar template similar
5. OR Gemini API (si habilitado y funcional) ✅
6. OR Fallback genérico (último recurso)
```

---

## 🚨 PROBLEMAS PENDIENTES

### P1: CRÍTICO - Gemini API No Funciona
**Estado:** 🔴 Sin resolver confirmado  
**Impacto:** Alto - Fallback total no funciona  
**Bloqueador:** Sí - Si no hay templates, app falla  

**Siguiente Acción:**
1. ✅ Actualizar paquete a 0.4.6
2. ⚠️ Ejecutar diagnose_gemini.dart
3. ⚠️ Si falla, probar gemini-pro
4. ⚠️ Si falla, deshabilitar Gemini y depender 100% de templates

---

### P2: ALTO - Template Fallback Service No Funcional
**Estado:** 🟡 Parcialmente resuelto  
**Impacto:** Medio - Fallback a scoring no funciona  
**Bloqueador:** No - Templates directos funcionan  

**Solución Temporal:**
- Sistema retorna lista vacía → salta directo a Gemini
- No afecta si hay template exacto

**Solución Permanente (TODO):**
- Generar `template_manifest.json` durante build
- Contiene lista de todos los fingerprints disponibles
- TemplateFallbackService lo carga y usa para scoring

---

### P3: MEDIO - Templates Externos Corruptos
**Estado:** 🟢 Mitigado  
**Impacto:** Bajo - Solo afecta scoring de GitHub  
**Bloqueador:** No

**Observación:**
Templates descargados de GitHub tienen intent "faith" inválido.
Scoring engine los salta correctamente.

---

## 📝 RESUMEN EJECUTIVO

### ¿Qué Funciona?
✅ Templates locales precacheados (si existen)  
✅ Generación de fingerprints  
✅ Error handling mejorado  
✅ Mensajes de error claros  

### ¿Qué NO Funciona?
❌ Gemini API (modelo no encontrado)  
⚠️ Template Fallback Service (AssetManifest issue)  
⚠️ Scoring de templates externos (nomenclatura incorrecta)

### ¿Cuál es el riesgo?
🔴 **ALTO** - Si usuario tiene perfil sin template → App falla  

### ¿Cuál es la solución?
🎯 **Generar templates para TODOS los perfiles comunes**
- Objetivo: ~150-200 templates
- Cobertura: >95% de usuarios
- Gemini solo para edge cases raros

---

## 🎯 ACCIÓN INMEDIATA REQUERIDA

### PASO 1: Regenerar Templates (AHORA)
```bash
cd /home/develop4god/Projects/habitus_faith
bash scripts/apply_all_fixes.sh
```

### PASO 2: Diagnosticar Gemini (AHORA)
```bash
export GEMINI_API_KEY="AIzaSyCkB-YYzW7v69CAyYsrviqoQ07B19c_6uM"
dart scripts/diagnose_gemini.dart
```

### PASO 3: Decisión sobre Gemini
- **SI funciona:** ✅ Continuar con plan actual
- **SI NO funciona:** ❌ PLAN B:
  1. Deshabilitar llamadas a Gemini temporalmente
  2. Expandir templates a ~200 combinaciones
  3. Fallback genérico para edge cases
  4. Investigar issue con Google Cloud support

---

**Prioridad:** 🔴 P0 - CRÍTICO  
**Bloqueador de Release:** SÍ  
**Requiere Acción:** INMEDIATA  

