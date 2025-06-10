import 'package:flutter/material.dart';
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
  final Set<String> _selectedVerses = {}; // formato: "book|chapter|verse"
  final double _fontSize = 20;
  bool _bottomSheetOpen = false;

  List<Map<String, dynamic>> get _filteredBooks {
    // Implementa tu lógica de filtrado si tienes buscador
    return _books;
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
        _selectedChapter = 1;
      }
    });
    await _loadMaxChapter();
    await _loadVerses();
  }

  Future<void> _loadMaxChapter() async {
    if (_selectedBookNumber == null) return;
    final max =
        await _selectedVersion.service!.getMaxChapter(_selectedBookNumber!);
    setState(() {
      _maxChapter = max;
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

  void _onVerseTap(int verseNumber) {
    final key = "$_selectedBookName|$_selectedChapter|$verseNumber";
    setState(() {
      if (_selectedVerses.contains(key)) {
        _selectedVerses.remove(key);
      } else {
        _selectedVerses.add(key);
      }
    });
    if (_selectedVerses.isNotEmpty && !_bottomSheetOpen) {
      _showBottomSheet();
    } else if (_selectedVerses.isEmpty && _bottomSheetOpen) {
      Navigator.of(context).pop();
      _bottomSheetOpen = false;
    }
  }

  void _showBottomSheet() {
    _bottomSheetOpen = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.22,
          minChildSize: 0.18,
          maxChildSize: 0.5,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                // Si se deseleccionan todos, cerrar el sheet
                if (_selectedVerses.isEmpty) {
                  Future.delayed(Duration.zero, () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  });
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, bottom: 4),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 4),
                      child: Text(
                        _getCompactReference(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Colores de subrayado
                        ...[
                          Colors.yellow[200],
                          Colors.green[200],
                          Colors.blue[200],
                          Colors.purple[100],
                        ].map((color) => GestureDetector(
                              onTap: () {
                                // Aquí puedes guardar el color para los versículos seleccionados
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                              ),
                            )),
                        // Favorito
                        IconButton(
                          icon: const Icon(Icons.bookmark_border,
                              color: Colors.black54),
                          onPressed: () {
                            // Lógica para guardar como favorito
                          },
                          tooltip: 'Favorito',
                        ),
                        // Nota
                        IconButton(
                          icon: const Icon(Icons.sticky_note_2_outlined,
                              color: Colors.black54),
                          onPressed: () {
                            // Lógica para agregar nota
                          },
                          tooltip: 'Nota',
                        ),
                        // Compartir
                        IconButton(
                          icon: const Icon(Icons.share_outlined,
                              color: Colors.black54),
                          onPressed: () {
                            // Lógica para compartir
                          },
                          tooltip: 'Compartir',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.keyboard_arrow_up,
                            color: Colors.grey, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          "Desliza hacia arriba para ver más",
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 13),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        children: const [
                          SizedBox(height: 24),
                          Center(
                            child: Text(
                              "Próximamente nuevas opciones",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    ).whenComplete(() {
      setState(() {
        _bottomSheetOpen = false;
        _selectedVerses.clear();
      });
    });
  }

  String _getCompactReference() {
    // Agrupa y compacta las referencias seleccionadas
    // Formato: Libro Capítulo:vers,vers-rango; OtroLibro Capítulo:vers
    if (_selectedVerses.isEmpty) return '';
    // Parsear y agrupar
    final Map<String, Map<int, List<int>>> grouped = {};
    for (var key in _selectedVerses) {
      final parts = key.split('|');
      final book = parts[0];
      final chapter = int.parse(parts[1]);
      final verse = int.parse(parts[2]);
      grouped.putIfAbsent(book, () => {});
      grouped[book]!.putIfAbsent(chapter, () => []);
      grouped[book]![chapter]!.add(verse);
    }
    List<String> refs = [];
    grouped.forEach((book, chapters) {
      chapters.forEach((chapter, verses) {
        verses.sort();
        List<String> verseRefs = [];
        int? start;
        int? prev;
        for (var v in verses) {
          if (start == null) {
            start = v;
            prev = v;
          } else if (v == prev! + 1) {
            prev = v;
          } else {
            if (start == prev) {
              verseRefs.add("$start");
            } else {
              verseRefs.add("$start-$prev");
            }
            start = v;
            prev = v;
          }
        }
        if (start != null) {
          if (start == prev) {
            verseRefs.add("$start");
          } else {
            verseRefs.add("$start-$prev");
          }
        }
        refs.add("$book $chapter:${verseRefs.join(',')}");
      });
    });
    return refs.join("; ");
  }

  // >>> FUNCIÓN PARA LIMPIAR EL TEXTO DEL VERSÍCULO ACTUALIZADA AQUÍ <<<
  String _cleanVerseText(String text) {
    // Elimina <pb/>
    String cleanedText = text.replaceAll('<pb/>', '');
    // Elimina cualquier contenido entre corchetes (incluyendo los corchetes)
    cleanedText = cleanedText.replaceAll(RegExp(r'\[.*?\]'), '');
    // Elimina la etiqueta <f></f> (y su contenido)
    cleanedText = cleanedText.replaceAll(RegExp(r'<f>.*?</f>'), '');
    return cleanedText.trim(); // Elimina espacios al inicio o final
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedBookName ?? ''),
        actions: [
          // >>> SELECTOR DE VERSIONES MEJORADO AQUÍ <<<
          // Siempre muestra el DropdownButton, incluso si solo hay una versión,
          // para asegurar que el componente siempre esté presente si lo necesitas.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<BibleVersion>(
              value: _selectedVersion,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              underline: Container(), // Para remover la línea por defecto
              onChanged: (BibleVersion? newVersion) async {
                if (newVersion != null && newVersion != _selectedVersion) {
                  setState(() {
                    _selectedVersion = newVersion;
                    // Reiniciar el estado del libro/capítulo para la nueva versión
                    _selectedBookName = null;
                    _selectedBookNumber = null;
                    _selectedChapter = null;
                    _maxChapter = 1;
                    _verses = [];
                    _selectedVerses.clear();
                  });
                  await _initVersion(); // Re-inicializa la base de datos y carga datos para la nueva versión
                }
              },
              items: widget.versions.map((version) {
                return DropdownMenuItem<BibleVersion>(
                  value: version,
                  child: Text(
                    version.name,
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                );
              }).toList(),
            ),
          ),
          // Botón de búsqueda (lo implementaremos después de confirmar esto)
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Lógica para abrir el buscador de versículos o palabras
            },
          ),
        ],
      ),
      body: _books.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
              child: Column(
                children: [
                  // Selector de libro y capítulo
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          value: _filteredBooks.any(
                                  (b) => b['short_name'] == _selectedBookName)
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
                              _selectedVerses.clear();
                            });
                            await _loadMaxChapter();
                            await _loadVerses();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<int>(
                        value: _selectedChapter,
                        icon: const Icon(Icons.arrow_drop_down),
                        items: List.generate(_maxChapter, (i) => i + 1)
                            .map((ch) => DropdownMenuItem<int>(
                                  value: ch,
                                  child: Text(ch.toString()),
                                ))
                            .toList(),
                        onChanged: (val) async {
                          if (val == null) return;
                          setState(() {
                            _selectedChapter = val;
                            _selectedVerses.clear();
                          });
                          await _loadVerses();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _verses.isEmpty
                        ? const Center(child: Text("No hay versículos"))
                        : ListView.builder(
                            itemCount: _verses.length,
                            itemBuilder: (context, idx) {
                              final verse = _verses[idx];
                              final verseNumber = verse['verse'];
                              final key =
                                  "$_selectedBookName|$_selectedChapter|$verseNumber";
                              final isSelected = _selectedVerses.contains(key);
                              return GestureDetector(
                                onTap: () => _onVerseTap(verseNumber),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 2),
                                  decoration: isSelected
                                      ? const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.grey,
                                              width: 2,
                                              style: BorderStyle.solid,
                                            ),
                                          ),
                                        )
                                      : null,
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: _fontSize,
                                        color: Colors.black,
                                        fontFamily: 'Serif',
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "${verse['verse']} ",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                            fontSize: 15,
                                          ),
                                        ),
                                        TextSpan(
                                          text: _cleanVerseText(verse['text']),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: "Inicio"),
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined), label: "Biblia"),
          BottomNavigationBarItem(
              icon: Icon(Icons.check_box_outlined), label: "Planes"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Descubre"),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Más"),
        ],
        currentIndex: 1,
        onTap: (idx) {
          // Navegación entre secciones
        },
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
