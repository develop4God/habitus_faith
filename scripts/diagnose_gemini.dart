#!/usr/bin/env dart

/// Diagnostic script to test Gemini API configuration
/// Usage: dart scripts/diagnose_gemini.dart

import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  print('🔍 Gemini API Diagnostic Tool\n');

  // 1. Check API key from environment
  final apiKey = Platform.environment['GEMINI_API_KEY'];

  if (apiKey == null || apiKey.isEmpty) {
    print('❌ GEMINI_API_KEY not found in environment');
    print('   Set it with: export GEMINI_API_KEY=your_key_here');
    exit(1);
  }

  print('✅ API Key found: ${apiKey.substring(0, 10)}...');

  if (!apiKey.startsWith('AIza')) {
    print('⚠️  Warning: API key doesn\'t start with "AIza" (expected format)');
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

  print('\n📋 Testing model availability:\n');

  for (final modelName in modelsToTest) {
    try {
      print('Testing: $modelName');
      final model = GenerativeModel(
        model: modelName,
        apiKey: apiKey,
      );

      // Try a simple generation
      final response = await model.generateContent([
        Content.text('Say "Hello" in one word only.')
      ]).timeout(const Duration(seconds: 10));

      final text = response.text ?? '';
      print('  ✅ SUCCESS - Response: ${text.trim()}');
      print('  ✅ This model works! Use: "$modelName"\n');
    } catch (e) {
      if (e.toString().contains('not found') ||
          e.toString().contains('not supported')) {
        print('  ❌ Model not available: ${e.toString().split('\n').first}');
      } else if (e.toString().contains('API_KEY')) {
        print('  ❌ API key issue: $e');
        break; // No point testing other models
      } else {
        print('  ⚠️  Error: ${e.toString().split('\n').first}');
      }
      print('');
    }
  }

  print('\n📖 Recommendations:');
  print('  1. Use the model name that showed ✅ SUCCESS above');
  print(
      '  2. Update lib/core/config/ai_config.dart with the working model name');
  print('  3. Verify your API key has Gemini API enabled in Google AI Studio');
  print(
      '  4. Check https://ai.google.dev/gemini-api/docs/models for latest model names');
}
