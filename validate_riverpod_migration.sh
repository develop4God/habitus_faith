#!/bin/bash

# Riverpod DI Migration Validation Script
# This script validates that the service locator antipattern has been removed
# and that pure Riverpod DI is now in place.

echo "🔍 Riverpod DI Migration Validation"
echo "===================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

validation_passed=true

# 1. Check that service_locator.dart no longer exists
echo -n "1. Checking service_locator.dart deleted... "
if [ ! -f "lib/core/services/service_locator.dart" ]; then
    echo -e "${GREEN}✓ PASS${NC}"
else
    echo -e "${RED}✗ FAIL${NC} - service_locator.dart still exists"
    validation_passed=false
fi

# 2. Check that setupServiceLocator is not in main.dart
echo -n "2. Checking setupServiceLocator removed from main.dart... "
if ! grep -q "setupServiceLocator" lib/main.dart; then
    echo -e "${GREEN}✓ PASS${NC}"
else
    echo -e "${RED}✗ FAIL${NC} - setupServiceLocator still in main.dart"
    validation_passed=false
fi

# 3. Check that service_locator import is not in main.dart
echo -n "3. Checking service_locator import removed from main.dart... "
if ! grep -q "service_locator" lib/main.dart; then
    echo -e "${GREEN}✓ PASS${NC}"
else
    echo -e "${RED}✗ FAIL${NC} - service_locator import still in main.dart"
    validation_passed=false
fi

# 4. Check notification_provider uses pure Riverpod pattern
echo -n "4. Checking notification_provider.dart uses pure Riverpod... "
if grep -q "NotificationService.create()" lib/core/providers/notification_provider.dart && \
   ! grep -q "getService<NotificationService>()" lib/core/providers/notification_provider.dart; then
    echo -e "${GREEN}✓ PASS${NC}"
else
    echo -e "${RED}✗ FAIL${NC} - notification_provider.dart doesn't use pure Riverpod"
    validation_passed=false
fi

# 5. Check that no files import service_locator
echo -n "5. Checking no files import service_locator... "
if ! grep -r "import.*service_locator" lib/ test/ --include="*.dart" 2>/dev/null; then
    echo -e "${GREEN}✓ PASS${NC}"
else
    echo -e "${RED}✗ FAIL${NC} - Some files still import service_locator"
    validation_passed=false
fi

# 6. Check that test files were deleted
echo -n "6. Checking old test files deleted... "
missing_count=0
[ ! -f "test/core/services/service_locator_test.dart" ] && ((missing_count++))
[ ! -f "test/core/services/notification_service_di_test.dart" ] && ((missing_count++))
[ ! -f "test/integration/notification_service_integration_test.dart" ] && ((missing_count++))

if [ $missing_count -eq 3 ]; then
    echo -e "${GREEN}✓ PASS${NC} (all 3 files deleted)"
else
    echo -e "${YELLOW}⚠ PARTIAL${NC} ($missing_count/3 files deleted)"
fi

# 7. Check new test file exists
echo -n "7. Checking new test file exists... "
if [ -f "test/core/providers/notification_provider_test.dart" ]; then
    echo -e "${GREEN}✓ PASS${NC}"
else
    echo -e "${RED}✗ FAIL${NC} - New test file not created"
    validation_passed=false
fi

# 8. Run flutter analyze
echo ""
echo "8. Running Flutter analyze..."
flutter analyze --no-fatal-infos lib/main.dart \
    lib/core/providers/notification_provider.dart \
    lib/core/services/notifications/notification_service.dart \
    lib/features/habits/presentation/habits_providers.dart \
    lib/core/providers/habit_predictor_provider.dart 2>&1 | head -20

# 9. Try to compile the test file
echo ""
echo "9. Checking test file compiles..."
flutter test --no-pub test/core/providers/notification_provider_test.dart --dry-run 2>&1 | grep -E "error|All tests passed|passed" | head -5

echo ""
echo "===================================="
if [ "$validation_passed" = true ]; then
    echo -e "${GREEN}✓ Migration validation PASSED${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Run: flutter run --debug"
    echo "  2. Check logs for Firebase auth"
    echo "  3. Check logs for FCM token"
    echo "  4. Verify last login update"
    exit 0
else
    echo -e "${RED}✗ Migration validation FAILED${NC}"
    echo "Please review the failures above and fix them."
    exit 1
fi

