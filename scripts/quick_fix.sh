#!/bin/bash
# QUICK FIX - Regenerar templates faltantes y diagnosticar Gemini
# Este script solo hace lo esencial: generar templates y probar API

set -e

echo "🔧 QUICK FIX: Templates + Gemini Diagnostic"
echo "============================================"
echo ""

cd "$(dirname "$0")"
PROJECT_ROOT="$(cd .. && pwd)"

echo "📍 Project: $PROJECT_ROOT"
echo ""

# Step 1: Generate missing templates
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 1: Generating Templates"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if python3 generate_templates_v2.py --max 130; then
    echo "✅ Templates generated"
    TEMPLATE_COUNT=$(ls -1 habit_templates_v2/*.json 2>/dev/null | wc -l)
    echo "   Total: $TEMPLATE_COUNT templates"
else
    echo "❌ Template generation failed"
    exit 1
fi
echo ""

# Step 2: Copy to assets
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 2: Copying to Assets"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

mkdir -p "$PROJECT_ROOT/assets/habit_templates_v2"
cp habit_templates_v2/*.json "$PROJECT_ROOT/assets/habit_templates_v2/"

# Verify critical templates exist
MISSING=0
for fingerprint in "404862177" "1070993398"; do
    if [ -f "$PROJECT_ROOT/assets/habit_templates_v2/$fingerprint.json" ]; then
        echo "✅ Template $fingerprint exists"
    else
        echo "❌ Template $fingerprint MISSING!"
        MISSING=$((MISSING + 1))
    fi
done

if [ $MISSING -gt 0 ]; then
    echo ""
    echo "⚠️  WARNING: $MISSING critical template(s) missing!"
    echo "   This may cause onboarding failures."
fi
echo ""

# Step 3: Diagnose Gemini
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 3: Gemini API Diagnostic"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if API key is set
if [ -z "$GEMINI_API_KEY" ]; then
    echo "⚠️  GEMINI_API_KEY not set in environment"
    echo ""
    echo "Trying to load from .env file..."

    if [ -f "$PROJECT_ROOT/.env" ]; then
        export $(grep "^GEMINI_API_KEY" "$PROJECT_ROOT/.env" | xargs)

        if [ -n "$GEMINI_API_KEY" ]; then
            echo "✅ Loaded API key from .env"
        else
            echo "❌ Could not find GEMINI_API_KEY in .env"
            echo ""
            echo "Skipping Gemini diagnostic."
            echo "To test later, run:"
            echo "  export GEMINI_API_KEY='your_key'"
            echo "  dart scripts/diagnose_gemini.dart"
            exit 0
        fi
    else
        echo "❌ .env file not found"
        echo ""
        echo "Skipping Gemini diagnostic."
        exit 0
    fi
fi

cd "$PROJECT_ROOT"

echo ""
echo "Running diagnostic with API key: ${GEMINI_API_KEY:0:10}..."
echo ""

if dart scripts/diagnose_gemini.dart; then
    echo ""
    echo "✅ Gemini diagnostic completed"
else
    echo ""
    echo "⚠️  Gemini diagnostic found issues"
    echo "   Check output above for details"
    echo ""
    echo "Common fixes:"
    echo "  1. Verify API key at: https://aistudio.google.com/app/apikey"
    echo "  2. Ensure Gemini API is enabled"
    echo "  3. Try updating google_generative_ai package"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ QUICK FIX COMPLETE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo "  1. flutter clean && flutter pub get"
echo "  2. flutter run"
echo "  3. Test onboarding with wellness profile"
echo ""

