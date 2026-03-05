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

/// Utility to validate and complete translations between the reference file
/// app_en.arb and any language file.
///
/// Validates:
///   ✅ Forward: keys in reference missing from target (auto-inserts as PENDING)
///   ✅ Reverse: keys in target not in reference (orphan/ghost keys)
///   ✅ @@locale value matches the language being processed
///   ✅ Duplicate keys in the raw file (JSON parse silently drops them)
///   ✅ Completion % calculated before PENDING insertion (accurate metric)
///   ✅ File only written when changes exist (no spurious git diffs)
///
/// Usage: dart run lib/utils/arb_validator.dart [lang1 lang2 ...]
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

  final referenceJson =
      json.decode(await referenceFile.readAsString()) as Map<String, dynamic>;
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

    final rawContent = await targetFile.readAsString();

    // ── FIX #6: Detect duplicate keys before JSON parse silently drops them ──
    final duplicateKeys = _findDuplicateKeys(rawContent);

    final targetJson = json.decode(rawContent) as Map<String, dynamic>;

    final missingContentKeys = <String>[];
    final missingMetadataKeys = <String>[];
    final pendingKeys = <String>[];
    final orphanKeys = <String>[]; // FIX #2: reverse validation
    int addedContentKeys = 0;

    // ── FIX #5: Validate @@locale matches the language being processed ────────
    final declaredLocale = targetJson['@@locale'] as String?;
    final localeMismatch = declaredLocale != null && declaredLocale != lang;

    // ── FIX #1: Calculate real completion BEFORE inserting PENDING keys ───────
    final originalContentKeys = targetJson.keys
        .where((key) => !key.startsWith('@') && key != '@@locale')
        .length;
    final completionPercentage =
        ((originalContentKeys / totalReferenceKeys) * 100).toStringAsFixed(1);

    // ── Forward validation: reference → target ────────────────────────────────
    void compareKeys(
        Map<String, dynamic> reference, Map<String, dynamic> target) {
      reference.forEach((key, value) {
        if (!target.containsKey(key)) {
          if (key.startsWith('@')) {
            missingMetadataKeys.add(key);
          } else if (key != '@@locale') {
            missingContentKeys.add(key);
          }
        } else {
          final targetValue = target[key];
          if (targetValue == 'PENDING' ||
              (targetValue is Map && targetValue['description'] == 'PENDING')) {
            pendingKeys.add(key);
          }
        }
      });
    }

    // ── FIX #2: Reverse validation: target → reference (orphan detection) ─────
    void findOrphanKeys(
        Map<String, dynamic> reference, Map<String, dynamic> target) {
      target.forEach((key, value) {
        if (key != '@@locale' && !key.startsWith('@')) {
          if (!reference.containsKey(key)) {
            orphanKeys.add(key);
          }
        }
      });
    }

    // ── Auto-insert missing keys as PENDING ───────────────────────────────────
    void insertMissingKeys(
        Map<String, dynamic> reference, Map<String, dynamic> target) {
      reference.forEach((key, value) {
        if (!target.containsKey(key)) {
          target[key] = value is Map ? {'description': 'PENDING'} : 'PENDING';
          if (key != '@@locale' && !key.startsWith('@')) {
            addedContentKeys++;
          }
        } else if (value is Map && target[key] is Map) {
          insertMissingKeys(value as Map<String, dynamic>,
              target[key] as Map<String, dynamic>);
        }
      });
    }

    compareKeys(referenceJson, targetJson);
    findOrphanKeys(referenceJson, targetJson); // FIX #2
    insertMissingKeys(referenceJson, targetJson);

    final pendingCount = pendingKeys.where((k) => !k.startsWith('@')).length;

    // Store results for summary
    procesados[lang] = {
      'name': languageNames[lang] ?? lang.toUpperCase(),
      'originalKeys': originalContentKeys,
      'missing': missingContentKeys.length,
      'orphans': orphanKeys.length, // FIX #2
      'pending': pendingCount,
      'added': addedContentKeys,
      'completion': completionPercentage,
      'localeMismatch': localeMismatch,
      'duplicates': duplicateKeys,
    };

    // ── Print report ──────────────────────────────────────────────────────────
    final langName = languageNames[lang] ?? lang.toUpperCase();
    stdout.writeln(
      '┌─────────────────────────────────────────────────────────────┐',
    );
    stdout.writeln('${'│ $langName (app_$lang.arb)'.padRight(61)}│');
    stdout.writeln(
      '├─────────────────────────────────────────────────────────────┤',
    );
    // FIX #1: completionPercentage is now calculated from originalContentKeys
    stdout.writeln(
      '${'│ Content Keys: $originalContentKeys/$totalReferenceKeys ($completionPercentage% complete)'.padRight(61)}│',
    );

    final hasIssues = missingContentKeys.isNotEmpty ||
        pendingCount > 0 ||
        orphanKeys.isNotEmpty ||
        localeMismatch ||
        duplicateKeys.isNotEmpty;

    if (!hasIssues) {
      stdout.writeln(
        '${'│ Status: ✅ All keys present, translated, no orphans'.padRight(61)}│',
      );
    } else {
      final issues = <String>[];
      if (missingContentKeys.isNotEmpty) {
        issues.add('${missingContentKeys.length} missing');
      }
      if (pendingCount > 0) issues.add('$pendingCount pending');
      if (orphanKeys.isNotEmpty) {
        issues.add('${orphanKeys.length} orphan'); // FIX #2
      }
      if (localeMismatch) issues.add('@@locale mismatch'); // FIX #5
      if (duplicateKeys.isNotEmpty) {
        issues.add('${duplicateKeys.length} duplicate'); // FIX #6
      }
      stdout.writeln(
        '${'│ Status: ⚠️  ${issues.join(', ')}  '.padRight(61)}│',
      );
    }
    stdout.writeln(
      '└─────────────────────────────────────────────────────────────┘',
    );

    // Detail blocks
    if (addedContentKeys > 0) {
      stdout.writeln(
        '  ✨ Added $addedContentKeys new content keys as "PENDING"',
      );
    }

    if (pendingCount > 0) {
      final display = pendingKeys.where((k) => !k.startsWith('@')).toList();
      stdout.writeln('  📝 Pending translations (${display.length}):');
      for (final key in display.take(20)) {
        stdout.writeln('     • $key');
      }
      if (display.length > 20) {
        stdout.writeln('     ... and ${display.length - 20} more');
      }
    }

    // FIX #2: Orphan key report
    if (orphanKeys.isNotEmpty) {
      stdout.writeln(
        '  🚨 Orphan keys (in target, NOT in reference — remove or add to en.arb):',
      );
      for (final key in orphanKeys.take(20)) {
        stdout.writeln('     • $key');
      }
      if (orphanKeys.length > 20) {
        stdout.writeln('     ... and ${orphanKeys.length - 20} more');
      }
    }

    // FIX #5: @@locale mismatch report
    if (localeMismatch) {
      stdout.writeln(
        '  ❌ @@locale mismatch: file declares "$declaredLocale", expected "$lang"',
      );
    }

    // FIX #6: Duplicate key report
    if (duplicateKeys.isNotEmpty) {
      stdout.writeln(
        '  ❌ Duplicate keys detected (JSON kept last value — fix manually):',
      );
      for (final key in duplicateKeys) {
        stdout.writeln('     • $key');
      }
    }

    stdout.writeln('');

    // FIX #3 + #4: Only write when changes exist — preserves ordering, avoids
    // spurious git diffs. insertMissingKeys appends to existing map so key
    // order from the original file is preserved for unchanged keys.
    if (addedContentKeys > 0) {
      await targetFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(targetJson),
      );
    }
  }

  // ── Summary report ────────────────────────────────────────────────────────
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

    final sortedLanguages = procesados.entries.toList()
      ..sort(
        (a, b) => double.parse(b.value['completion'] as String)
            .compareTo(double.parse(a.value['completion'] as String)),
      );

    for (final entry in sortedLanguages) {
      final data = entry.value;
      final completion = double.parse(data['completion'] as String);
      final orphans = data['orphans'] as int;
      final localeMismatch = data['localeMismatch'] as bool;
      final duplicates = data['duplicates'] as List<String>;
      final barLength = (completion / 5).round().clamp(0, 20);
      final bar = '█' * barLength + '░' * (20 - barLength);

      String statusIcon;
      if (completion >= 100 &&
          orphans == 0 &&
          !localeMismatch &&
          duplicates.isEmpty) {
        statusIcon = '✅';
      } else if (completion >= 90) {
        statusIcon = '🟡';
      } else {
        statusIcon = '🔴';
      }

      stdout.writeln(
        '  $statusIcon ${data['name'].toString().padRight(25)} $bar ${data['completion']}%',
      );

      final issues = <String>[];
      if ((data['missing'] as int) > 0) {
        issues.add('${data['missing']} missing');
      }
      if ((data['pending'] as int) > 0) {
        issues.add('${data['pending']} pending');
      }
      if (orphans > 0) issues.add('$orphans orphan');
      if (localeMismatch) issues.add('@@locale mismatch');
      if (duplicates.isNotEmpty) issues.add('${duplicates.length} duplicate');

      if (issues.isNotEmpty) {
        stdout.writeln('     └─ Action needed: ${issues.join(', ')}');
      }
    }

    stdout.writeln('');
    stdout.writeln('📈 Statistics:');
    final totalPending =
        procesados.values.fold<int>(0, (sum, d) => sum + (d['pending'] as int));
    final totalOrphans =
        procesados.values.fold<int>(0, (sum, d) => sum + (d['orphans'] as int));
    final totalAdded =
        procesados.values.fold<int>(0, (sum, d) => sum + (d['added'] as int));
    final fullyTranslated = procesados.values
        .where((d) =>
            d['missing'] == 0 &&
            d['pending'] == 0 &&
            d['orphans'] == 0 &&
            !(d['localeMismatch'] as bool) &&
            (d['duplicates'] as List).isEmpty)
        .length;

    stdout.writeln('  • Languages processed: ${procesados.length}');
    stdout.writeln('  • Fully clean: $fullyTranslated/${procesados.length}');
    stdout.writeln('  • Keys added this run: $totalAdded');
    stdout.writeln('  • Total pending translations: $totalPending');
    stdout.writeln('  • Total orphan keys: $totalOrphans');

    final hasActionItems = totalPending > 0 || totalOrphans > 0;

    if (hasActionItems) {
      stdout.writeln('');
      stdout.writeln('⚠️  ACTION REQUIRED:');
      if (totalPending > 0) {
        stdout.writeln('  📝 Replace "PENDING" values in:');
        for (final entry in sortedLanguages) {
          final data = entry.value;
          if ((data['pending'] as int) > 0) {
            stdout.writeln(
              '     • lib/l10n/app_${entry.key}.arb (${data['pending']} keys)',
            );
          }
        }
      }
      if (totalOrphans > 0) {
        stdout.writeln('  🚨 Remove or promote orphan keys in:');
        for (final entry in sortedLanguages) {
          final data = entry.value;
          if ((data['orphans'] as int) > 0) {
            stdout.writeln(
              '     • lib/l10n/app_${entry.key}.arb (${data['orphans']} orphan keys)',
            );
          }
        }
      }
    } else {
      stdout.writeln('');
      stdout.writeln('🎉 Excellent! All translations are complete and clean!');
    }
  }

  if (noEncontrados.isNotEmpty) {
    stdout.writeln('');
    stdout.writeln('❌ Files not found: ${noEncontrados.join(', ')}');
  }

  // ── Exit code ─────────────────────────────────────────────────────────────
  // Exit 1 if any language has actionable issues — ensures CI pipelines fail.
  final hasFailures = procesados.values.any((d) =>
      (d['missing'] as int) > 0 ||
      (d['pending'] as int) > 0 ||
      (d['orphans'] as int) > 0 ||
      (d['localeMismatch'] as bool) ||
      (d['duplicates'] as List).isNotEmpty) ||
      noEncontrados.isNotEmpty;

  stdout.writeln('');
  stdout.writeln(
    '═══════════════════════════════════════════════════════════════',
  );
  stdout.writeln(hasFailures ? '❌ Validation failed.' : '✅ Validation complete.');
  stdout.writeln(
    '═══════════════════════════════════════════════════════════════',
  );

  if (hasFailures) exit(1);
}

