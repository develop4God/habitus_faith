import '../models/bible_version.dart';

class BibleVersionRegistry {
  // Version codes
  static const String rvr1960 = 'RVR1960';
  static const String ntv = 'NTV';
  static const String tla = 'TLA';
  static const String peshEs = 'Pesh-es';
  static const String rv1865 = 'RV1865';

  // Language codes
  static const String spanish = 'es';
  static const String english = 'en';

  // Get all available Bible versions
  static List<BibleVersion> getAllVersions() {
    return [
      BibleVersion(
        name: 'RVR1960 Reina Valera 1960',
        assetPath: 'assets/biblia/RVR1960.SQLite3',
        dbFileName: 'RVR1960.SQLite3',
        versionCode: rvr1960,
        languageCode: spanish,
      ),
      BibleVersion(
        name: 'NTV Nueva Traducción Viviente',
        assetPath: 'assets/biblia/NTV.SQLite3',
        dbFileName: 'NTV.SQLite3',
        versionCode: ntv,
        languageCode: spanish,
      ),
      BibleVersion(
        name: 'TLA Traducción en Lenguaje Actual',
        assetPath: 'assets/biblia/TLA.SQLite3',
        dbFileName: 'TLA.SQLite3',
        versionCode: tla,
        languageCode: spanish,
      ),
      BibleVersion(
        name: 'Biblia Peshitta Nuevo Testamento',
        assetPath: 'assets/biblia/Pesh-es.SQLite3',
        dbFileName: 'Pesh-es.SQLite3',
        versionCode: peshEs,
        languageCode: spanish,
      ),
      BibleVersion(
        name: 'RV1865 Reina Valera 1865',
        assetPath: 'assets/biblia/RV1865.SQLite3',
        dbFileName: 'RV1865.SQLite3',
        versionCode: rv1865,
        languageCode: spanish,
      ),
    ];
  }

  // Get versions by language
  static List<BibleVersion> getVersionsByLanguage(String languageCode) {
    return getAllVersions()
        .where((v) => v.languageCode == languageCode)
        .toList();
  }

  // Get default version for a language
  static BibleVersion getDefaultVersion(String languageCode) {
    final versions = getVersionsByLanguage(languageCode);
    return versions.isNotEmpty ? versions.first : getAllVersions().first;
  }

  // Check if asset needs to be downloaded (for future cloud versions)
  static bool needsDownload(String versionCode) {
    // For now, all versions are bundled, so no download needed
    return false;
  }
}
