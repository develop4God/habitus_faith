// test/unit/services/abandonment_predictor_validation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/ml/abandonment_predictor.dart';
import '../../utils/tflite_test_stub.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AbandonmentPredictor validation', () {
    test('initialize works with fake interpreter', () async {
      // Install fake tflite interpreter so initialization doesn't try to load native libs
      await installFakeTflite(result: 0.3);

      final predictor = AbandonmentPredictor();
      await predictor.initialize();

      // With fake interpreter, predictor should report initialized
      expect(predictor.isInitialized, isTrue);

      await predictor.dispose();
      uninstallFakeTflite();
    });
  });
}
