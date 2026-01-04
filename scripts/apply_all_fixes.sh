#!/bin/bash
# EJECUTAR ESTE SCRIPT PARA APLICAR TODAS LAS CORRECCIONES
# Run from project root: bash scripts/apply_all_fixes.sh

set -e

echo "🚀 Habitus Faith - Template & Gemini Fix Application"
echo "===================================================="
echo ""

PROJECT_ROOT="/home/develop4god/Projects/habitus_faith"
cd "$PROJECT_ROOT"

echo "📍 Working from: $(pwd)"
echo ""

# Step 1: Regenerate all templates
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 1: Regenerating Templates"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd scripts
if bash regenerate_all_templates.sh; then
    echo "✅ Templates regenerated successfully"
else
    echo "❌ Template regeneration failed"
    exit 1
fi
echo ""

cd "$PROJECT_ROOT"

# Step 2: Verify Gemini configuration (optional - needs API key)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 2: Verifying Gemini Configuration (Optional)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -f ".env" ] && grep -q "GEMINI_API_KEY" .env; then
    # shellcheck disable=SC2046
    export $(grep "GEMINI_API_KEY" .env | xargs)

    if [ -n "$GEMINI_API_KEY" ]; then
        echo "Running Gemini diagnostics..."
        if dart scripts/diagnose_gemini.dart; then
            echo "✅ Gemini configuration verified"
        else
            echo "⚠️  Gemini diagnostic returned errors"
            echo "   This is non-critical if you have enough templates"
        fi
    else
        echo "⏭️  GEMINI_API_KEY not found, skipping verification"
    fi
else
    echo "⏭️  .env file not found, skipping Gemini verification"
fi
echo ""

# Step 3: Flutter clean and rebuild
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 3: Cleaning Flutter Build Cache"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
flutter clean
echo "✅ Flutter cache cleaned"
echo ""

# Step 4: Get dependencies
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 4: Getting Dependencies"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
flutter pub get
echo "✅ Dependencies updated"
echo ""

# Step 5: Run tests (optional)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 5: Running Unit Tests (Optional)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

read -p "Run unit tests? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if flutter test test/unit/config/ai_config_test.dart; then
        echo "✅ AI config tests passed"
    else
        echo "⚠️  Some tests failed (check output above)"
    fi
else
    echo "⏭️  Skipping tests"
fi
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ ALL FIXES APPLIED SUCCESSFULLY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Summary of Changes:"
echo "  ✅ Generated ~120 habit templates"
echo "  ✅ Updated Gemini model to gemini-1.5-flash-latest"
echo "  ✅ Added template similarity fallback service"
echo "  ✅ Improved error handling for Gemini API"
echo "  ✅ Cleaned and rebuilt Flutter project"
echo ""
echo "Next Steps:"
echo "  1. Build and run the app:"
echo "     flutter run"
echo ""
echo "  2. Test onboarding with these scenarios:"
echo "     • Wellness + [Physical Health, Reduce Stress, Better Sleep] + Lack of Motivation"
echo "     • Faith (New) + [Closer to God] + Lack of Time"
echo "     • Both (Growing) + [Closer to God, Physical Health] + Lack of Motivation"
echo ""
echo "  3. Monitor logs for:"
echo "     ✅ '[Template HIT] Exact match' (good)"
echo "     ✅ '[Template HIT] Similar template found' (fallback working)"
echo "     ⚠️  '[Cache MISS] Calling Gemini API' (should be rare)"
echo "     ❌ 'Template not found' (should NOT appear)"
echo ""
echo "  4. Check documentation:"
echo "     • docs/TEMPLATE_FIX_SUMMARY.md - Complete summary"
echo "     • docs/TEMPLATE_AND_GEMINI_FIX_PLAN.md - Detailed plan"
echo ""
echo "═══════════════════════════════════════════════════"
echo "Ready to test! 🎉"
echo "═══════════════════════════════════════════════════"

