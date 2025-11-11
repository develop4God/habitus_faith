import 'package:cloud_firestore/cloud_firestore.dart';

class GeminiTemplateFirestoreService {
  final FirebaseFirestore firestore;

  GeminiTemplateFirestoreService(this.firestore);

  Future<void> saveGeminiTemplate({
    required String fingerprint,
    required Map<String, dynamic> profile,
    required List<Map<String, dynamic>> habits,
    required String language,
    required String source,
  }) async {
    final docRef = firestore.collection('habit_templates_master').doc(fingerprint);
    await docRef.set({
      'fingerprint': fingerprint,
      'profile': profile,
      'habits': habits,
      'language': language,
      'source': source,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

