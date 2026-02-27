import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class BibleDbService {
  late Database _db;

  /// Initialise the database from an asset file.
  ///
  /// [dbAssetPath] may point to either a plain `.SQLite3` file or a
  /// gzip-compressed `.SQLite3.gz` file.  When the asset is compressed the
  /// service decompresses it transparently before writing it to the
  /// application-documents directory so that SQLite can open it normally.
  ///
  /// The local cache file is always named after the uncompressed DB so that
  /// a second launch skips the copy/decompress step.
  Future<void> initDb(String dbAssetPath, String dbName) async {
    // Resolve the local (uncompressed) cache name.
    // e.g. "RVR1960_es.SQLite3.gz" → cache as "RVR1960_es.SQLite3"
    final String localName = dbName.endsWith('.gz')
        ? dbName.substring(0, dbName.length - 3)
        : dbName;

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = join(documentsDirectory.path, localName);

    if (!File(dbPath).existsSync()) {
      // Read the asset bytes
      final data = await rootBundle.load(dbAssetPath);
      Uint8List bytes = data.buffer.asUint8List();

      // Decompress if the asset is gzip-compressed
      if (dbAssetPath.endsWith('.gz')) {
        bytes = Uint8List.fromList(GZipCodec().decode(bytes));
      }

      await File(dbPath).writeAsBytes(bytes, flush: true);
    }

    _db = await openDatabase(dbPath, readOnly: true);
  }

  // Get all books
  Future<List<Map<String, dynamic>>> getAllBooks() async {
    return await _db.query('books');
  }

  // Get the maximum chapter number for a book
  Future<int> getMaxChapter(int bookNumber) async {
    final result = await _db.rawQuery(
      'SELECT MAX(chapter) as maxChapter FROM verses WHERE book_number = ?',
      [bookNumber],
    );
    return result.first['maxChapter'] as int? ?? 1;
  }

  // Get verses from a chapter
  Future<List<Map<String, dynamic>>> getChapterVerses(
    int bookNumber,
    int chapter,
  ) async {
    return await _db.query(
      'verses',
      where: 'book_number = ? AND chapter = ?',
      whereArgs: [bookNumber, chapter],
    );
  }

  // (Optional) Get a chapter using the original method
  Future<List<Map<String, dynamic>>> getChapter({
    required int bookNumber,
    required int chapter,
    String tableName = "verses",
  }) async {
    return await _db.query(
      tableName,
      where: 'book_number = ? AND chapter = ?',
      whereArgs: [bookNumber, chapter],
    );
  }

  // Search for verses containing a phrase
  // Prioritizes exact word matches over partial matches

  // Search for verses containing a phrase
  // Prioritizes exact word matches over partial matches
  Future<List<Map<String, dynamic>>> searchVerses(String searchQuery) async {
    if (searchQuery.trim().isEmpty) return [];

    final query = searchQuery.trim();

    // Multi-word search: require all words to be present (AND)
    final queryWords = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    // If only one word, priority: exact word, then partial
    if (queryWords.length == 1) {
      final q = queryWords.first;

      // 1. Exact word match in any position, case-insensitive (using spaces or start/end)
      final exactResults = await _db.rawQuery(
        '''
        SELECT v.*, b.long_name, b.short_name, 1 as priority
        FROM verses v
        JOIN books b ON v.book_number = b.book_number
        WHERE LOWER(v.text) = ?
           OR LOWER(v.text) LIKE ?
           OR LOWER(v.text) LIKE ?
           OR LOWER(v.text) LIKE ?
        ORDER BY v.book_number, v.chapter, v.verse
        LIMIT 50
        ''',
        [
          q, // full match
          '$q %', // start of verse
          '% $q', // end of verse
          '% $q %', // surrounded by spaces
        ],
      );

      // Remove duplicates by rowid
      final exactRowids = exactResults.map((r) => r['rowid']).toSet();
      final exactRowidsStr = exactRowids.isEmpty ? '-1' : exactRowids.join(',');

      // 2. Partial matches (contains substring), excluding exact matches
      final partialResults = await _db.rawQuery(
        '''
        SELECT v.*, b.long_name, b.short_name, 2 as priority
        FROM verses v
        JOIN books b ON v.book_number = b.book_number
        WHERE LOWER(v.text) LIKE ?
          AND v.rowid NOT IN ($exactRowidsStr)
        ORDER BY v.book_number, v.chapter, v.verse
        LIMIT 50
        ''',
        ['%$q%'],
      );

      // Combine results, exact first
      return [...exactResults, ...partialResults];
    }

    // Multi-word search: require all words present (AND)
    final whereClauses =
        queryWords.map((w) => "LOWER(v.text) LIKE '%$w%'").join(' AND ');

    final results = await _db.rawQuery('''
      SELECT v.*, b.long_name, b.short_name, 1 as priority
      FROM verses v
      JOIN books b ON v.book_number = b.book_number
      WHERE $whereClauses
      ORDER BY v.book_number, v.chapter, v.verse
      LIMIT 50
      ''');

    return results;
  }

  // Find a book by name or abbreviation (case-insensitive, partial match)
  Future<Map<String, dynamic>?> findBookByName(String bookName) async {
    if (bookName.trim().isEmpty) return null;

    final searchTerm = bookName.trim();

    // Try exact match first (case-insensitive)
    var results = await _db.rawQuery(
      '''
      SELECT * FROM books 
      WHERE LOWER(long_name) = ? OR LOWER(short_name) = ?
      LIMIT 1
    ''',
      [searchTerm.toLowerCase(), searchTerm.toLowerCase()],
    );

    if (results.isNotEmpty) {
      return results.first;
    }

    // Try partial match at start of name
    results = await _db.rawQuery(
      '''
      SELECT * FROM books 
      WHERE LOWER(long_name) LIKE ? OR LOWER(short_name) LIKE ?
      ORDER BY book_number
      LIMIT 1
    ''',
      ['${searchTerm.toLowerCase()}%', '${searchTerm.toLowerCase()}%'],
    );

    if (results.isNotEmpty) {
      return results.first;
    }

    // Try contains match (for common abbreviations)
    results = await _db.rawQuery(
      '''
      SELECT * FROM books 
      WHERE LOWER(long_name) LIKE ? OR LOWER(short_name) LIKE ?
      ORDER BY book_number
      LIMIT 1
    ''',
      ['%${searchTerm.toLowerCase()}%', '%${searchTerm.toLowerCase()}%'],
    );

    return results.isNotEmpty ? results.first : null;
  }

  // Get a specific verse
  Future<Map<String, dynamic>?> getVerse({
    required int bookNumber,
    required int chapter,
    required int verse,
  }) async {
    final results = await _db.query(
      'verses',
      where: 'book_number = ? AND chapter = ? AND verse = ?',
      whereArgs: [bookNumber, chapter, verse],
      limit: 1,
    );

    return results.isNotEmpty ? results.first : null;
  }
}
