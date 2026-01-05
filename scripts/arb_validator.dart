import 'dart:convert';
import 'dart:io';

/// List of supported languages (from app_localizations.dart)
const supportedLanguages = [
  'en',
  'es',
  'fr',
  'pt',
  'zh',
];

/// Utility to validate and complete translations between the reference file app_en.arb and any language file
/// Usage: dart run scripts/arb_validator.dart [lang]
void main(List<String> args) async {
  stdout.writeln('Starting ARB language validation...');
  final languages = args.isNotEmpty ? args : supportedLanguages;
  final procesados = <String>[];
  final noEncontrados = <String>[];

  for (final lang in languages) {
    final referencePath = 'lib/l10n/app_en.arb'; // Usar inglés como template
    final targetPath = 'lib/l10n/app_${lang}.arb';

    final referenceFile = File(referencePath);
    final targetFile = File(targetPath);

    if (!referenceFile.existsSync() || !targetFile.existsSync()) {
      stdout.writeln('❌ Reference or translation file not found ($lang).');
      noEncontrados.add(lang);
      continue;
    }
    procesados.add(lang);

    final referenceJson = json.decode(await referenceFile.readAsString());
    final targetJson = json.decode(await targetFile.readAsString());

    final missingKeys = <String>[];
    final incompleteKeys = <String>[];
    int pendingCount = 0;

    /// Inserta claves faltantes en el JSON destino, usando el valor 'PENDING' por defecto
    void insertMissingKeys(Map reference, Map target) {
      reference.forEach((key, value) {
        if (!target.containsKey(key)) {
          if (value is Map) {
            target[key] = {};
            insertMissingKeys(value, target[key]);
          } else {
            target[key] = 'PENDING';
            pendingCount++;
          }
        } else if (value is Map && target[key] is Map) {
          insertMissingKeys(value, target[key]);
        }
      });
    }

    void compareKeys(Map reference, Map target, String prefix) {
      reference.forEach((key, value) {
        final fullKey = prefix.isEmpty ? key : '$prefix.$key';
        if (target.containsKey(key)) {
          if (value is Map && target[key] is Map) {
            compareKeys(value, target[key], fullKey);
          } else if (value is String) {
            if (target[key] is! String || target[key].trim().isEmpty) {
              incompleteKeys.add(fullKey);
            }
          }
        } else {
          missingKeys.add(fullKey);
        }
      });
    }

    compareKeys(referenceJson, targetJson, '');
    insertMissingKeys(referenceJson, targetJson);

    stdout.writeln(
      '==== ARB TRANSLATION VALIDATION AND COMPLETION REPORT ($lang) ====');
    if (missingKeys.isEmpty && incompleteKeys.isEmpty) {
      stdout.writeln('✅ All keys are present and complete.');
    } else {
      if (missingKeys.isNotEmpty) {
        stdout.writeln('❌ Missing keys in app_${lang}.arb:');
        for (final k in missingKeys) {
          stdout.writeln('  - $k');
        }
      }
      if (incompleteKeys.isNotEmpty) {
        stdout.writeln('⚠️ Incomplete or empty keys in app_${lang}.arb:');
        for (final k in incompleteKeys) {
          stdout.writeln('  - $k');
        }
      }
    }

    // Save the updated target file with missing keys
    await targetFile.writeAsString(
      JsonEncoder.withIndent('  ').convert(targetJson),
    );
    if (pendingCount > 0) {
      stdout.writeln(
        '✅ app_${lang}.arb updated: $pendingCount new keys added as "PENDING".',
      );
    } else {
      stdout.writeln('ℹ️ No new keys added. app_${lang}.arb was already complete.');
    }
    stdout.writeln('');
  }
  stdout.writeln('--- FINAL SUMMARY ---');
  stdout.writeln('Languages processed successfully: ${procesados.join(", ")}');
  if (noEncontrados.isNotEmpty) {
    stdout.writeln('Languages not found: ${noEncontrados.join(", ")}');
  } else {
    stdout.writeln('All language files were found and validated.');
  }
}

