#!/usr/bin/env dart

import 'dart:developer';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

void debugPrint(Object? message) => log(message?.toString() ?? '');

void main() async {
  stdout.writeln('🔍 Gemini API Diagnostic Tool\n');

  // 1. Check API key from environment
  final apiKey = Platform.environment['GEMINI_API_KEY'];

  if (apiKey == null || apiKey.isEmpty) {
    stdout.writeln('❌ GEMINI_API_KEY not found in environment');
    stdout.writeln('   Set it with: export GEMINI_API_KEY=your_key_here');
    exit(1);
  }

  stdout.writeln('✅ API Key found: [${apiKey.substring(0, 10)}]...');

  if (!apiKey.startsWith('AIza')) {
    stdout.writeln(
      '⚠️  Warning: API key doesn\'t start with "AIza" (expected format)',
    );
  }

  // 2. Test different model names (ordered by likelihood of working)
  final modelsToTest = [
    'gemini-1.5-flash', // Most common, try first
    'gemini-1.5-pro', // Pro version
    'gemini-pro', // Legacy name
    'gemini-1.5-flash-latest', // Versioned variant
    'gemini-1.5-pro-latest', // Pro latest
    'models/gemini-1.5-flash', // With prefix (shouldn't work but test anyway)
    'models/gemini-1.5-flash-latest',
  ];

  stdout.writeln('\n📋 Testing model availability:\n');

  for (final modelName in modelsToTest) {
    try {
      stdout.writeln('Testing: $modelName');
      final model = GenerativeModel(model: modelName, apiKey: apiKey);

      // Try a simple generation
      final response = await model.generateContent([
        Content.text('Say "Hello" in one word only.')
      ]).timeout(const Duration(seconds: 10));

      final text = response.text ?? '';
      stdout.writeln('  ✅ SUCCESS - Response: ${text.trim()}');
      stdout.writeln('  ✅ This model works! Use: "$modelName"\n');
    } catch (e) {
      if (e.toString().contains('not found') ||
          e.toString().contains('not supported')) {
        stdout.writeln(
          '  ❌ Model not available: ${e.toString().split('\n').first}',
        );
      } else if (e.toString().contains('API_KEY')) {
        stdout.writeln('  ❌ API key issue: $e');
        break; // No point testing other models
      } else {
        stdout.writeln('  ⚠️  Error: ${e.toString().split('\n').first}');
      }
      stdout.writeln('');
    }
  }

  stdout.writeln('\n📖 Recommendations:');
  stdout.writeln('  1. Use the model name that showed ✅ SUCCESS above');
  stdout.writeln(
    '  2. Update lib/core/config/ai_config.dart with the working model name',
  );
  stdout.writeln(
    '  3. Verify your API key has Gemini API enabled in Google AI Studio',
  );
  stdout.writeln(
    '  4. Check https://ai.google.dev/gemini-api/docs/models for latest model names',
  );
}
