#!/bin/bash
# Script de verificación del sistema de templates

echo "🔍 VERIFICANDO SISTEMA DE TEMPLATES"
echo "===================================="
echo ""

# 1. Verificar templates generados
echo "1️⃣  Verificando templates generados..."
TEMPLATES_COUNT=$(ls scripts/habit_templates_v2/*.json 2>/dev/null | wc -l)
if [ "$TEMPLATES_COUNT" -eq 60 ]; then
    echo "   ✅ 60 templates generados"
else
    echo "   ❌ ERROR: Se encontraron $TEMPLATES_COUNT templates (esperado: 60)"
fi

# 2. Verificar templates en assets
echo ""
echo "2️⃣  Verificando templates en assets..."
ASSETS_COUNT=$(ls assets/habit_templates_v2/*.json 2>/dev/null | wc -l)
if [ "$ASSETS_COUNT" -eq 60 ]; then
    echo "   ✅ 60 templates en assets"
else
    echo "   ❌ ERROR: Se encontraron $ASSETS_COUNT templates en assets (esperado: 60)"
fi

# 3. Verificar tamaño de templates
echo ""
echo "3️⃣  Verificando tamaño de templates..."
if [ -d "assets/habit_templates_v2" ]; then
    SIZE=$(du -sh assets/habit_templates_v2/ | cut -f1)
    echo "   ✅ Tamaño total: $SIZE (esperado: ~100-120K)"
else
    echo "   ❌ ERROR: Directorio assets/habit_templates_v2 no existe"
fi

# 4. Verificar pubspec.yaml
echo ""
echo "4️⃣  Verificando pubspec.yaml..."
if grep -q "assets/habit_templates_v2/" pubspec.yaml; then
    echo "   ✅ Assets configurados en pubspec.yaml"
else
    echo "   ❌ ERROR: Assets no configurados en pubspec.yaml"
fi

# 5. Verificar servicios Dart
echo ""
echo "5️⃣  Verificando servicios Dart..."
if [ -f "lib/core/services/habit_template_loader.dart" ]; then
    echo "   ✅ HabitTemplateLoader creado"
else
    echo "   ❌ ERROR: HabitTemplateLoader no encontrado"
fi

if [ -f "lib/core/utils/habit_translation_helper.dart" ]; then
    echo "   ✅ HabitTranslationHelper creado"
else
    echo "   ❌ ERROR: HabitTranslationHelper no encontrado"
fi

# 6. Verificar traducciones
echo ""
echo "6️⃣  Verificando traducciones..."
if grep -q "morning_prayer" lib/l10n/app_en.arb; then
    echo "   ✅ Traducciones en inglés agregadas"
else
    echo "   ❌ ERROR: Traducciones en inglés no encontradas"
fi

if grep -q "morning_prayer" lib/l10n/app_es.arb; then
    echo "   ✅ Traducciones en español agregadas"
else
    echo "   ❌ ERROR: Traducciones en español no encontradas"
fi

# 7. Verificar tests Python
echo ""
echo "7️⃣  Ejecutando tests Python..."
cd scripts
if python3 test_habit_selector.py > /dev/null 2>&1; then
    echo "   ✅ Tests Python pasando"
else
    echo "   ❌ ERROR: Tests Python fallando"
fi
cd ..

# 8. Verificar un template de ejemplo
echo ""
echo "8️⃣  Verificando estructura de template de ejemplo..."
if [ -f "assets/habit_templates_v2/1689162142.json" ]; then
    echo "   ✅ Template de ejemplo existe (1689162142.json)"

    # Verificar que tiene la estructura esperada
    if grep -q '"template_id"' assets/habit_templates_v2/1689162142.json && \
       grep -q '"fingerprint"' assets/habit_templates_v2/1689162142.json && \
       grep -q '"habits"' assets/habit_templates_v2/1689162142.json; then
        echo "   ✅ Estructura del template válida"
    else
        echo "   ❌ ERROR: Estructura del template inválida"
    fi
else
    echo "   ❌ ERROR: Template de ejemplo no encontrado"
fi

# Resumen final
echo ""
echo "===================================="
echo "📊 RESUMEN"
echo "===================================="
echo ""
echo "Templates generados: $TEMPLATES_COUNT/60"
echo "Templates en assets: $ASSETS_COUNT/60"
echo ""

# Determinar estado general
if [ "$TEMPLATES_COUNT" -eq 60 ] && [ "$ASSETS_COUNT" -eq 60 ]; then
    echo "✅ SISTEMA LISTO PARA INTEGRACIÓN"
    echo ""
    echo "Próximos pasos:"
    echo "1. flutter gen-l10n"
    echo "2. Modificar GeminiService"
    echo "3. Testing"
    echo ""
    echo "Ver NEXT_STEPS.md para detalles"
else
    echo "❌ HAY PROBLEMAS QUE CORREGIR"
    echo ""
    echo "Revisa los errores arriba y consulta la documentación"
fi

echo ""

