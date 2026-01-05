# ✅ CHECKLIST DE CORRECCIÓN - Habitus Faith
## Templates Faltantes + Error API Gemini

---

## 🎯 OBJETIVO
Resolver dos problemas críticos:
1. ❌ Templates faltantes (fingerprint 404862177 y otros)
2. ❌ Error Gemini API: "models/gemini-1.5-flash is not found"

---

## 📋 PASOS A EJECUTAR

### ✅ FASE 1: Aplicar Correcciones (5-10 minutos)

```bash
cd /home/develop4god/Projects/habitus_faith
bash scripts/apply_all_fixes.sh
```

Este script automático hace:
- [ ] Regenera 120 templates (vs 59 actuales)
- [ ] Incluye template faltante 404862177
- [ ] Copia templates a assets/
- [ ] Verifica configuración Gemini
- [ ] Limpia cache de Flutter
- [ ] Actualiza dependencias

**Resultado Esperado:**
```
✅ ALL FIXES APPLIED SUCCESSFULLY
Generated templates: ~120
```

---

### ✅ FASE 2: Rebuild & Test (10-15 minutos)

#### Paso 1: Rebuild App
```bash
flutter run
```

Esperar a que compile completamente.

#### Paso 2: Test Manual - Onboarding

**Escenario A: El que fallaba ❌→✅**
1. Abrir app
2. Ir a Onboarding
3. Seleccionar:
   - Intent: **Wellness** ☯️
   - Motivations: **Physical Health, Reduce Stress, Better Sleep** 
   - Challenge: **Lack of Motivation**
   - Support: **Weak**
4. Completar commitment
5. ✅ **VERIFICAR**: Se cargan hábitos instantáneamente (<1 segundo)
6. ✅ **VERIFICAR**: Log muestra `[Template HIT] Exact match for fingerprint: 404862177`

**Escenario B: Faith-based**
1. Nuevo onboarding
2. Seleccionar:
   - Intent: **Faith** 🙏
   - Maturity: **New**
   - Motivations: **Closer to God**
   - Challenge: **Lack of Time**
   - Support: **Weak**
3. Completar
4. ✅ **VERIFICAR**: Carga instantánea

**Escenario C: Both**
1. Nuevo onboarding
2. Seleccionar:
   - Intent: **Both** 🙏☯️
   - Maturity: **Growing**
   - Motivations: **Closer to God, Physical Health**
   - Challenge: **Lack of Motivation**
   - Support: **Normal**
3. Completar
4. ✅ **VERIFICAR**: Carga instantánea

#### Paso 3: Verificar Logs

Buscar en logcat/console:

✅ **BUENOS:**
```
[Template HIT] Exact match for fingerprint: XXXXXXX
[Template HIT] Similar template found (score ≥0.75)
```

⚠️ **ACEPTABLES (raros):**
```
[Cache MISS] Calling Gemini API
```

❌ **MALOS (no deberían aparecer):**
```
Template not found for fingerprint: XXXXXXX
models/gemini-1.5-flash is not found
```

---

### ✅ FASE 3: Validación Técnica (Opcional)

#### Verificar Templates Generados
```bash
cd /home/develop4god/Projects/habitus_faith
ls -l assets/habit_templates_v2/*.json | wc -l
```
**Esperado:** ~120 archivos

#### Verificar Template Específico
```bash
cat assets/habit_templates_v2/404862177.json | head -20
```
**Esperado:** JSON válido con profile y habits

#### Verificar Configuración Gemini
```bash
export GEMINI_API_KEY="AIzaSyCkB-YYzW7v69CAyYsrviqoQ07B19c_6uM"
dart scripts/diagnose_gemini.dart
```
**Esperado:** 
```
✅ This model works! Use: "gemini-1.5-flash-latest"
```

---

## 📊 CRITERIOS DE ÉXITO

### ✅ Mínimo Aceptable
- [ ] App compila sin errores
- [ ] Onboarding completa sin crashes
- [ ] Al menos 1 escenario de test carga hábitos
- [ ] No aparece error "Template not found" para casos comunes

### ✅ Ideal
- [ ] 3/3 escenarios de test funcionan perfectamente
- [ ] Logs muestran `[Template HIT] Exact match` en todos los casos
- [ ] Tiempo de carga <100ms
- [ ] Gemini API no se llama durante onboarding normal

### ✅ Excelente
- [ ] Todos los anteriores +
- [ ] 0 errores en logs
- [ ] Fallback system funciona (probado con perfil no cubierto)
- [ ] Documentación actualizada

---

## 🐛 TROUBLESHOOTING

### Problema: "Template not found" persiste

**Solución 1: Verificar que templates se copiaron**
```bash
ls assets/habit_templates_v2/ | grep 404862177
```
Si no existe → Ejecutar `bash scripts/regenerate_all_templates.sh`

**Solución 2: Limpiar build cache**
```bash
flutter clean
flutter pub get
rm -rf build/
flutter run
```

**Solución 3: Verificar pubspec.yaml**
```yaml
flutter:
  assets:
    - assets/habit_templates_v2/  # Debe existir
```

---

### Problema: Error Gemini persiste

**Solución 1: Verificar modelo actualizado**
```bash
grep "defaultModel" lib/core/config/ai_config.dart
```
Debe mostrar: `'gemini-1.5-flash-latest'`

**Solución 2: Verificar API key**
```bash
grep "GEMINI_API_KEY" .env
```
Debe empezar con `AIza`

**Solución 3: Test diagnóstico**
```bash
export GEMINI_API_KEY="tu_key_aqui"
dart scripts/diagnose_gemini.dart
```

---

### Problema: App muy lenta

**Solución: Verificar número de templates**
```bash
ls assets/habit_templates_v2/*.json | wc -l
```
Si >150 → Puede ser excesivo, considerar reducir

**Solución: Profile release build**
```bash
flutter run --profile
# o
flutter run --release
```

---

## 📞 SOPORTE

Si nada funciona:

1. **Revisar logs completos:**
   ```bash
   flutter run > app_log.txt 2>&1
   ```
   Buscar todos los errores relacionados con "template" o "gemini"

2. **Verificar versiones:**
   ```bash
   flutter doctor -v
   grep "google_generative_ai" pubspec.yaml
   ```

3. **Revisar documentación:**
   - `docs/TEMPLATE_FIX_SUMMARY.md` - Resumen completo
   - `docs/TEMPLATE_AND_GEMINI_FIX_PLAN.md` - Plan detallado

4. **Contactar desarrolladores:**
   - Incluir: logs, versión Flutter, pasos reproducidos
   - Mencionar: "Template & Gemini fix - Checklist v1.0"

---

## ✅ SIGN-OFF

Una vez completado TODO lo anterior, marca aquí:

- [ ] FASE 1: Scripts ejecutados exitosamente
- [ ] FASE 2: Tests manuales pasados (3/3)
- [ ] FASE 3: Validación técnica OK
- [ ] Logs limpios (sin errores críticos)
- [ ] App lista para producción

**Firma:** _________________  
**Fecha:** _________________  
**Notas:** _________________

---

**Versión:** 1.0  
**Fecha Creación:** 2026-01-03  
**Última Actualización:** 2026-01-03  
**Autor:** AI Agent

