import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('i18n Translation Completeness', () {
    late Map<String, dynamic> masterKeys;
    late List<Map<String, dynamic>> translationFiles;

    setUpAll(() {
      // Load master file (English)
      final enFile = File('lib/l10n/app_en.arb');
      masterKeys =
          json.decode(enFile.readAsStringSync()) as Map<String, dynamic>;

      // Load all translation files
      translationFiles = [
        json.decode(File('lib/l10n/app_es.arb').readAsStringSync())
            as Map<String, dynamic>,
        json.decode(File('lib/l10n/app_fr.arb').readAsStringSync())
            as Map<String, dynamic>,
        json.decode(File('lib/l10n/app_pt.arb').readAsStringSync())
            as Map<String, dynamic>,
        json.decode(File('lib/l10n/app_zh.arb').readAsStringSync())
            as Map<String, dynamic>,
      ];
    });

    test('All translation files have matching keys from master', () {
      // Get all content keys (exclude metadata keys starting with @)
      final masterContentKeys = masterKeys.keys
          .where((key) => !key.startsWith('@') && key != '@@locale')
          .toSet();

      final fileNames = [
        'app_es.arb',
        'app_fr.arb',
        'app_pt.arb',
        'app_zh.arb'
      ];

      for (int i = 0; i < translationFiles.length; i++) {
        final translationFile = translationFiles[i];
        final fileName = fileNames[i];

        final translationContentKeys = translationFile.keys
            .where((key) => !key.startsWith('@') && key != '@@locale')
            .toSet();

        // Check for missing keys
        final missingKeys =
            masterContentKeys.difference(translationContentKeys);
        expect(
          missingKeys,
          isEmpty,
          reason: '$fileName is missing keys: ${missingKeys.join(", ")}',
        );

        // Check for extra keys not in master
        final extraKeys = translationContentKeys.difference(masterContentKeys);
        expect(
          extraKeys,
          isEmpty,
          reason:
              '$fileName has extra keys not in master: ${extraKeys.join(", ")}',
        );
      }
    });

    test('All observability and ML keys are present', () {
      final requiredKeys = [
        'mlPredictionFailed',
        'mlModelNotLoaded',
        'mlInsufficientData',
        'backgroundSyncFailed',
        'backgroundSyncNetwork',
        'backgroundSyncPermission',
        'workmanagerActive',
        'workmanagerRestricted',
        'workmanagerDisabled',
        'patternWeekend',
        'patternEvening',
        'optimalTimeFound',
        'networkTimeout',
        'firebasePermissionDenied',
        'errorUnknown',
        'devBannerTitle',
        'devBannerLastSync',
        'devBannerMlStatus',
        'devBannerWorkmanager',
        'devBannerFastTime',
        'riskLevelLow',
        'riskLevelMedium',
        'riskLevelHigh',
        'predictorRunning',
        'predictorComplete',
        'syncInProgress',
        'syncComplete',
        'mlModelLoaded',
        'mlModelLoading',
        'mlModelError',
      ];

      for (final key in requiredKeys) {
        expect(
          masterKeys.containsKey(key),
          isTrue,
          reason: 'Master file (app_en.arb) is missing required key: $key',
        );

        // Verify all translation files have the key
        for (int i = 0; i < translationFiles.length; i++) {
          final fileName =
              ['app_es.arb', 'app_fr.arb', 'app_pt.arb', 'app_zh.arb'][i];
          expect(
            translationFiles[i].containsKey(key),
            isTrue,
            reason: '$fileName is missing required key: $key',
          );
        }
      }
    });

    test('No empty translations', () {
      final fileNames = [
        'app_en.arb',
        ...['app_es.arb', 'app_fr.arb', 'app_pt.arb', 'app_zh.arb']
      ];
      final allFiles = [masterKeys, ...translationFiles];

      for (int i = 0; i < allFiles.length; i++) {
        final file = allFiles[i];
        final fileName = fileNames[i];

        for (final entry in file.entries) {
          if (!entry.key.startsWith('@') && entry.key != '@@locale') {
            expect(
              entry.value,
              isNotEmpty,
              reason: '$fileName has empty translation for key: ${entry.key}',
            );
          }
        }
      }
    });
  });
}
