# Ejecutar Tests

Este proyecto incluye tests integrales para la migración de la app Habitus Faith.

## Pre-requisitos

```bash
flutter pub get
```

## Ejecutar Todos los Tests

```bash
flutter test
```

Salida esperada: **19+ tests pasando** ✅

## Ejecutar Tests con Coverage

```bash
flutter test --coverage
```

Esto genera un reporte de coverage en `coverage/lcov.info`

## Ver Reporte de Coverage (HTML)

```bash
# Instalar lcov si no está ya instalado
# macOS: brew install lcov
# Linux: sudo apt-get install lcov

# Generar reporte HTML
genhtml coverage/lcov.info -o coverage/html

# Abrir en navegador
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
```

## Ejecutar Archivos de Test Específicos

```bash
# Solo unit tests
flutter test test/unit/

# Solo integration tests
flutter test test/integration/

# Solo widget tests
flutter test test/widget/

# Archivo de test específico
flutter test test/unit/models/habit_model_test.dart
```

## Ejecutar Tests en Modo Watch

```bash
flutter test --watch
```

## Categorías de Tests

### Unit Tests (7 tests)
- `test/unit/models/habit_model_test.dart`
- Prueba lógica de negocio del modelo de hábito
- Prueba cálculos de rachas
- Prueba serialización/deserialización

### Integration Tests (5 tests)
- `test/integration/habits_provider_test.dart`
- Prueba proveedores de Riverpod con Firestore
- Prueba operaciones CRUD
- Prueba filtrado de datos

### Widget Tests (6 tests)
- `test/widget/habits_page_test.dart`
- Prueba interacciones de UI
- Prueba flujos de usuario
- Prueba integración de Firestore en UI

## Resultados Esperados

Todos los tests deberían pasar con:
- ✅ 19+ tests pasando
- ✅ 0 fallos
- ✅ Coverage >70% en código nuevo
- ✅ Sin warnings de analyzer

## Solución de Problemas

### Si los tests fallan:

1. **Dependencias faltantes**
   ```bash
   flutter pub get
   ```

2. **Caché de build obsoleto**
   ```bash
   flutter clean
   flutter pub get
   flutter test
   ```

3. **Problemas específicos de plataforma**
   - Asegurar que se está usando Flutter 3.0.0 o posterior
   - Verificar que todas las dependencias de test están instaladas

### Problemas Comunes

**Problema**: No se pueden encontrar imports de paquetes
**Solución**: Ejecutar `flutter pub get`

**Problema**: Timeout de test
**Solución**: Algunos tests usan `pumpAndSettle()` - asegurar que el sistema no está sobrecargado

**Problema**: Errores de mock de Firestore
**Solución**: Verificar que la versión de `fake_cloud_firestore` es compatible

## Archivos Helper de Test

- `test/helpers/test_providers.dart` - Crea contenedores de prueba con Firebase simulado
- `test/helpers/fixtures.dart` - Proporciona fixtures de datos de prueba

## Integración CI/CD

Agregar a tu pipeline CI/CD:

```yaml
# Ejemplo GitHub Actions
- name: Ejecutar tests
  run: flutter test
  
- name: Generar coverage
  run: flutter test --coverage
  
- name: Subir coverage
  uses: codecov/codecov-action@v2
  with:
    files: coverage/lcov.info
```

## Escribir Nuevos Tests

Seguir el patrón AAA:

```dart
//test('descripción', () {
  // Arrange - Configurar datos de prueba
  final habit = TestFixtures.habitOracion();
  
  // Act - Ejecutar la acción
  final result = habit.completeToday();
  
  // Assert - Verificar el resultado
  //expect(result.currentStreak, 1);
//});
```

Usar claves de prueba para widget tests:

```dart
//await tester.tap(find.byKey(const Key('add_habit_fab')));
```

## Análisis de Código

```bash
# Ejecutar analyzer
flutter analyze

# Solo errores y warnings (sin infos)
flutter analyze --no-fatal-infos
```
