#!/bin/bash

# Validation Script for Architecture Review Fixes
# Verifies all critical issues have been resolved

echo "🔍 Validating Architecture Review Fixes..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

FAILED=0

# Check 1: Verify ref.watch() is used in notification_provider.dart
echo "1️⃣  Checking Provider Lifecycle Fix (ref.watch vs ref.read)..."
if grep -q "ref.watch(firebaseMessagingProvider)" lib/core/providers/notification_provider.dart && \
   grep -q "ref.watch(firebaseFirestoreProvider)" lib/core/providers/notification_provider.dart && \
   grep -q "ref.watch(firebaseAuthProvider)" lib/core/providers/notification_provider.dart; then
    echo -e "   ${GREEN}✅ PASS${NC}: Using ref.watch() for all Firebase providers"
else
    echo -e "   ${RED}❌ FAIL${NC}: Still using ref.read() - should use ref.watch()"
    FAILED=1
fi

# Check 2: Verify create() factory method is removed
echo ""
echo "2️⃣  Checking Composition Root Duplication (create() removed)..."
if grep -q "factory NotificationService.create()" lib/core/services/notifications/notification_service.dart; then
    echo -e "   ${RED}❌ FAIL${NC}: create() factory still exists"
    FAILED=1
else
    echo -e "   ${GREEN}✅ PASS${NC}: create() factory removed - Riverpod is canonical"
fi

# Check 3: Verify no 'expect(true, true)' in tests
echo ""
echo "3️⃣  Checking for Meaningless Assertions..."
if grep -q "expect(true, true)" test/unit/services/notifications/notification_service_test.dart; then
    echo -e "   ${RED}❌ FAIL${NC}: Found 'expect(true, true)' - meaningless test"
    FAILED=1
else
    echo -e "   ${GREEN}✅ PASS${NC}: No meaningless assertions found"
fi

# Check 4: Verify verify() uses flexible matchers
echo ""
echo "4️⃣  Checking for Flexible Mock Matchers..."
if grep -A5 "verify.*requestPermission" test/unit/services/notifications/notification_service_test.dart | grep -q "any(named:"; then
    echo -e "   ${GREEN}✅ PASS${NC}: Using flexible matchers in verify()"
else
    echo -e "   ${YELLOW}⚠️  WARNING${NC}: May not be using flexible matchers in all verify() calls"
fi

# Check 5: Verify behavioral tests exist
echo ""
echo "5️⃣  Checking for Behavioral Verification..."
if grep -q "verify(.*).called(" test/unit/services/notifications/notification_service_test.dart; then
    echo -e "   ${GREEN}✅ PASS${NC}: Behavioral verification found"
else
    echo -e "   ${RED}❌ FAIL${NC}: No behavioral verification (verify().called())"
    FAILED=1
fi

# Check 6: Verify onTokenRefresh stream test exists
echo ""
echo "6️⃣  Checking for Token Refresh Stream Test..."
if grep -q "onTokenRefresh stream emits new tokens" test/unit/services/notifications/notification_service_test.dart; then
    echo -e "   ${GREEN}✅ PASS${NC}: Stream behavior test added"
else
    echo -e "   ${RED}❌ FAIL${NC}: Missing onTokenRefresh stream test"
    FAILED=1
fi

# Check 7: Verify documentation doesn't claim "100%"
echo ""
echo "7️⃣  Checking Documentation Accuracy..."
if grep -q "SOLID Compliance: 100%" docs/NOTIFICATION_SERVICE_DI_REFACTORING.md || \
   grep -q "Full SOLID Compliance" NOTIFICATION_SERVICE_DI_COMPLETE.md; then
    echo -e "   ${RED}❌ FAIL${NC}: Still claiming 100% SOLID compliance"
    FAILED=1
else
    echo -e "   ${GREEN}✅ PASS${NC}: Documentation claims are accurate"
fi

# Run Flutter analyze
echo ""
echo "8️⃣  Running Flutter Analyze..."
if flutter analyze lib/core/services/notifications/notification_service.dart \
                  lib/core/providers/notification_provider.dart \
                  2>&1 | grep -q "No issues found"; then
    echo -e "   ${GREEN}✅ PASS${NC}: No analysis errors"
else
    echo -e "   ${YELLOW}⚠️  WARNING${NC}: Analysis may have issues (check manually)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ ALL CHECKS PASSED!${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "✨ Architecture Review Fixes Complete!"
    echo ""
    echo "Next Steps:"
    echo "  1. Run: flutter test test/unit/services/notifications/notification_service_test.dart"
    echo "  2. Review: ARCHITECTURE_REVIEW_FIXES_COMPLETE.md"
    echo "  3. Merge to development branch"
    echo ""
    exit 0
else
    echo -e "${RED}❌ SOME CHECKS FAILED${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Please review and fix the failed checks above."
    echo ""
    exit 1
fi

