import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../providers/bible_providers.dart';
import '../bible_reader_core/bible_reader_core.dart';

/// Main Bible Reader Page using Riverpod for state management
class BibleReaderPage extends ConsumerStatefulWidget {
  const BibleReaderPage({super.key});

  @override
  ConsumerState<BibleReaderPage> createState() => _BibleReaderPageState();
}

class _BibleReaderPageState extends ConsumerState<BibleReaderPage> {
  @override
  void initState() {
    super.initState();
    // Initialize Bible reader with device language
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bibleReaderProvider.notifier).initialize('es');
    });
  }

  String _cleanVerseText(String text) {
    return BibleTextNormalizer.clean(text);
  }

  String _formatVerseReference(BibleReaderState state) {
    if (state.selectedVerses.isEmpty) return '';
    // Simple reference formatting
    final firstKey = state.selectedVerses.first.split('|');
    if (firstKey.length == 3) {
      return '${firstKey[0]} ${firstKey[1]}:${firstKey[2]}';
    }
    return '';
  }

  String _getSelectedVersesText(BibleReaderState state) {
    if (state.selectedVerses.isEmpty) return '';
    
    final buffer = StringBuffer();
    for (final verseKey in state.selectedVerses) {
      final parts = verseKey.split('|');
      if (parts.length == 3) {
        final verseNumber = int.tryParse(parts[2]);
        if (verseNumber != null) {
          final verse = state.verses.firstWhere(
            (v) => v['verse'] == verseNumber,
            orElse: () => {},
          );
          if (verse.isNotEmpty) {
            buffer.writeln('${verse['verse']} ${_cleanVerseText(verse['text'])}');
          }
        }
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bibleReaderProvider);
    final notifier = ref.read(bibleReaderProvider.notifier);

    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(state.selectedBookName ?? 'Bible'),
        actions: [
          // Version selector
          if (state.availableVersions.isNotEmpty)
            PopupMenuButton<BibleVersion>(
              icon: const Icon(Icons.library_books),
              tooltip: 'Select Version',
              onSelected: (version) {
                notifier.changeVersion(version);
              },
              itemBuilder: (context) => state.availableVersions
                  .map((version) => PopupMenuItem(
                        value: version,
                        child: Text(version.name),
                      ))
                  .toList(),
            ),
          // Font size controls
          IconButton(
            icon: const Icon(Icons.format_size),
            tooltip: 'Font Size',
            onPressed: () {
              notifier.toggleFontControls();
            },
          ),
        ],
      ),
      body: state.books.isEmpty
          ? const Center(child: Text('Loading books...'))
          : Column(
              children: [
                // Font size control strip
                if (state.showFontControls)
                  Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const Text('Font Size:'),
                        Expanded(
                          child: Slider(
                            value: state.fontSize,
                            min: 12.0,
                            max: 32.0,
                            divisions: 20,
                            label: state.fontSize.round().toString(),
                            onChanged: (value) {
                              notifier.setFontSize(value);
                            },
                          ),
                        ),
                        Text('${state.fontSize.round()}'),
                      ],
                    ),
                  ),
                // Book and Chapter selector
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      // Book selector
                      Expanded(
                        flex: 2,
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: state.selectedBookNumber,
                          hint: const Text('Select Book'),
                          items: state.books.map((book) {
                            return DropdownMenuItem<int>(
                              value: book['book_number'] as int,
                              child: Text(
                                book['long_name'] as String,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (bookNumber) {
                            if (bookNumber != null) {
                              final book = state.books.firstWhere(
                                (b) => b['book_number'] == bookNumber,
                              );
                              notifier.selectBook(
                                bookNumber,
                                book['short_name'] as String,
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Chapter selector
                      DropdownButton<int>(
                        value: state.selectedChapter,
                        hint: const Text('Ch'),
                        items: List.generate(state.maxChapter, (i) => i + 1)
                            .map((chapter) => DropdownMenuItem<int>(
                                  value: chapter,
                                  child: Text('Ch $chapter'),
                                ))
                            .toList(),
                        onChanged: (chapter) {
                          if (chapter != null) {
                            notifier.selectChapter(chapter);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                // Verses display
                Expanded(
                  child: state.verses.isEmpty
                      ? const Center(child: Text('Select a book and chapter'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.verses.length,
                          itemBuilder: (context, index) {
                            final verse = state.verses[index];
                            final verseNumber = verse['verse'] as int;
                            final verseText = verse['text'] as String;
                            final verseKey =
                                '${state.selectedBookName}|${state.selectedChapter}|$verseNumber';
                            final isSelected =
                                state.selectedVerses.contains(verseKey);
                            final isMarked = state.persistentlyMarkedVerses
                                .contains(verseKey);

                            return GestureDetector(
                              onTap: () {
                                notifier.toggleVerseSelection(verseKey);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.blue.withValues(alpha: 0.1)
                                      : isMarked
                                          ? Colors.yellow.withValues(alpha: 0.2)
                                          : null,
                                  border: isSelected
                                      ? Border(
                                          left: BorderSide(
                                            color: Colors.blue,
                                            width: 3,
                                          ),
                                        )
                                      : null,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: state.fontSize,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                      height: 1.5,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '$verseNumber ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[600],
                                          fontSize: state.fontSize * 0.8,
                                        ),
                                      ),
                                      TextSpan(
                                        text: _cleanVerseText(verseText),
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
      // Show action bar when verses are selected
      bottomNavigationBar: state.selectedVerses.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Selected verses count
                    Text(
                      '${state.selectedVerses.length} verses selected',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Copy
                        IconButton(
                          icon: const Icon(Icons.copy),
                          tooltip: 'Copy',
                          onPressed: () {
                            final text = _getSelectedVersesText(state);
                            final reference = _formatVerseReference(state);
                            Clipboard.setData(
                              ClipboardData(text: '$reference\n\n$text'),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Copied to clipboard')),
                            );
                            notifier.clearSelection();
                          },
                        ),
                        // Share
                        IconButton(
                          icon: const Icon(Icons.share),
                          tooltip: 'Share',
                          onPressed: () {
                            final text = _getSelectedVersesText(state);
                            final reference = _formatVerseReference(state);
                            Share.share('$reference\n\n$text');
                            notifier.clearSelection();
                          },
                        ),
                        // Save
                        IconButton(
                          icon: const Icon(Icons.bookmark_add),
                          tooltip: 'Save',
                          onPressed: () async {
                            await notifier.saveSelectedVerses();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Verses saved')),
                              );
                            }
                            notifier.clearSelection();
                          },
                        ),
                        // Cancel
                        IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: 'Cancel',
                          onPressed: () {
                            notifier.clearSelection();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
