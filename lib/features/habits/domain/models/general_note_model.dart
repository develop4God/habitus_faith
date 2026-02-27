class GeneralNote {
  final String id;
  final String userId;
  final String content;
  final DateTime date;
  final DateTime createdAt;
  final String? petId;

  const GeneralNote({
    required this.id,
    required this.userId,
    required this.content,
    required this.date,
    required this.createdAt,
    this.petId,
  });

  GeneralNote copyWith({
    String? id,
    String? userId,
    String? content,
    DateTime? date,
    DateTime? createdAt,
    String? petId,
  }) {
    return GeneralNote(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      petId: petId ?? this.petId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
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
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      petId: json['petId'] as String?,
    );
  }

  String get dateKey => date.toIso8601String().split('T')[0];
}
