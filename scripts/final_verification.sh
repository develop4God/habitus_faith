#!/bin/bash
# Final Verification Script - Run before deploying

echo "======================================================================"
echo "  HABITUS FAITH - TEMPLATE SYSTEM V2 FINAL VERIFICATION"
echo "======================================================================"
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check 1: Template files
echo "1. Checking template files..."
SCRIPTS_COUNT=$(ls scripts/habit_templates_v2/*.json 2>/dev/null | wc -l)
ASSETS_COUNT=$(ls assets/habit_templates_v2/*.json 2>/dev/null | wc -l)

if [ "$SCRIPTS_COUNT" -eq 60 ] && [ "$ASSETS_COUNT" -eq 60 ]; then
    echo -e "   ${GREEN}✓${NC} Templates: $SCRIPTS_COUNT in scripts, $ASSETS_COUNT in assets"
else
    echo -e "   ${RED}✗${NC} Expected 60 templates, found $SCRIPTS_COUNT in scripts, $ASSETS_COUNT in assets"
    exit 1
fi

# Check 2: No duplicates
echo "2. Checking for duplicates..."
DIFF_OUTPUT=$(diff <(ls scripts/habit_templates_v2/ | sort) <(ls assets/habit_templates_v2/ | sort))
if [ -z "$DIFF_OUTPUT" ]; then
    echo -e "   ${GREEN}✓${NC} No duplicates - files match exactly"
else
    echo -e "   ${RED}✗${NC} Files differ between scripts and assets"
    exit 1
fi

# Check 3: Python validation
echo "3. Running Python validation..."
cd scripts
VALIDATION_OUTPUT=$(python3 validate_templates.py 2>&1 | grep "ALL TEMPLATES VALID")
if [ -n "$VALIDATION_OUTPUT" ]; then
    echo -e "   ${GREEN}✓${NC} All templates validated"
else
    echo -e "   ${RED}✗${NC} Template validation failed"
    cd ..
    exit 1
fi
cd ..

# Check 4: Integration tests
echo "4. Running integration tests..."
cd scripts
INTEGRATION_OUTPUT=$(python3 test_integration.py 2>&1 | grep "ALL TESTS PASSED")
if [ -n "$INTEGRATION_OUTPUT" ]; then
    echo -e "   ${GREEN}✓${NC} Integration tests passed"
else
    echo -e "   ${RED}✗${NC} Integration tests failed"
    cd ..
    exit 1
fi
cd ..

# Check 5: Flutter build
echo "5. Checking Flutter build..."
if [ -f "build/app/outputs/flutter-apk/app-debug.apk" ]; then
    APK_SIZE=$(ls -lh build/app/outputs/flutter-apk/app-debug.apk | awk '{print $5}')
    echo -e "   ${GREEN}✓${NC} APK built successfully ($APK_SIZE)"
else
    echo -e "   ${YELLOW}⚠${NC} APK not found - run: flutter build apk --debug"
fi

# Check 6: Pubspec assets
echo "6. Checking pubspec.yaml..."
if grep -q "assets/habit_templates_v2/" pubspec.yaml; then
    echo -e "   ${GREEN}✓${NC} Assets configured in pubspec.yaml"
else
    echo -e "   ${RED}✗${NC} Assets not configured in pubspec.yaml"
    exit 1
fi

# Check 7: Dart loader service
echo "7. Checking Dart loader service..."
if [ -f "lib/core/services/habit_template_loader.dart" ]; then
    echo -e "   ${GREEN}✓${NC} HabitTemplateLoader service exists"
else
    echo -e "   ${RED}✗${NC} HabitTemplateLoader service not found"
    exit 1
fi

# Summary
echo ""
echo "======================================================================"
echo -e "  ${GREEN}✓ ALL CHECKS PASSED - SYSTEM READY FOR TESTING${NC}"
echo "======================================================================"
echo ""
echo "Next Steps:"
echo "  1. Install APK on device: adb install build/app/outputs/flutter-apk/app-debug.apk"
echo "  2. Complete onboarding with different profiles"
echo "  3. Verify habits generate instantly (< 1 second)"
echo "  4. Check logs for 'Template loaded successfully'"
echo ""
echo "Test Scenarios:"
echo "  - New believer + lack of time → Should get 5 short spiritual habits"
echo "  - Wellness + reduce stress → Should get physical + mental habits"
echo "  - Both + growing + weak support → Should include relational habit"
echo ""

