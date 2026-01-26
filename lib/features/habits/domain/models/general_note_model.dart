class GeneralNote {
  final String id;
  final String userId;
  final String content;
  final DateTime date;
  final DateTime createdAt;

  const GeneralNote({
    required this.id,
    required this.userId,
    required this.content,
    required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GeneralNote.fromJson(Map<String, dynamic> json) {
    return GeneralNote(
      id: json['id'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  String get dateKey => date.toIso8601String().split('T')[0];
}