/// FIX #6: Detect duplicate CONTENT keys (not metadata field names).
///
/// ARB files have structure:
///   "contentKey": "value",
///   "@contentKey": { "description": "...", "type": "String", ... }
///
/// Metadata blocks contain field names like "description", "type", "placeholders"
/// etc. These are structural JSON and appear in every metadata block.
/// We should only flag REAL duplicates (same content key appearing twice).
///
/// Strategy: json.decode silently drops duplicate keys (last value wins), so
/// we cannot rely on the parsed map to detect them. Go straight to line-by-line
/// raw parsing — only top-level content keys (2-space indent, no @ prefix).
List<String> _findDuplicateKeys(String rawContent) {
  try {
    // Validate JSON is parseable at all — if not, bail early
    json.decode(rawContent);

    // Find which ones are duplicated by checking against the raw file
    // Parse line-by-line to detect actual duplicates in the file
    final lines = rawContent.split('\n');
    final seenContentKeys = <String>{};
    final realDuplicates = <String>{};

    for (final line in lines) {
      // Match only top-level keys (those at indentation level 2 spaces, not inside metadata)
      final match = RegExp(r'^\s{2}"([^@][^"]*?)"\s*:').firstMatch(line);
      if (match != null) {
        final key = match.group(1)!;
        // If we've seen this key before at top level, it's a real duplicate
        if (!seenContentKeys.add(key)) {
          realDuplicates.add(key);
        }
      }
    }

    return realDuplicates.toList()..sort();
  } catch (e) {
    // If JSON parsing fails, return empty list (let JSON parser report the error)
    return [];
  }
}
