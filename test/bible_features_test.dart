import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/utils/bible_version_registry.dart';
import 'package:habitus_faith/utils/copyright_utils.dart';
import 'package:habitus_faith/utils/bubble_constants.dart';

void main() {
  group('Bible Version Registry Tests', () {
    test('getAllVersions returns all versions', () {
      final versions = BibleVersionRegistry.getAllVersions();
      expect(versions.length, greaterThanOrEqualTo(5));
      expect(versions.any((v) => v.versionCode == 'RVR1960'), isTrue);
      expect(versions.any((v) => v.versionCode == 'NTV'), isTrue);
      expect(versions.any((v) => v.versionCode == 'TLA'), isTrue);
      expect(versions.any((v) => v.versionCode == 'Pesh-es'), isTrue);
      expect(versions.any((v) => v.versionCode == 'RV1865'), isTrue);
    });

    test('getVersionsByLanguage filters by language', () {
      final spanishVersions = BibleVersionRegistry.getVersionsByLanguage('es');
      expect(spanishVersions.length, greaterThanOrEqualTo(5));
      expect(spanishVersions.every((v) => v.languageCode == 'es'), isTrue);
    });

    test('getDefaultVersion returns a version', () {
      final defaultVersion = BibleVersionRegistry.getDefaultVersion('es');
      expect(defaultVersion, isNotNull);
      expect(defaultVersion.languageCode, 'es');
    });
  });

  group('Copyright Utils Tests', () {
    test('getCopyright returns copyright for RVR1960 in Spanish', () {
      final copyright = CopyrightUtils.getCopyright('RVR1960', 'es');
      expect(copyright, contains('Reina-Valera 1960'));
      expect(copyright, contains('Sociedades Bíblicas'));
    });

    test('getCopyright returns copyright for NTV in Spanish', () {
      final copyright = CopyrightUtils.getCopyright('NTV', 'es');
      expect(copyright, contains('Nueva Traducción Viviente'));
      expect(copyright, contains('Tyndale House Foundation'));
    });

    test('getCopyright returns default for unknown version', () {
      final copyright = CopyrightUtils.getCopyright('UNKNOWN', 'es');
      expect(copyright, contains('Texto bíblico utilizado con permiso'));
    });

    test('getVersionName returns correct name', () {
      final name = CopyrightUtils.getVersionName('RVR1960', 'es');
      expect(name, 'Reina Valera 1960');
    });
  });

  group('Bubble Constants Tests', () {
    test('buildBadge creates a badge widget', () {
      final badge = BubbleConstants.buildBadge(text: 'Nuevo');
      expect(badge, isNotNull);
    });

    test('bubble IDs are defined', () {
      expect(BubbleConstants.bibleNavigationBubble, isNotEmpty);
      expect(BubbleConstants.bibleSearchBubble, isNotEmpty);
      expect(BubbleConstants.versionSelectorBubble, isNotEmpty);
    });
  });
}
