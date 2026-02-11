import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/domain/models/general_note_model.dart';

void main() {
  test('GeneralNote serializes with pet emoji', () {
    final note = GeneralNote(
      id: 'note-1',
      userId: 'user-1',
      content: 'Test note',
      petEmoji: '🐶',
      date: DateTime(2024, 10, 1),
      createdAt: DateTime(2024, 10, 1, 9, 30),
    );

    final json = note.toJson();
    expect(json['petEmoji'], '🐶');

    final restored = GeneralNote.fromJson(json);
    expect(restored.petEmoji, '🐶');
  });
}
