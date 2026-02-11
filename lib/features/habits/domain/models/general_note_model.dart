class GeneralNote {
  final String id;
  final String userId;
  final String content;
  final String? petEmoji;
  final DateTime date;
  final DateTime createdAt;
  final String? petId;

  const GeneralNote({
    required this.id,
    required this.userId,
    required this.content,
    this.petEmoji,
    required this.date,
    required this.createdAt,
    this.petId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'petEmoji': petEmoji,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      if (petId != null) 'petId': petId,
    };
  }

  factory GeneralNote.fromJson(Map<String, dynamic> json) {
    return GeneralNote(
      id: json['id'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      petEmoji: json['petEmoji'] as String?,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      petId: json['petId'] as String?,
    );
  }

  String get dateKey => date.toIso8601String().split('T')[0];
}
