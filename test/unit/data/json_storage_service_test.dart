import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/features/habits/data/storage/json_storage_service.dart';

void main() {
  late JsonStorageService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    service = JsonStorageService(prefs);
  });

  group('JsonStorageService', () {
    group('JSON operations', () {
      test('saves and retrieves JSON object', () async {
        final data = {'name': 'Test', 'value': 123};
        await service.saveJson('test_key', data);

        final retrieved = service.getJson('test_key');
        expect(retrieved, equals(data));
      });

      test('returns null for non-existent JSON key', () {
        final result = service.getJson('non_existent');
        expect(result, isNull);
      });

      test('saves and retrieves JSON list', () async {
        final data = [
          {'id': '1', 'name': 'Item 1'},
          {'id': '2', 'name': 'Item 2'},
        ];
        await service.saveJsonList('list_key', data);

        final retrieved = service.getJsonList('list_key');
        expect(retrieved, equals(data));
      });

      test('returns empty list for non-existent list key', () {
        final result = service.getJsonList('non_existent_list');
        expect(result, isEmpty);
      });
    });

    group('Boolean operations', () {
      test('saves and retrieves boolean', () async {
        await service.setBool('bool_key', true);
        expect(service.getBool('bool_key'), isTrue);

        await service.setBool('bool_key', false);
        expect(service.getBool('bool_key'), isFalse);
      });

      test('returns default value for non-existent boolean', () {
        expect(service.getBool('non_existent', defaultValue: true), isTrue);
        expect(service.getBool('non_existent', defaultValue: false), isFalse);
      });
    });

    group('String operations', () {
      test('saves and retrieves string', () async {
        await service.setString('string_key', 'test value');
        expect(service.getString('string_key'), equals('test value'));
      });

      test('returns null for non-existent string', () {
        expect(service.getString('non_existent'), isNull);
      });
    });

    group('Key management', () {
      test('containsKey returns true for existing key', () async {
        await service.setString('test', 'value');
        expect(service.containsKey('test'), isTrue);
      });

      test('containsKey returns false for non-existent key', () {
        expect(service.containsKey('non_existent'), isFalse);
      });

      test('removes key successfully', () async {
        await service.setString('test', 'value');
        expect(service.containsKey('test'), isTrue);

        await service.remove('test');
        expect(service.containsKey('test'), isFalse);
      });

      test('clear removes all keys', () async {
        await service.setString('key1', 'value1');
        await service.setString('key2', 'value2');
        await service.setBool('key3', true);

        await service.clear();

        expect(service.containsKey('key1'), isFalse);
        expect(service.containsKey('key2'), isFalse);
        expect(service.containsKey('key3'), isFalse);
      });
    });
  });
}
