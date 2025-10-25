import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/bible_reader_core/bible_reader_core.dart';

void main() {
  group('BibleVersion - Edge Cases & Real Logic', () {
    group('Constructor and defaults', () {
      test('creates version with all required fields', () {
        final version = BibleVersion(
          name: 'RVR1960',
          language: 'Spanish',
          languageCode: 'es',
          assetPath: 'assets/biblia/rvr1960.db',
          dbFileName: 'rvr1960.db',
        );

        expect(version.name, equals('RVR1960'));
        expect(version.language, equals('Spanish'));
        expect(version.languageCode, equals('es'));
        expect(version.assetPath, equals('assets/biblia/rvr1960.db'));
        expect(version.dbFileName, equals('rvr1960.db'));
        expect(version.isDownloaded, isTrue); // Default value
      });

      test('uses name as id when id not provided', () {
        final version = BibleVersion(
          name: 'KJV',
          language: 'English',
          languageCode: 'en',
          assetPath: 'assets/biblia/kjv.db',
          dbFileName: 'kjv.db',
        );

        expect(version.id, equals('KJV'));
      });

      test('uses provided id when specified', () {
        final version = BibleVersion(
          id: 'custom_id',
          name: 'KJV',
          language: 'English',
          languageCode: 'en',
          assetPath: 'assets/biblia/kjv.db',
          dbFileName: 'kjv.db',
        );

        expect(version.id, equals('custom_id'));
        expect(version.name, equals('KJV'));
      });

      test('respects isDownloaded parameter', () {
        final version = BibleVersion(
          name: 'NIV',
          language: 'English',
          languageCode: 'en',
          assetPath: 'assets/biblia/niv.db',
          dbFileName: 'niv.db',
          isDownloaded: false,
        );

        expect(version.isDownloaded, isFalse);
      });
    });

    group('Edge cases - Special characters', () {
      test('handles version name with hyphens', () {
        final version = BibleVersion(
          name: 'RVR-1960',
          language: 'Spanish',
          languageCode: 'es',
          assetPath: 'assets/biblia/rvr_1960.db',
          dbFileName: 'rvr_1960.db',
        );

        expect(version.name, equals('RVR-1960'));
        expect(version.id, equals('RVR-1960'));
      });

      test('handles version name with numbers', () {
        final version = BibleVersion(
          name: 'NVI2015',
          language: 'Spanish',
          languageCode: 'es',
          assetPath: 'assets/biblia/nvi2015.db',
          dbFileName: 'nvi2015.db',
        );

        expect(version.name, equals('NVI2015'));
      });

      test('handles language with accents', () {
        final version = BibleVersion(
          name: 'RVR1960',
          language: 'Español',
          languageCode: 'es',
          assetPath: 'assets/biblia/rvr1960.db',
          dbFileName: 'rvr1960.db',
        );

        expect(version.language, equals('Español'));
      });

      test('handles language code variations', () {
        final version = BibleVersion(
          name: 'KJV',
          language: 'English (US)',
          languageCode: 'en-US',
          assetPath: 'assets/biblia/kjv.db',
          dbFileName: 'kjv.db',
        );

        expect(version.languageCode, equals('en-US'));
      });

      test('handles complex asset paths', () {
        final version = BibleVersion(
          name: 'TEST',
          language: 'Test',
          languageCode: 'test',
          assetPath: 'assets/biblia/subfolder/version.db',
          dbFileName: 'version.db',
        );

        expect(version.assetPath, equals('assets/biblia/subfolder/version.db'));
      });
    });

    group('Equality operator', () {
      test('two versions with same id are equal', () {
        final version1 = BibleVersion(
          id: 'test_id',
          name: 'Version1',
          language: 'Lang1',
          languageCode: 'l1',
          assetPath: 'path1',
          dbFileName: 'file1.db',
        );

        final version2 = BibleVersion(
          id: 'test_id',
          name: 'Version2', // Different name
          language: 'Lang2', // Different language
          languageCode: 'l2',
          assetPath: 'path2',
          dbFileName: 'file2.db',
        );

        expect(version1, equals(version2));
      });

      test('two versions with different ids are not equal', () {
        final version1 = BibleVersion(
          id: 'id1',
          name: 'Version',
          language: 'Language',
          languageCode: 'lang',
          assetPath: 'path',
          dbFileName: 'file.db',
        );

        final version2 = BibleVersion(
          id: 'id2',
          name: 'Version',
          language: 'Language',
          languageCode: 'lang',
          assetPath: 'path',
          dbFileName: 'file.db',
        );

        expect(version1, isNot(equals(version2)));
      });

      test('version is equal to itself (identical)', () {
        final version = BibleVersion(
          name: 'KJV',
          language: 'English',
          languageCode: 'en',
          assetPath: 'assets/biblia/kjv.db',
          dbFileName: 'kjv.db',
        );

        expect(version, equals(version));
      });

      test('versions with same name but no explicit id are equal', () {
        final version1 = BibleVersion(
          name: 'KJV',
          language: 'English',
          languageCode: 'en',
          assetPath: 'assets/biblia/kjv.db',
          dbFileName: 'kjv.db',
        );

        final version2 = BibleVersion(
          name: 'KJV',
          language: 'English (UK)', // Different language description
          languageCode: 'en-GB', // Different language code
          assetPath: 'assets/biblia/kjv_uk.db',
          dbFileName: 'kjv_uk.db',
        );

        expect(version1, equals(version2)); // Same because id defaults to name
      });
    });

    group('HashCode', () {
      test('versions with same id have same hashCode', () {
        final version1 = BibleVersion(
          id: 'test_id',
          name: 'Version1',
          language: 'Lang1',
          languageCode: 'l1',
          assetPath: 'path1',
          dbFileName: 'file1.db',
        );

        final version2 = BibleVersion(
          id: 'test_id',
          name: 'Version2',
          language: 'Lang2',
          languageCode: 'l2',
          assetPath: 'path2',
          dbFileName: 'file2.db',
        );

        expect(version1.hashCode, equals(version2.hashCode));
      });

      test('versions with different ids have different hashCodes', () {
        final version1 = BibleVersion(
          id: 'id1',
          name: 'Version',
          language: 'Language',
          languageCode: 'lang',
          assetPath: 'path',
          dbFileName: 'file.db',
        );

        final version2 = BibleVersion(
          id: 'id2',
          name: 'Version',
          language: 'Language',
          languageCode: 'lang',
          assetPath: 'path',
          dbFileName: 'file.db',
        );

        expect(version1.hashCode, isNot(equals(version2.hashCode)));
      });

      test('can be used in Set without duplicates', () {
        final version1 = BibleVersion(
          name: 'KJV',
          language: 'English',
          languageCode: 'en',
          assetPath: 'assets/biblia/kjv.db',
          dbFileName: 'kjv.db',
        );

        final version2 = BibleVersion(
          name: 'KJV', // Same name, so same id
          language: 'English',
          languageCode: 'en',
          assetPath: 'assets/biblia/kjv2.db',
          dbFileName: 'kjv2.db',
        );

        final version3 = BibleVersion(
          name: 'NIV',
          language: 'English',
          languageCode: 'en',
          assetPath: 'assets/biblia/niv.db',
          dbFileName: 'niv.db',
        );

        final versionSet = {version1, version2, version3};
        expect(versionSet.length, equals(2)); // version1 and version2 are same
      });

      test('can be used in Map as keys', () {
        final kjv = BibleVersion(
          name: 'KJV',
          language: 'English',
          languageCode: 'en',
          assetPath: 'assets/biblia/kjv.db',
          dbFileName: 'kjv.db',
        );

        final niv = BibleVersion(
          name: 'NIV',
          language: 'English',
          languageCode: 'en',
          assetPath: 'assets/biblia/niv.db',
          dbFileName: 'niv.db',
        );

        final versionMap = {
          kjv: 'King James Version',
          niv: 'New International Version',
        };

        expect(versionMap[kjv], equals('King James Version'));
        expect(versionMap[niv], equals('New International Version'));
      });
    });

    group('Real-world Bible versions', () {
      test('creates RVR1960 (Spanish)', () {
        final version = BibleVersion(
          name: 'RVR1960',
          language: 'Español',
          languageCode: 'es',
          assetPath: 'assets/biblia/rvr1960.db',
          dbFileName: 'rvr1960.db',
        );

        expect(version.name, equals('RVR1960'));
        expect(version.languageCode, equals('es'));
      });

      test('creates KJV (English)', () {
        final version = BibleVersion(
          name: 'KJV',
          language: 'English',
          languageCode: 'en',
          assetPath: 'assets/biblia/kjv.db',
          dbFileName: 'kjv.db',
        );

        expect(version.name, equals('KJV'));
        expect(version.languageCode, equals('en'));
      });

      test('creates NIV (English)', () {
        final version = BibleVersion(
          name: 'NIV',
          language: 'English',
          languageCode: 'en',
          assetPath: 'assets/biblia/niv.db',
          dbFileName: 'niv.db',
        );

        expect(version.name, equals('NIV'));
      });

      test('creates NVI (Spanish)', () {
        final version = BibleVersion(
          name: 'NVI',
          language: 'Español',
          languageCode: 'es',
          assetPath: 'assets/biblia/nvi.db',
          dbFileName: 'nvi.db',
        );

        expect(version.name, equals('NVI'));
        expect(version.language, equals('Español'));
      });
    });

    group('Edge cases - Empty/unusual values', () {
      test('handles empty string name (creates empty id)', () {
        final version = BibleVersion(
          name: '',
          language: 'Test',
          languageCode: 'test',
          assetPath: 'path',
          dbFileName: 'file.db',
        );

        expect(version.name, equals(''));
        expect(version.id, equals(''));
      });

      test('handles very long version name', () {
        final longName = 'VeryLongVersionNameThatExceedsNormalLengthForTesting';
        final version = BibleVersion(
          name: longName,
          language: 'Test',
          languageCode: 'test',
          assetPath: 'path',
          dbFileName: 'file.db',
        );

        expect(version.name, equals(longName));
        expect(version.id, equals(longName));
      });

      test('handles unicode characters in name', () {
        final version = BibleVersion(
          name: 'Version_日本語',
          language: 'Japanese',
          languageCode: 'ja',
          assetPath: 'path',
          dbFileName: 'file.db',
        );

        expect(version.name, equals('Version_日本語'));
      });
    });
  });
}
