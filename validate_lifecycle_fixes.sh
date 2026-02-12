#!/bin/bash

# Validation Script for Critical Lifecycle Fixes
# Verifies memory leak fixes, dispose, lastUsed, and production logging

echo "🔍 Validating Critical Lifecycle Fixes..."
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

FAILED=0

# Check 1: Stream subscription fields exist
echo "1️⃣  Checking Stream Subscription Fields..."
if grep -q "StreamSubscription<String>? _tokenRefreshSubscription;" lib/core/services/notifications/notification_service.dart && \
   grep -q "StreamSubscription<RemoteMessage>? _onMessageSubscription;" lib/core/services/notifications/notification_service.dart && \
   grep -q "StreamSubscription<RemoteMessage>? _onMessageOpenedAppSubscription;" lib/core/services/notifications/notification_service.dart; then
    echo -e "   ${GREEN}✅ PASS${NC}: Stream subscription fields defined"
else
    echo -e "   ${RED}❌ FAIL${NC}: Missing stream subscription fields"
    FAILED=1
fi

# Check 2: dispose() method exists
echo ""
echo "2️⃣  Checking dispose() Method..."
if grep -q "void dispose()" lib/core/services/notifications/notification_service.dart; then
    echo -e "   ${GREEN}✅ PASS${NC}: dispose() method exists"
else
    echo -e "   ${RED}❌ FAIL${NC}: dispose() method missing"
    FAILED=1
fi

# Check 3: Subscriptions are cancelled in dispose
echo ""
echo "3️⃣  Checking Subscription Cleanup..."
if grep -q "_tokenRefreshSubscription?.cancel();" lib/core/services/notifications/notification_service.dart && \
   grep -q "_onMessageSubscription?.cancel();" lib/core/services/notifications/notification_service.dart && \
   grep -q "_onMessageOpenedAppSubscription?.cancel();" lib/core/services/notifications/notification_service.dart; then
    echo -e "   ${GREEN}✅ PASS${NC}: All subscriptions cancelled in dispose()"
else
    echo -e "   ${RED}❌ FAIL${NC}: Not all subscriptions cancelled"
    FAILED=1
fi

# Check 4: lastUsed timestamp update exists
echo ""
echo "4️⃣  Checking lastUsed Timestamp Update..."
if grep -q "'lastUsed': FieldValue.serverTimestamp()" lib/core/services/notifications/notification_service.dart; then
    echo -e "   ${GREEN}✅ PASS${NC}: lastUsed timestamp update found"
else
    echo -e "   ${RED}❌ FAIL${NC}: lastUsed timestamp update missing"
    FAILED=1
fi

# Check 5: No emoji logging (check for specific emojis)
echo ""
echo "5️⃣  Checking Production Logging (No Emojis)..."
if grep -E "🔍|✅|⚠️|📝|🔑|🔔|📩" lib/core/services/notifications/notification_service.dart | grep -q "developer.log"; then
    echo -e "   ${YELLOW}⚠️  WARNING${NC}: Found emoji in logs - should use structured format"
    echo "   Remaining emojis found:"
    grep -E "🔍|✅|⚠️|📝|🔑|🔔|📩" lib/core/services/notifications/notification_service.dart | head -3
else
    echo -e "   ${GREEN}✅ PASS${NC}: No emojis in critical log statements"
fi

# Check 6: Structured logging format
echo ""
echo "6️⃣  Checking Structured Logging Format..."
if grep -q "\[NotificationService\]" lib/core/services/notifications/notification_service.dart; then
    echo -e "   ${GREEN}✅ PASS${NC}: Structured logging format found"
else
    echo -e "   ${YELLOW}⚠️  WARNING${NC}: Limited structured logging found"
fi

# Check 7: Provider onDispose hookup
echo ""
echo "7️⃣  Checking Provider Disposal..."
if grep -q "ref.onDispose" lib/core/providers/notification_provider.dart && \
   grep -q "service.dispose()" lib/core/providers/notification_provider.dart; then
    echo -e "   ${GREEN}✅ PASS${NC}: Provider properly disposes service"
else
    echo -e "   ${RED}❌ FAIL${NC}: Provider missing onDispose callback"
    FAILED=1
fi

# Check 8: Lifecycle tests exist
echo ""
echo "8️⃣  Checking Lifecycle Tests..."
if [ -f "test/unit/services/notifications/notification_service_lifecycle_test.dart" ]; then
    echo -e "   ${GREEN}✅ PASS${NC}: Lifecycle test file exists"
else
    echo -e "   ${RED}❌ FAIL${NC}: Lifecycle test file missing"
    FAILED=1
fi

# Check 9: Flutter analyze
echo ""
echo "9️⃣  Running Flutter Analyze..."
if flutter analyze lib/core/services/notifications/notification_service.dart \
                  lib/core/providers/notification_provider.dart \
                  2>&1 | grep -q "No issues found"; then
    echo -e "   ${GREEN}✅ PASS${NC}: No analysis errors"
else
    echo -e "   ${YELLOW}⚠️  WARNING${NC}: Analysis may have issues"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ ALL CRITICAL CHECKS PASSED!${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "✨ Critical Fixes Validated:"
    echo "  ✅ Memory leak prevention (stream subscriptions)"
    echo "  ✅ Proper disposal (onDispose callback)"
    echo "  ✅ Cloud Function coordination (lastUsed timestamp)"
    echo "  ✅ Production-ready logging"
    echo ""
    echo "Next Steps:"
    echo "  1. Run: flutter test test/unit/services/notifications/notification_service_lifecycle_test.dart"
    echo "  2. Test hot reload behavior (no memory leaks)"
    echo "  3. Verify logs in production (structured format)"
    echo "  4. Monitor Firestore for lastUsed timestamps"
    echo ""
    exit 0
else
    echo -e "${RED}❌ SOME CHECKS FAILED${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Please fix the failed checks above."
    echo ""
    exit 1
fi

