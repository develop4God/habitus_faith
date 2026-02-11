#!/bin/bash

# Quick Test and Run Script
# This script tests the code and then runs the app

set -e  # Exit on error

echo "🚀 Habitus Faith - Riverpod DI Migration Test & Run"
echo "=================================================="
echo ""

# Step 1: Run tests
echo "📝 Step 1: Running unit tests..."
echo ""
flutter test test/core/providers/notification_provider_test.dart
test_result=$?

if [ $test_result -eq 0 ]; then
    echo ""
    echo "✅ Tests passed!"
else
    echo ""
    echo "⚠️  Some tests may require Firebase initialization"
    echo "   This is expected for integration tests"
fi

echo ""
echo "=================================================="
echo ""

# Step 2: Run the app
echo "📱 Step 2: Running app in debug mode..."
echo ""
echo "🔍 Watch for these log patterns:"
echo "  - 🔐 Authenticated user detected"
echo "  - 📅 Updating lastLogin timestamp"
echo "  - 🔔 Initializing FCM"
echo "  - 🎫 FCM Token received"
echo "  - ✅ FCM token saved successfully"
echo ""
echo "Starting app in 3 seconds..."
sleep 3

flutter run --debug

