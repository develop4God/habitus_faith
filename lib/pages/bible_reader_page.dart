import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; // Agrega share_plus a pubspec.yaml
import '../services/bible_db_service.dart';
import '../models/bible_version.dart';

class BibleReaderPage extends StatefulWidget {
  final List<BibleVersion> versions;
  const BibleReaderPage({super.key, required this.versions});

  @override
  State<BibleReaderPage> createState() => _BibleReaderPageState();
}

class _BibleReaderPageState extends State<BibleReaderPage> {
  late BibleVersion _selectedVersion;
  List<Map<String, dynamic>> _books = [];
  String? _selectedBookName;
  int? _selectedBookNumber;
  int? _selectedChapter;
  int _maxChapter = 1;
  List<Map<String, dynamic>> _verses = [];
  int? _highlightedVerse;
  String _bookSearch = '';
  double _fontSize = 20;

  List<Map<String, dynamic>> get _filteredBooks {
    if (_bookSearch.isEmpty) return _books;
    return _books
        .where((b) => b['long_name']
            .toString()
            .toLowerCase()
            .contains(_bookSearch.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _selectedVersion = widget.versions.first;
    _initVersion();
  }

  Future<void> _initVersion() async {
    _selectedVersion.service ??= BibleDbService();
    await _selectedVersion.service!.initDb(
      _selectedVersion.assetPath,
      _selectedVersion.dbFileName,
    );
    await _loadBooks();
  }

  Future<void> _loadBooks() async {
    final books = await _selectedVersion.service!.getAllBooks();
    setState(() {
      _books = books;
      if (books.isNotEmpty) {
        _selectedBookName = books[0]['short_name'];
        _selectedBookNumber = books[0]['book_number'];
      }
    });
    await _loadMaxChapter();
    await _loadVerses();
  }

  Future<void> _loadMaxChapter() async {
    if (_selectedBookNumber == null) return;
    final maxChapter =
        await _selectedVersion.service!.getMaxChapter(_selectedBookNumber!);
    setState(() {
      _maxChapter = maxChapter;
      _selectedChapter = 1;
    });
  }

  Future<void> _loadVerses() async {
    if (_selectedBookNumber == null || _selectedChapter == null) return;
    final verses = await _selectedVersion.service!.getChapterVerses(
      _selectedBookNumber!,
      _selectedChapter!,
    );
    setState(() {
      _verses = verses;
    });
  }

  String cleanVerseText(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&');
  }

  void _shareVerse(String verseText) {
    Share.share(verseText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title:
            const Text('Biblia', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Compartir versículo',
            onPressed: _highlightedVerse != null
                ? () {
                    final v = _verses[_highlightedVerse!];
                    final text =
                        '${v['long_name'] ?? ''} ${v['chapter']}:${v['verse']} ${cleanVerseText(v['text'])}';
                    _shareVerse(text);
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
            tooltip: 'Aumentar letra',
            onPressed: () {
              setState(() {
                _fontSize = (_fontSize + 2).clamp(16, 32);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.text_decrease),
            tooltip: 'Disminuir letra',
            onPressed: () {
              setState(() {
                _fontSize = (_fontSize - 2).clamp(16, 32);
              });
            },
          ),
        ],
      ),
      body: _books.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selector de versión
                  Row(
                    children: [
                      const Text('Versión:',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(width: 12),
                      DropdownButton<BibleVersion>(
                        value: _selectedVersion,
                        icon: const Icon(Icons.arrow_drop_down),
                        items: widget.versions
                            .map((v) => DropdownMenuItem<BibleVersion>(
                                  value: v,
                                  child: Text(v.name),
                                ))
                            .toList(),
                        onChanged: (ver) async {
                          if (ver == null) return;
                          setState(() {
                            _selectedVersion = ver;
                            _books = [];
                            _verses = [];
                          });
                          await _initVersion();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Buscador de libros
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar libro...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 12),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _bookSearch = val;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  // Selección de libro
                  // ...existing code...

                  // Selección de libro
                  DropdownButton<String>(
                    value: _filteredBooks
                            .any((b) => b['short_name'] == _selectedBookName)
                        ? _selectedBookName
                        : (_filteredBooks.isNotEmpty
                            ? _filteredBooks[0]['short_name']
                            : null),
                    icon: const Icon(Icons.arrow_drop_down),
                    items: _filteredBooks
                        .map((b) => DropdownMenuItem<String>(
                              value: b['short_name'],
                              child: Text(b['long_name']),
                            ))
                        .toList(),
                    onChanged: (val) async {
                      if (val == null) return;
                      final book = _filteredBooks
                          .firstWhere((b) => b['short_name'] == val);
                      setState(() {
                        _selectedBookName = val;
                        _selectedBookNumber = book['book_number'];
                        _selectedChapter = 1;
                        _highlightedVerse = null;
                      });
                      await _loadMaxChapter();
                      await _loadVerses();
                    },
                  ),

                  // Selección de capítulo
                  Row(
                    children: [
                      const Text('Capítulo:',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(width: 12),
                      DropdownButton<int>(
                        value: _selectedChapter,
                        icon: const Icon(Icons.arrow_drop_down),
                        items: List.generate(
                          _maxChapter,
                          (i) => DropdownMenuItem<int>(
                            value: i + 1,
                            child: Text('${i + 1}'),
                          ),
                        ),
                        onChanged: (val) async {
                          setState(() {
                            _selectedChapter = val;
                          });
                          await _loadVerses();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Lista de versículos
                  Expanded(
                    child: _verses.isEmpty
                        ? const Center(child: Text('No hay versículos.'))
                        : ListView.builder(
                            itemCount: _verses.length,
                            itemBuilder: (context, idx) {
                              final v = _verses[idx];
                              final isHighlighted = _highlightedVerse == idx;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _highlightedVerse = idx;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  decoration: BoxDecoration(
                                    color: isHighlighted
                                        ? Colors.yellow.withOpacity(0.2)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 8),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 2),
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '${v['verse']} ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple,
                                            fontSize: _fontSize,
                                            decoration: isHighlighted
                                                ? TextDecoration.underline
                                                : TextDecoration.none,
                                          ),
                                        ),
                                        TextSpan(
                                          text: cleanVerseText(v['text']),
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: _fontSize,
                                          ),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
