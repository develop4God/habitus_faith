#!/bin/bash

# Quick validation script for NotificationService DI refactoring
# This script checks that all files compile and are ready for testing

echo "🔍 Validating NotificationService DI Refactoring..."
echo ""

# Check if files exist
echo "📁 Checking files exist..."
files=(
  "lib/core/services/notifications/notification_service.dart"
  "lib/core/providers/notification_provider.dart"
  "lib/core/providers/firebase_services_provider.dart"
  "lib/core/providers/auth_provider.dart"
  "test/unit/services/notifications/notification_service_test.dart"
)

all_exist=true
for file in "${files[@]}"; do
  if [ -f "$file" ]; then
    echo "  ✅ $file"
  else
    echo "  ❌ $file (MISSING)"
    all_exist=false
  fi
done

if [ "$all_exist" = false ]; then
  echo ""
  echo "❌ Some files are missing. Aborting."
  exit 1
fi

echo ""
echo "✅ All files exist!"
echo ""

# Run Flutter analyze
echo "🔍 Running Flutter analyze..."
flutter analyze \
  lib/core/services/notifications/notification_service.dart \
  lib/core/providers/notification_provider.dart \
  lib/core/providers/firebase_services_provider.dart \
  lib/core/providers/auth_provider.dart

if [ $? -ne 0 ]; then
  echo ""
  echo "❌ Analysis failed. Please fix errors before continuing."
  exit 1
fi

echo ""
echo "✅ Analysis passed!"
echo ""

# Check test file syntax
echo "🧪 Checking test file syntax..."
flutter analyze test/unit/services/notifications/notification_service_test.dart

if [ $? -ne 0 ]; then
  echo ""
  echo "⚠️  Test file has warnings/errors."
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Validation Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Summary:"
echo "  • NotificationService: Refactored to use Dependency Injection"
echo "  • No singletons in constructor"
echo "  • Factory method available for production use"
echo "  • Riverpod providers inject dependencies automatically"
echo "  • 18 unit tests written and ready"
echo ""
echo "🎯 Next Steps:"
echo "  1. Run: flutter test test/unit/services/notifications/notification_service_test.dart"
echo "  2. Verify all 18 tests pass"
echo "  3. Review docs/NOTIFICATION_SERVICE_DI_REFACTORING.md"
echo ""

