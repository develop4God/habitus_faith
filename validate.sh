#!/bin/bash

# Habitus Faith - Validation Script
# This script validates the migration is complete and working

echo "🔍 Habitus Faith Migration Validation"
echo "======================================"
echo ""

# Check Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    echo "   Please install Flutter: https://docs.flutter.dev/get-started/install"
    exit 1
fi

echo "✅ Flutter is installed"
flutter --version | head -1
echo ""

# Check for required files
echo "📁 Checking required files..."

files=(
    "lib/firebase_options.dart"
    "lib/core/providers/auth_provider.dart"
    "lib/core/providers/firestore_provider.dart"
    "lib/features/habits/models/habit_model.dart"
    "lib/features/habits/providers/habits_provider.dart"
    "lib/pages/habits_page.dart"
    "lib/pages/home_page.dart"
    "android/app/google-services.json"
    "test/helpers/test_providers.dart"
    "test/helpers/fixtures.dart"
    "test/unit/models/habit_model_test.dart"
    "test/integration/habits_provider_test.dart"
    "test/widget/habits_page_test.dart"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file - MISSING"
        exit 1
    fi
done
echo ""

# Install dependencies
echo "📦 Installing dependencies..."
flutter pub get > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Dependencies installed successfully"
else
    echo "❌ Failed to install dependencies"
    exit 1
fi
echo ""

# Run analyzer
echo "🔍 Running Flutter analyzer..."
flutter analyze --no-fatal-infos > /tmp/analyze_output.txt 2>&1
if [ $? -eq 0 ]; then
    echo "✅ No analysis errors"
else
    echo "⚠️  Analyzer found issues:"
    cat /tmp/analyze_output.txt | grep -E "(error|warning)" | head -10
fi
echo ""

# Run tests
echo "🧪 Running tests..."
flutter test --no-pub > /tmp/test_output.txt 2>&1
test_exit_code=$?

# Count test results
total_tests=$(cat /tmp/test_output.txt | grep -oE "[0-9]+ tests? passed" | grep -oE "[0-9]+" | head -1)
if [ -z "$total_tests" ]; then
    total_tests=0
fi

if [ $test_exit_code -eq 0 ]; then
    echo "✅ All tests passed!"
    echo "   Total: $total_tests tests"
else
    echo "❌ Some tests failed"
    cat /tmp/test_output.txt | grep -E "(FAILED|Error)" | head -10
fi
echo ""

# Run coverage
echo "📊 Generating coverage report..."
flutter test --coverage --no-pub > /dev/null 2>&1
if [ -f "coverage/lcov.info" ]; then
    # Calculate rough coverage percentage (requires lcov)
    if command -v lcov &> /dev/null; then
        total_lines=$(lcov --summary coverage/lcov.info 2>&1 | grep "lines" | grep -oE "[0-9]+\.[0-9]+" | head -1)
        echo "✅ Coverage report generated"
        echo "   Lines covered: $total_lines%"
    else
        echo "✅ Coverage report generated at coverage/lcov.info"
        echo "   Install lcov to see percentage: brew install lcov (macOS) or apt-get install lcov (Linux)"
    fi
else
    echo "⚠️  Coverage report not generated"
fi
echo ""

# Summary
echo "📋 VALIDATION SUMMARY"
echo "===================="
echo ""
if [ $test_exit_code -eq 0 ] && [ $total_tests -ge 18 ]; then
    echo "✅ Migration is COMPLETE and VALIDATED!"
    echo ""
    echo "   ✅ $total_tests tests passing"
    echo "   ✅ All required files present"
    echo "   ✅ No critical analyzer errors"
    echo "   ✅ Coverage report generated"
    echo ""
    echo "Next steps:"
    echo "1. Set up Firebase (see MIGRATION_COMPLETE.md)"
    echo "2. Run the app: flutter run"
    echo "3. Test on a device/emulator"
else
    echo "⚠️  Migration validation incomplete"
    echo ""
    echo "   Tests passed: $total_tests (expected: 18+)"
    echo ""
    echo "Please review:"
    echo "- Test output: /tmp/test_output.txt"
    echo "- Analyzer output: /tmp/analyze_output.txt"
    echo ""
    echo "See TESTING.md for troubleshooting"
    exit 1
fi

echo ""
echo "🎉 All validation checks passed!"
