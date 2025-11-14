import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:habitus_faith/core/services/ai/gemini_template_firestore_service.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(SetOptions(merge: true));
  });

  group('GeminiTemplateFirestoreService', () {
    late MockFirebaseFirestore mockFirestore;
    late GeminiTemplateFirestoreService service;
    late MockDocumentReference mockDocRef;
    late MockCollectionReference mockCollectionRef;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockDocRef = MockDocumentReference();
      mockCollectionRef = MockCollectionReference();
      service = GeminiTemplateFirestoreService(mockFirestore);
      // Stub collection and doc
      when(() => mockFirestore.collection('habit_templates_master'))
          .thenReturn(mockCollectionRef);
      when(() => mockCollectionRef.doc(any())).thenReturn(mockDocRef);
      // Stub set
      when(() => mockDocRef.set(any(), any()))
          .thenAnswer((_) async => Future.value());
    });

    test('saveGeminiTemplate guarda correctamente el template', () async {
      await service.saveGeminiTemplate(
        fingerprint: 'test_fp',
        profile: {'intent': 'wellness'},
        habits: [
          {'name': 'Ejemplo', 'emoji': '💪'},
        ],
        language: 'es',
        source: 'gemini',
      );

      verify(() => mockFirestore.collection('habit_templates_master'))
          .called(1);
      verify(() => mockCollectionRef.doc('test_fp')).called(1);
      verify(() => mockDocRef.set(
            any(
                that: isA<Map<String, dynamic>>()
                    .having((m) => m['fingerprint'], 'fingerprint', 'test_fp')),
            any(),
          )).called(1);
    });
  });
}
