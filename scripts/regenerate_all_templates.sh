#!/bin/bash
# Regenerate all habit templates and copy to assets
# This script ensures comprehensive template coverage

set -e  # Exit on error

echo "🚀 Habit Template Regeneration Script"
echo "======================================"
echo ""

# Navigate to scripts directory
cd "$(dirname "$0")"

echo "📍 Working directory: $(pwd)"
echo ""

# Step 1: Clean old templates
echo "🧹 Step 1: Cleaning old templates..."
if [ -d "habit_templates_v2" ]; then
    echo "   Removing scripts/habit_templates_v2/"
    rm -rf habit_templates_v2
fi

if [ -d "../assets/habit_templates_v2" ]; then
    echo "   Backing up assets/habit_templates_v2/ to assets/habit_templates_v2.backup/"
    rm -rf ../assets/habit_templates_v2.backup
    cp -r ../assets/habit_templates_v2 ../assets/habit_templates_v2.backup
fi

echo "   ✅ Cleanup complete"
echo ""

# Step 2: Generate new templates
echo "📝 Step 2: Generating templates..."
echo "   Using expanded matrix (120 templates)"

if ! python3 generate_templates_v2.py --max 120; then
    echo "   ❌ Template generation failed!"
    exit 1
fi

echo "   ✅ Generation complete"
echo ""

# Step 3: Verify templates
echo "🔍 Step 3: Verifying templates..."
TEMPLATE_COUNT=$(ls -1 habit_templates_v2/*.json 2>/dev/null | wc -l)
echo "   Generated templates: $TEMPLATE_COUNT"

if [ $TEMPLATE_COUNT -lt 100 ]; then
    echo "   ⚠️  Warning: Expected ~120 templates, got $TEMPLATE_COUNT"
    read -p "   Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "   ✅ Verification passed"
echo ""

# Step 4: Copy to assets
echo "📦 Step 4: Copying templates to assets..."
mkdir -p ../assets/habit_templates_v2
cp -v habit_templates_v2/*.json ../assets/habit_templates_v2/

ASSET_COUNT=$(ls -1 ../assets/habit_templates_v2/*.json | wc -l)
echo "   ✅ Copied $ASSET_COUNT templates to assets/"
echo ""

# Step 5: Verify fingerprints (if script exists)
if [ -f "verify_fingerprints.py" ]; then
    echo "🔐 Step 5: Verifying fingerprints..."
    if python3 verify_fingerprints.py; then
        echo "   ✅ Fingerprint verification passed"
    else
        echo "   ⚠️  Fingerprint verification failed (non-critical)"
    fi
else
    echo "⏭️  Step 5: Skipped (verify_fingerprints.py not found)"
fi
echo ""

# Step 6: Summary
echo "📊 Summary"
echo "=========="
echo "Generated templates: $TEMPLATE_COUNT"
echo "Copied to assets: $ASSET_COUNT"
echo "Backup location: ../assets/habit_templates_v2.backup/"
echo ""

# Calculate total size
TOTAL_SIZE=$(du -sh ../assets/habit_templates_v2 | cut -f1)
echo "Total size: $TOTAL_SIZE"
echo ""

echo "✅ SUCCESS: Template regeneration complete!"
echo ""
echo "Next steps:"
echo "1. Run 'flutter clean' to clear build cache"
echo "2. Run 'flutter pub get' to refresh assets"
echo "3. Rebuild the app and test onboarding"
echo "4. If issues persist, check logs for missing fingerprints"
echo ""
echo "To verify specific fingerprint:"
echo "  python3 test_fingerprint.py <intent> <maturity> <motivations> <challenge>"

