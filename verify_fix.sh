#!/bin/bash

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║         Habits Page Fix - Comprehensive Verification         ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1: Formatting Dart code..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
dart format lib/ test/
FORMAT_EXIT=$?
if [ $FORMAT_EXIT -eq 0 ]; then
    echo -e "${GREEN}✓ Formatting completed successfully${NC}"
else
    echo -e "${RED}✗ Formatting failed${NC}"
    ERRORS=$((ERRORS + 1))
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2: Applying automatic fixes..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
dart fix --apply
FIX_EXIT=$?
if [ $FIX_EXIT -eq 0 ]; then
    echo -e "${GREEN}✓ Fixes applied successfully${NC}"
else
    echo -e "${RED}✗ Fix application failed${NC}"
    ERRORS=$((ERRORS + 1))
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 3: Analyzing code for errors and warnings..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
dart analyze > analyze_output.txt 2>&1
ANALYZE_EXIT=$?

# Check for errors and warnings
ERROR_COUNT=$(grep -c "error •" analyze_output.txt || true)
WARNING_COUNT=$(grep -c "warning •" analyze_output.txt || true)
INFO_COUNT=$(grep -c "info •" analyze_output.txt || true)

cat analyze_output.txt

if [ $ANALYZE_EXIT -eq 0 ] && [ "$ERROR_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✓ Analysis completed with no errors${NC}"
    if [ "$WARNING_COUNT" -gt 0 ]; then
        echo -e "${YELLOW}  ⚠ Found $WARNING_COUNT warnings${NC}"
    fi
    if [ "$INFO_COUNT" -gt 0 ]; then
        echo -e "${YELLOW}  ℹ Found $INFO_COUNT info messages${NC}"
    fi
else
    echo -e "${RED}✗ Analysis found $ERROR_COUNT errors${NC}"
    ERRORS=$((ERRORS + 1))
fi
rm analyze_output.txt
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 4: Running tests..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
flutter test
TEST_EXIT=$?
if [ $TEST_EXIT -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed${NC}"
else
    echo -e "${RED}✗ Some tests failed${NC}"
    ERRORS=$((ERRORS + 1))
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed successfully!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Run the app: flutter run"
    echo "2. Navigate to the Habits page"
    echo "3. Verify habits are displayed (no spinner)"
    echo "4. Test habit operations (add, edit, complete, delete)"
    echo ""
    echo "See HABITS_PAGE_FIX_SUMMARY.md for detailed information."
    exit 0
else
    echo -e "${RED}✗ $ERRORS checks failed${NC}"
    echo ""
    echo "Please review the errors above and fix them before running the app."
    echo "See HABITS_PAGE_FIX_LOG.md for detailed troubleshooting."
    exit 1
fi

