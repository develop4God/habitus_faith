import 'bible_db_service.dart';

class BibleVersion {
  final String id;
  final String name;
  final String language;
  final String languageCode;
  final String assetPath;
  final String dbFileName;
  final bool isDownloaded;

  BibleVersion({
    String? id,
    required this.name,
    required this.language,
    required this.languageCode,
    required this.assetPath,
    required this.dbFileName,
    this.isDownloaded = true,
  }) : id = id ?? name; // Use name as id if not provided

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BibleVersion &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
