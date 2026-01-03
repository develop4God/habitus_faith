# INTEGRACIÓN DE TEMPLATES CON LA APP

## 📋 PASOS PARA INTEGRAR

### 1. Copiar Templates a Assets

```bash
# Desde la raíz del proyecto
mkdir -p assets/habit_templates_v2
cp scripts/habit_templates_v2/*.json assets/habit_templates_v2/
```

### 2. Actualizar pubspec.yaml

```yaml
flutter:
  assets:
    - assets/habit_templates_v2/
```

### 3. Crear Template Loader Service

Archivo: `lib/core/services/template_loader_service.dart`

```dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class HabitTemplateLoader {
  static Future<Map<String, dynamic>?> loadTemplate(String fingerprint) async {
    try {
      final path = 'assets/habit_templates_v2/$fingerprint.json';
      final jsonString = await rootBundle.loadString(path);
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Template not found for fingerprint: $fingerprint');
      return null;
    }
  }
  
  static List<Map<String, dynamic>> parseHabits(Map<String, dynamic> template) {
    final habitsJson = template['habits'] as List;
    return habitsJson.map((h) => h as Map<String, dynamic>).toList();
  }
}
```

### 4. Modificar GeminiService

En `lib/core/services/ai/gemini_service.dart`:

```dart
// Agregar import
import 'package:habitus_faith/core/services/template_loader_service.dart';

// En generateHabitsFromOnboarding, ANTES de llamar a Gemini:
Future<List<Map<String, dynamic>>> generateHabitsFromOnboarding(
  OnboardingProfile profile,
) async {
  try {
    // 1. INTENTAR CARGAR TEMPLATE PRECACHEADO
    final fingerprint = profile.cacheFingerprint;
    logger.i('Searching for cached template: $fingerprint');
    
    final template = await HabitTemplateLoader.loadTemplate(fingerprint);
    
    if (template != null) {
      logger.i('✅ Found cached template! Skipping AI generation.');
      final habits = HabitTemplateLoader.parseHabits(template);
      
      // Traducir habits usando i18n
      return habits.map((h) => {
        ...h,
        'name': _translateHabitName(h['nameKey']),
        'notification': _translateNotification(h['notification_key']),
      }).toList();
    }
    
    // 2. SI NO HAY TEMPLATE, GENERAR CON AI (fallback actual)
    logger.i('No cached template found. Generating with AI...');
    
    // ... resto del código actual ...
```

### 5. Agregar Funciones de Traducción

```dart
String _translateHabitName(String nameKey) {
  // Mapeo de keys a traducciones
  const habitNames = {
    'morning_prayer': {
      'en': 'Morning Prayer',
      'es': 'Oración Matutina',
    },
    'bible_reading': {
      'en': 'Bible Reading',
      'es': 'Lectura Bíblica',
    },
    // ... etc
  };
  
  final currentLocale = Get.find<LanguageController>().currentLanguage;
  return habitNames[nameKey]?[currentLocale] ?? nameKey;
}

String _translateNotification(String notificationKey) {
  // Similar a _translateHabitName
  // Usar las mismas translations del habit name por ahora
  return _translateHabitName(notificationKey);
}
```

### 6. Testing

```dart
// Test manual en la app
void testTemplateLoading() async {
  // Test case: faithBased, new, closerToGod, lackOfTime
  final profile = OnboardingProfile(
    primaryIntent: PrimaryIntent.faithBased,
    spiritualMaturity: 'new',
    motivations: ['closerToGod'],
    challenge: 'lackOfTime',
    supportLevel: 'weak',
  );
  
  print('Fingerprint: ${profile.cacheFingerprint}');
  // Expected: 1689162142
  
  final template = await HabitTemplateLoader.loadTemplate(profile.cacheFingerprint);
  
  if (template != null) {
    print('✅ Template found!');
    print('Habits: ${template['habits'].length}');
  } else {
    print('❌ Template not found');
  }
}
```

## 🔍 VERIFICACIÓN

### Checklist

- [ ] Templates copiados a `assets/habit_templates_v2/`
- [ ] `pubspec.yaml` actualizado
- [ ] `HabitTemplateLoader` creado
- [ ] `GeminiService` modificado para intentar template primero
- [ ] Traducciones de habit names agregadas
- [ ] Test manual ejecutado exitosamente

### Métricas de Éxito

1. **Cache Hit Rate**: Debería ser ~80% para usuarios típicos
2. **Tiempo de Carga**: <100ms vs ~5-10s con AI
3. **Consistencia**: Mismos inputs = mismos hábitos

### Logs Esperados

```
I/GeminiService: Searching for cached template: 1689162142
I/GeminiService: ✅ Found cached template! Skipping AI generation.
I/GeminiService: Loaded 5 habits from template
```

## 📊 MONITOREO

Agregar analytics para medir:

```dart
// En GeminiService
if (template != null) {
  analytics.logEvent(
    name: 'template_cache_hit',
    parameters: {
      'fingerprint': fingerprint,
      'intent': profile.primaryIntent.name,
      'maturity': profile.spiritualMaturity,
    },
  );
} else {
  analytics.logEvent(
    name: 'template_cache_miss',
    parameters: {
      'fingerprint': fingerprint,
      'falling_back_to': 'ai_generation',
    },
  );
}
```

## 🚀 PRÓXIMOS PASOS

### Fase 2: Firebase Storage (Post-UAT)

Cuando tengamos muchos templates:

1. Subir templates a Firebase Storage
2. Implementar download on-demand
3. Cachear localmente en el dispositivo
4. Actualizar templates sin rebuild de la app

### Fase 3: Analytics-Driven Templates

1. Analizar qué templates se usan más
2. Generar templates adicionales para casos comunes
3. Optimizar templates basados en feedback de usuarios

## ⚠️ CONSIDERACIONES

### Tamaño del Bundle

60 templates × ~2KB = ~120KB total
- ✅ Aceptable para assets
- ✅ Menor que una imagen promedio
- ✅ No afecta significativamente el tamaño de la app

### Mantenimiento

- Templates son **estáticos** - no necesitan actualizarse frecuentemente
- Si cambia la estructura de hábitos, regenerar con `generate_templates_v2.py`
- Versionado en `template.version` permite migración futura

### I18n

Los templates usan **keys** (`nameKey`, `notification_key`) que se traducen en runtime:
- ✅ No duplicación de templates por idioma
- ✅ Fácil agregar nuevos idiomas
- ✅ Mantiene templates language-agnostic

## 📝 DOCUMENTACIÓN PARA EL EQUIPO

Los templates Pre-cacheados:
1. **Reducen latencia**: De 5-10s (AI) a <100ms (JSON load)
2. **Reducen costos**: Menos llamadas a Gemini API
3. **Mejoran UX**: Usuario ve hábitos instantáneamente
4. **Son determinísticos**: Mismos inputs = mismos outputs
5. **Están optimizados**: Scoring engine selecciona los mejores hábitos

Cuándo se usa AI:
- Perfil muy específico/único sin template match
- Usuario personaliza motivations/challenge después del onboarding
- Fallback si hay error cargando template

