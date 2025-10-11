import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/bible_db_service.dart';
import '../models/bible_version.dart';
import '../widgets/app_bar_constants.dart';
import '../utils/theme_constants.dart';
import '../utils/copyright_utils.dart';
import '../utils/bubble_constants.dart';
import '../providers/devocional_provider.dart';

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
  bool _showNavigationBubble = false;
  String _currentLanguage = 'es';

  List<Map<String, dynamic>> get _filteredBooks {
    return _books;
  }

  @override
  void initState() {
    super.initState();
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    final provider = Provider.of<DevocionalProvider>(context, listen: false);
    _currentLanguage = provider.selectedLanguage;

    // Load last position or use default
    final lastPosition = await provider.getLastPosition();
    if (lastPosition != null) {
      final versionCode = lastPosition['version'];
      _selectedVersion = widget.versions.firstWhere(
        (v) => v.versionCode == versionCode,
        orElse: () => widget.versions.first,
      );
    } else {
      _selectedVersion = widget.versions.first;
    }

    // Check if navigation bubble should be shown
    _showNavigationBubble = await BubbleUtils.shouldShowBubble(
        BubbleConstants.bibleNavigationBubble);

    await _initVersion();

    // Load last position if available
    if (lastPosition != null) {
      setState(() {
        _selectedBookNumber = lastPosition['bookNumber'];
        _selectedChapter = lastPosition['chapter'];
      });
      await _loadMaxChapter();
      await _loadVerses();
    }
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
      if (books.isNotEmpty && _selectedBookNumber == null) {
        _selectedBookName = books[0]['short_name'];
        _selectedBookNumber = books[0]['book_number'];
        _selectedChapter = 1;
      } else if (_selectedBookNumber != null) {
        final book = books.firstWhere(
          (b) => b['book_number'] == _selectedBookNumber,
          orElse: () => books[0],
        );
        _selectedBookName = book['short_name'];
      }
    });
    if (_selectedBookNumber != null) {
      await _loadMaxChapter();
      await _loadVerses();
    }
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

    // Save last position
    if (!mounted) return;
    final provider = Provider.of<DevocionalProvider>(context, listen: false);
    await provider.saveLastPosition(
      _selectedVersion.versionCode,
      _selectedBookNumber!,
      _selectedChapter!,
    );
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

  void _onSharePressed() async {
    final text = _getSelectedVersesText();
    await Share.share(text);
    if (!mounted) return;
    _showSnackBar(context, 'Compartido exitosamente');
  }

  void _onCopyPressed() async {
    final text = _getSelectedVersesText();
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    _showSnackBar(context, 'Copiado al portapapeles');
  }

  String _getSelectedVersesText() {
    final List<String> versesText = [];
    for (var key in _selectedVerses) {
      final parts = key.split('|');
      final chapter = parts[1];
      final verseNum = parts[2];
      final verse = _verses.firstWhere(
        (v) => v['verse'].toString() == verseNum,
        orElse: () => {'text': ''},
      );
      versesText.add(
          '$_selectedBookName $chapter:$verseNum - ${_cleanVerseText(verse['text'])}');
    }
    return versesText.join('\n\n');
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ThemeConstants.getSnackBarBackground(context),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showBottomSheet() {
    _bottomSheetOpen = true;
    final scaffoldContext = context;
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
                if (_selectedVerses.isEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (Navigator.of(scaffoldContext).canPop()) {
                      Navigator.of(scaffoldContext).pop();
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
                        IconButton(
                          icon: const Icon(Icons.content_copy,
                              color: Colors.black54),
                          onPressed: _onCopyPressed,
                          tooltip: 'Copiar',
                        ),
                        IconButton(
                          icon: const Icon(Icons.share_outlined,
                              color: Colors.black54),
                          onPressed: _onSharePressed,
                          tooltip: 'Compartir',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
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
    if (_selectedVerses.isEmpty) return '';
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

  String _cleanVerseText(String text) {
    String cleanedText = text.replaceAll('<pb/>', '');
    cleanedText = cleanedText.replaceAll(RegExp(r'\[.*?\]'), '');
    cleanedText = cleanedText.replaceAll(RegExp(r'<f>.*?</f>'), '');
    return cleanedText.trim();
  }

  Future<void> _onNavigationTap() async {
    if (_showNavigationBubble) {
      await BubbleUtils.markAsShown(BubbleConstants.bibleNavigationBubble);
      setState(() {
        _showNavigationBubble = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _selectedBookName ?? 'Biblia',
        subtitle: _selectedVersion.name,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<BibleVersion>(
              value: _selectedVersion,
              icon: const Icon(Icons.arrow_drop_down,
                  color: ThemeConstants.onPrimaryColor),
              underline: Container(),
              dropdownColor: Colors.white,
              onChanged: (BibleVersion? newVersion) async {
                if (newVersion != null && newVersion != _selectedVersion) {
                  setState(() {
                    _selectedVersion = newVersion;
                    _selectedBookName = null;
                    _selectedBookNumber = null;
                    _selectedChapter = null;
                    _maxChapter = 1;
                    _verses = [];
                    _selectedVerses.clear();
                  });
                  await _initVersion();
                  if (!mounted) return;
                  _showSnackBar(
                    context,
                    'Versión cambiada a ${newVersion.name}',
                  );
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
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.search,
                    color: ThemeConstants.onPrimaryColor),
                onPressed: () {
                  // TODO: Implement search
                },
              ),
            ],
          ),
        ],
      ),
      body: _books.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: Row(
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
                          isExpanded: true,
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
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
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
                              await _onNavigationTap();
                              setState(() {
                                _selectedChapter = val;
                                _selectedVerses.clear();
                              });
                              await _loadVerses();
                            },
                          ),
                          if (_showNavigationBubble)
                            Positioned(
                              top: -8,
                              right: -8,
                              child: BubbleConstants.buildBadge(
                                text: 'Nuevo',
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _verses.isEmpty
                      ? const Center(child: Text("No hay versículos"))
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: _verses.length + 1,
                          itemBuilder: (context, idx) {
                            if (idx == _verses.length) {
                              // Copyright disclaimer at the bottom
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  CopyrightUtils.getCopyright(
                                    _selectedVersion.versionCode,
                                    _currentLanguage,
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }

                            final verse = _verses[idx];
                            final verseNumber = verse['verse'];
                            final key =
                                "$_selectedBookName|$_selectedChapter|$verseNumber";
                            final isSelected = _selectedVerses.contains(key);
                            return GestureDetector(
                              onTap: () => _onVerseTap(verseNumber),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 12),
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
    );
  }
}
