# Quick Reference - Template System V2

## Status: ✅ READY

## Quick Commands

### Verify Everything
```bash
./scripts/final_verification.sh
```

### Install on Device
```bash
adb install build/app/outputs/flutter-apk/app-debug.apk
```

### View Logs
```bash
adb logcat | grep -E "(HabitTemplateLoader|GeminiService)"
```

### Rebuild if Needed
```bash
flutter clean && flutter pub get && flutter build apk --debug
```

## Test Profiles

| Profile | Fingerprint | Expected Habits |
|---------|-------------|-----------------|
| New believer + lack of time | `1689162142` | 5 spiritual (≤15 min) |
| Wellness + reduce stress | `142490031` | Physical + mental |
| Growing + both + weak support | `1595435698` | Mixed + relational |

## Success Indicators

✅ **Template loads in < 1 second**  
✅ **Log shows**: "✅ Template loaded successfully"  
✅ **No AI fallback** for covered profiles  
✅ **Habits match profile characteristics**

## Files

- **Templates**: `assets/habit_templates_v2/` (60 files)
- **Catalog**: `scripts/habit_catalog.py` (45 habits)
- **Generator**: `scripts/generate_templates_v2.py`
- **Tests**: `scripts/test_integration.py`
- **APK**: `build/app/outputs/flutter-apk/app-debug.apk` (203M)

## Troubleshooting

**Template not found?**
→ Check fingerprint matches, run `flutter pub get`

**Wrong habits?**
→ Run `python3 scripts/test_integration.py`

**Build fails?**
→ Run `flutter clean && flutter pub get`

---

**All systems ready. Deploy with confidence! 🚀**

