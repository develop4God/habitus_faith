import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/ml/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Contract tests for IPreferencesService implementations.
///
/// Any class that implements IPreferencesService must satisfy every test here.
void main() {
  group('IPreferencesService contract — SharedPreferencesService', () {
    late SharedPreferencesService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      service = SharedPreferencesService(prefs);
    });

    // ── getInt ──────────────────────────────────────────────────────────────

    test('getInt returns null for non-existent key', () {
      expect(service.getInt('no_such_key'), isNull);
    });

    test('getInt round-trips an integer', () async {
      await service.setInt('count', 42);
      expect(service.getInt('count'), 42);
    });

    test('getInt returns updated value after second setInt', () async {
      await service.setInt('count', 1);
      await service.setInt('count', 99);
      expect(service.getInt('count'), 99);
    });

    // ── getString ───────────────────────────────────────────────────────────

    test('getString returns null for non-existent key', () {
      expect(service.getString('no_such_key'), isNull);
    });

    test('getString round-trips a string', () async {
      await service.setString('key', '2025-01-01T00:00:00.000');
      expect(service.getString('key'), '2025-01-01T00:00:00.000');
    });

    test('getString returns updated value after second setString', () async {
      await service.setString('key', 'first');
      await service.setString('key', 'second');
      expect(service.getString('key'), 'second');
    });

    // ── key isolation ────────────────────────────────────────────────────────

    test('different keys do not interfere', () async {
      await service.setInt('a', 1);
      await service.setInt('b', 2);
      expect(service.getInt('a'), 1);
      expect(service.getInt('b'), 2);
    });

    test('int and string keys are independent', () async {
      await service.setInt('shared', 7);
      await service.setString('shared_str', 'hello');
      expect(service.getInt('shared'), 7);
      expect(service.getString('shared_str'), 'hello');
    });

    // ── setInt / setString return value ─────────────────────────────────────

    test('setInt returns true on success', () async {
      final result = await service.setInt('x', 0);
      expect(result, isTrue);
    });

    test('setString returns true on success', () async {
      final result = await service.setString('y', 'value');
      expect(result, isTrue);
    });
  });

  group(
      'IPreferencesService contract — SharedPreferencesService implements interface',
      () {
    test('SharedPreferencesService is an IPreferencesService', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = SharedPreferencesService(prefs);
      expect(service, isA<IPreferencesService>());
    });
  });

  group('IPreferencesService contract — platform channel failures', () {
    test('IPreferencesService implementations may surface PlatformException',
        () async {
      // Verify that a stub throwing PlatformException satisfies the interface —
      // confirming callers (e.g. AbandonmentPredictor) must guard against it.
      final throwing = _ThrowingPreferencesService();
      expect(throwing, isA<IPreferencesService>());

      await expectLater(
        () => throwing.setInt('k', 1),
        throwsA(isA<PlatformException>()),
      );
      await expectLater(
        () => throwing.setString('k', 'v'),
        throwsA(isA<PlatformException>()),
      );
      expect(() => throwing.getInt('k'), throwsA(isA<PlatformException>()));
      expect(
        () => throwing.getString('k'),
        throwsA(isA<PlatformException>()),
      );
    });

    test('getInt throws PlatformException when platform channel is unavailable',
        () {
      final throwing = _ThrowingPreferencesService();
      expect(() => throwing.getInt('any'), throwsA(isA<PlatformException>()));
    });
  });
}

/// Stub that mimics a platform channel being unavailable.
class _ThrowingPreferencesService implements IPreferencesService {
  @override
  int? getInt(String key) =>
      throw PlatformException(code: 'channel_unavailable');

  @override
  Future<bool> setInt(String key, int value) async =>
      throw PlatformException(code: 'channel_unavailable');

  @override
  String? getString(String key) =>
      throw PlatformException(code: 'channel_unavailable');

  @override
  Future<bool> setString(String key, String value) async =>
      throw PlatformException(code: 'channel_unavailable');
}
