import 'dart:convert';
import 'dart:io';

/// List of supported languages (from app_localizations.dart)
const supportedLanguages = ['en', 'es', 'fr', 'pt', 'zh'];

/// Language name mappings for better display
const languageNames = {
  'en': 'English',
  'es': 'Spanish (Español)',
  'fr': 'French (Français)',
  'pt': 'Portuguese (Português)',
  'zh': 'Chinese (中文)',
};

/// Utility to validate and complete translations between the reference file app_en.arb and any language file
/// Usage: dart run lib/utils/arb_validator.dart [lang]
void main(List<String> args) async {
  stdout.writeln(
    '╔═══════════════════════════════════════════════════════════════╗',
  );
  stdout.writeln(
    '║         ARB Translation Validator & Auto-Completer            ║',
  );
  stdout.writeln(
    '╚═══════════════════════════════════════════════════════════════╝',
  );
  stdout.writeln('');

  final languages = args.isNotEmpty
      ? args
      : supportedLanguages.where((l) => l != 'en').toList();
  final procesados = <String, Map<String, dynamic>>{};
  final noEncontrados = <String>[];

  // Load reference file once
  const referencePath = 'lib/l10n/app_en.arb';
  final referenceFile = File(referencePath);

  if (!referenceFile.existsSync()) {
    stderr.writeln('❌ ERROR: Reference file (app_en.arb) not found!');
    exit(1);
  }

  final referenceJson = json.decode(await referenceFile.readAsString());
  final totalReferenceKeys = referenceJson.keys
      .where((key) => !key.startsWith('@') && key != '@@locale')
      .length;

  stdout.writeln(
    '📋 Reference: app_en.arb ($totalReferenceKeys content keys)\n',
  );

  for (final lang in languages) {
    final targetPath = 'lib/l10n/app_$lang.arb';
    final targetFile = File(targetPath);

    if (!targetFile.existsSync()) {
      stdout.writeln(
        '❌ ${languageNames[lang] ?? lang.toUpperCase()}: File not found\n',
      );
      noEncontrados.add(lang);
      continue;
    }

    final targetJson = json.decode(await targetFile.readAsString());

    final missingContentKeys = <String>[];
    final missingMetadataKeys = <String>[];
    final pendingKeys = <String>[];
    int addedContentKeys = 0;

    /// Inserta claves faltantes en el JSON destino, usando el valor 'PENDING' por defecto
    void insertMissingKeys(Map reference, Map target) {
      reference.forEach((key, value) {
        if (!target.containsKey(key)) {
          target[key] = value is Map ? {'description': 'PENDING'} : 'PENDING';

          if (key != '@@locale' && !key.startsWith('@')) {
            addedContentKeys++;
          }
        } else if (value is Map && target[key] is Map) {
          insertMissingKeys(value, target[key]);
        }
      });
    }

    void compareKeys(Map reference, Map target) {
      reference.forEach((key, value) {
        if (!target.containsKey(key)) {
          if (key.startsWith('@')) {
            missingMetadataKeys.add(key);
          } else if (key != '@@locale') {
            missingContentKeys.add(key);
          }
        } else {
          // Check for PENDING values
          final targetValue = target[key];
          if (targetValue == 'PENDING' ||
              (targetValue is Map && targetValue['description'] == 'PENDING')) {
            pendingKeys.add(key);
          }
        }
      });
    }

    compareKeys(referenceJson, targetJson);
    insertMissingKeys(referenceJson, targetJson);

    // Calculate statistics
    final currentContentKeys = targetJson.keys
        .where((key) => !key.startsWith('@') && key != '@@locale')
        .length;
    final completionPercentage =
        ((currentContentKeys / totalReferenceKeys) * 100).toStringAsFixed(1);
    final pendingCount = pendingKeys.where((k) => !k.startsWith('@')).length;

    // Store results for summary
    procesados[lang] = {
      'name': languageNames[lang] ?? lang.toUpperCase(),
      'totalKeys': currentContentKeys,
      'missing': missingContentKeys.length,
      'pending': pendingCount,
      'added': addedContentKeys,
      'completion': completionPercentage,
    };

    // Print report for this language
    final langName = languageNames[lang] ?? lang.toUpperCase();
    stdout.writeln(
      '┌─────────────────────────────────────────────────────────────┐',
    );
    stdout.writeln('${'│ $langName (app_$lang.arb)'.padRight(61)}│');
    stdout.writeln(
      '├─────────────────────────────────────────────────────────────┤',
    );
    stdout.writeln(
      '${'│ Content Keys: $currentContentKeys/$totalReferenceKeys ($completionPercentage% complete)'.padRight(61)}│',
    );

    if (missingContentKeys.isEmpty && pendingCount == 0) {
      stdout.writeln(
        '${'│ Status: ✅ All keys present and translated'.padRight(61)}│',
      );
    } else {
      if (missingContentKeys.isNotEmpty) {
        stdout.writeln(
          '${'│ Status: ⚠️  ${missingContentKeys.length} missing, $pendingCount pending translation'.padRight(61)}│',
        );
      } else if (pendingCount > 0) {
        stdout.writeln(
          '${'│ Status: ⚠️  $pendingCount keys pending translation'.padRight(61)}│',
        );
      }
    }
    stdout.writeln(
      '└─────────────────────────────────────────────────────────────┘',
    );

    // Show details if there are issues
    if (missingContentKeys.isNotEmpty || pendingCount > 0) {
      if (addedContentKeys > 0) {
        stdout.writeln(
          '  ✨ Added $addedContentKeys new content keys as "PENDING"',
        );
      }

      if (pendingCount > 0 && pendingCount <= 20) {
        stdout.writeln(
          '  📝 Pending translations (${pendingKeys.where((k) => !k.startsWith('@')).length}):',
        );
        for (final key
            in pendingKeys.where((k) => !k.startsWith('@')).take(20)) {
          stdout.writeln('     • $key');
        }
      } else if (pendingCount > 20) {
        stdout.writeln(
          '  📝 $pendingCount keys pending translation (showing first 10):',
        );
        for (final key
            in pendingKeys.where((k) => !k.startsWith('@')).take(10)) {
          stdout.writeln('     • $key');
        }
        stdout.writeln('     ... and ${pendingCount - 10} more');
      }
    }

    stdout.writeln('');

    // Save the updated target file with missing keys
    await targetFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(targetJson),
    );
  }

  // Print comprehensive summary
  stdout.writeln(
    '╔═══════════════════════════════════════════════════════════════╗',
  );
  stdout.writeln(
    '║                       SUMMARY REPORT                          ║',
  );
  stdout.writeln(
    '╚═══════════════════════════════════════════════════════════════╝',
  );
  stdout.writeln('');

  if (procesados.isNotEmpty) {
    stdout.writeln('📊 Translation Coverage:');
    stdout.writeln('');

    // Sort by completion percentage
    final sortedLanguages = procesados.entries.toList()
      ..sort(
        (a, b) => double.parse(
          b.value['completion'],
        ).compareTo(double.parse(a.value['completion'])),
      );

    for (final entry in sortedLanguages) {
      final data = entry.value;
      final completion = double.parse(data['completion']);
      final barLength = (completion / 5).round();
      final bar = '█' * barLength + '░' * (20 - barLength);

      String statusIcon;
      if (completion >= 100) {
        statusIcon = '✅';
      } else if (completion >= 90) {
        statusIcon = '🟡';
      } else {
        statusIcon = '🔴';
      }

      stdout.writeln(
        '  $statusIcon ${data['name'].toString().padRight(25)} $bar ${data['completion']}%',
      );

      if (data['pending'] > 0 || data['missing'] > 0) {
        final issues = <String>[];
        if (data['missing'] > 0) issues.add('${data['missing']} missing');
        if (data['pending'] > 0) issues.add('${data['pending']} pending');
        stdout.writeln('     └─ Action needed: ${issues.join(', ')}');
      }
    }

    stdout.writeln('');
    stdout.writeln('📈 Statistics:');
    final totalPending = procesados.values.fold<int>(
      0,
      (sum, data) => sum + (data['pending'] as int),
    );
    final totalAdded = procesados.values.fold<int>(
      0,
      (sum, data) => sum + (data['added'] as int),
    );
    final fullyTranslated = procesados.values
        .where((data) => data['missing'] == 0 && data['pending'] == 0)
        .length;

    stdout.writeln('  • Languages processed: ${procesados.length}');
    stdout.writeln(
      '  • Fully translated: $fullyTranslated/${procesados.length}',
    );
    stdout.writeln('  • Keys added this run: $totalAdded');
    stdout.writeln('  • Total pending translations: $totalPending');

    if (totalPending > 0) {
      stdout.writeln('');
      stdout.writeln('⚠️  ACTION REQUIRED:');
      stdout.writeln('  Replace "PENDING" values in the following files:');
      for (final entry in sortedLanguages) {
        final data = entry.value;
        if (data['pending'] > 0) {
          stdout.writeln(
            '  • lib/l10n/app_${entry.key}.arb (${data['pending']} keys)',
          );
        }
      }
    } else {
      stdout.writeln('');
      stdout.writeln('🎉 Excellent! All translations are complete!');
    }
  }

  if (noEncontrados.isNotEmpty) {
    stdout.writeln('');
    stdout.writeln('❌ Files not found: ${noEncontrados.join(", ")}');
  }

  stdout.writeln('');
  stdout.writeln(
    '═══════════════════════════════════════════════════════════════',
  );
  stdout.writeln('✅ Validation complete. All ARB files have been updated.');
  stdout.writeln(
    '═══════════════════════════════════════════════════════════════',
  );
}
