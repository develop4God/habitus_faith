#!/bin/bash

echo "Running dart format..."
dart format lib/ test/

echo ""
echo "Running dart fix --apply..."
dart fix --apply

echo ""
echo "Analyzing code..."
dart analyze

echo ""
echo "Running tests..."
flutter test

echo ""
echo "Done!"

