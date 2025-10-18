import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart'
    show rootBundle; // <-- ¡Este es necesario!

class BibleDbService {
  late Database _db;

  Future<void> initDb(String dbAssetPath, String dbName) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = join(documentsDirectory.path, dbName);

    if (!File(dbPath).existsSync()) {
      // Lee el asset correctamente usando rootBundle
      final data = await rootBundle.load(dbAssetPath);
      final bytes = data.buffer.asUint8List();
      await File(dbPath).writeAsBytes(bytes, flush: true);
    }

    _db = await openDatabase(dbPath, readOnly: true);
  }

  // Obtener todos los libros
  Future<List<Map<String, dynamic>>> getAllBooks() async {
    return await _db.query('books');
  }

  // Obtener el número máximo de capítulos de un libro
  Future<int> getMaxChapter(int bookNumber) async {
    final result = await _db.rawQuery(
      'SELECT MAX(chapter) as maxChapter FROM verses WHERE book_number = ?',
      [bookNumber],
    );
    return result.first['maxChapter'] as int? ?? 1;
  }

  // Obtener los versículos de un capítulo
  Future<List<Map<String, dynamic>>> getChapterVerses(
      int bookNumber, int chapter) async {
    return await _db.query(
      'verses',
      where: 'book_number = ? AND chapter = ?',
      whereArgs: [bookNumber, chapter],
    );
  }

  // (Opcional) Obtener un capítulo usando el método original
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
}
