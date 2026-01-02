# ESTADO DEL DESARROLLO - Template Generator v2

## ✅ COMPLETADO

### 1. Catálogo de Hábitos (habit_catalog.py)
- ✅ 20 hábitos espirituales (spiritual)
- ✅ 15 hábitos físicos (physical)
- ✅ 8 hábitos mentales (mental)
- ✅ 2 hábitos relacionales (relational)
- ✅ Total: 45 hábitos con metadata completa

### 2. Motor de Scoring (generate_templates_v2.py)
- ✅ HabitScorer: Calcula scores basados en profile match
- ✅ HabitSelector: Selecciona hábitos óptimos
- ✅ Filtrado por madurez espiritual
- ✅ Ajuste de duraciones según challenge
- ✅ Balance de categorías por intent

### 3. Generador de Templates
- ✅ 60 templates generados (TEMPLATE_MATRIX)
  - 24 faithBased (new: 12, growing: 4, mature: 4, passionate: 4)
  - 12 wellness
  - 24 both (new: 8, growing: 8, mature: 4, passionate: 4)
- ✅ Estructura JSON correcta
- ✅ Metadata de profile incluida
- ✅ Hábitos con durations ajustadas

### 4. Tests
- ✅ test_habit_selector.py: 8/8 tests PASSING
  - Catálogo completo
  - Faith-based selection
  - Wellness selection
  - Weak support (relational habits)
  - Fingerprint generation
  - Template validation
  - Maturity filtering
  - Duration adjustment

## ⚠️ ISSUE ACTUAL: Fingerprint Verification

### Problema Detectado
El script `verify_fingerprints.py` reporta que los fingerprints NO coinciden cuando se regeneran desde el profile almacenado en el template.

### Causa Raíz (HIPÓTESIS)
Cuando se generaron los templates, se usó el profile COMPLETO incluyendo todos los campos. Pero al regenerar desde el template JSON, puede haber diferencias en:

1. **Orden de motivations**: Los templates pueden tener motivations en diferente orden que cuando se generaron
2. **Campo maturity**: En el template se guarda como `spiritualMaturity`, pero al regenerar se usa `maturity`
3. **Lógica de generación**: Puede haber una inconsistencia en cómo se construye el key

### Código Dart de Referencia
```dart
// onboarding_models.dart línea 80-83
String get cacheFingerprint {
  final key = '${primaryIntent.name}_${spiritualMaturity}_${motivations.join('_')}_$challenge';
  return key.hashCode.toString();
}
```

### Estructura del Key
Formato: `{intent}_{maturity}_{motivation1_motivation2}_{challenge}`

Ejemplo:
- `faithBased_new_closerToGod_lackOfTime`
- `wellness__physicalHealth_reduceStress_lackOfTime` (nota: doble _ porque no hay maturity)

## 🔍 DIAGNÓSTICO NECESARIO

### Verificación Manual
Necesitamos verificar UN template manualmente:

**Template:** `1689162142.json`
```json
{
  "fingerprint": "1689162142",
  "profile": {
    "intent": "faithBased",
    "motivations": ["closerToGod"],
    "challenge": "lackOfTime",
    "spiritualMaturity": "new"
  }
}
```

**Key esperado:** `faithBased_new_closerToGod_lackOfTime`

**Cálculo Jenkins Hash:**
```python
key = "faithBased_new_closerToGod_lackOfTime"
# Aplicar Jenkins hash...
# Resultado esperado: 1689162142
```

## 🎯 SIGUIENTE PASO

### Opción 1: Regenerar TODOS los templates
Si el fingerprint está mal, regenerar todos con la lógica corregida.

```bash
cd scripts
rm -rf habit_templates_v2/*
python3 generate_templates_v2.py --max 60
```

### Opción 2: Corregir verify_fingerprints.py
El problema puede estar en cómo `verify_fingerprints.py` extrae el profile del JSON:

```python
# Posible issue: usar 'maturity' en vez de 'spiritualMaturity'
regenerated_fingerprint = generate_fingerprint({
    "intent": profile.get("intent"),
    "maturity": profile.get("spiritualMaturity"),  # ← Esto puede ser el problema
    "motivations": profile.get("motivations", []),
    "challenge": profile.get("challenge")
})
```

## 📋 TAREAS PENDIENTES

1. ✅ Verificar que el algoritmo Jenkins hash es correcto
2. ⏳ Confirmar que los fingerprints generados coinciden con Dart
3. ⏳ Subir templates a Firebase Storage o Assets
4. ⏳ Actualizar GeminiService para buscar templates por fingerprint
5. ⏳ Crear documentación de uso

## 🚀 DEPLOYMENT

### Assets (Recomendado para UAT)
```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/habit_templates_v2/
```

Luego copiar:
```bash
cp -r scripts/habit_templates_v2/ assets/
```

### Firebase Storage (Futuro)
Para producción, subir a:
```
gs://habitus-app/habit_templates_v2/{fingerprint}.json
```

## ✅ VERIFICACIÓN FINAL

Antes de integrar con Dart:

1. [ ] Todos los fingerprints verificados
2. [ ] Test en Dart que carga un template
3. [ ] Verificar que el match funciona en la app
4. [ ] Fallback a AI si no hay match

## 📝 NOTAS

- Los templates son **language-agnostic** (usan keys para i18n)
- Cada template tiene 5-6 hábitos balanceados
- Duraciones ajustadas según challenge y maturity
- Support level NO está en el fingerprint (solo afecta selección de hábitos)

