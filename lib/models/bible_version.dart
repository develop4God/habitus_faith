import '../services/bible_db_service.dart';

class BibleVersion {
  final String name;
  final String assetPath;
  final String dbFileName;
  final String versionCode;
  final String languageCode;
  BibleDbService? service;

  BibleVersion({
    required this.name,
    required this.assetPath,
    required this.dbFileName,
    this.versionCode = '',
    this.languageCode = 'es',
    this.service,
  });
}
