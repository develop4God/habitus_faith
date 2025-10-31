import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../l10n/app_localizations.dart';
import '../providers/bible_providers.dart';
import '../bible_reader_core/bible_reader_core.dart';
import '../utils/copyright_utils.dart';
import '../widgets/floating_font_control_buttons.dart';

/// Main Bible Reader Page using Riverpod for state management
class BibleReaderPage extends ConsumerStatefulWidget {
  const BibleReaderPage({super.key});

  @override
  ConsumerState<BibleReaderPage> createState() => _BibleReaderPageState();
}

class _BibleReaderPageState extends ConsumerState<BibleReaderPage> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
    // Initialize Bible reader with device language
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bibleReaderProvider.notifier).initialize('es');
    });
  }

  @override
  void dispose() {
    super.dispose();
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
            buffer
                .writeln('${verse['verse']} ${_cleanVerseText(verse['text'])}');
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
    final l10n = AppLocalizations.of(context)!;

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
          ? Center(child: Text(l10n.loadingBooks))
          : Column(
              children: [
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
                          hint: Text(l10n.selectBook),
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
                              notifier.selectBook(book);
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
                      ? Center(child: Text(l10n.selectBookAndChapter))
                      : Stack(
                          children: [
                            ScrollablePositionedList.builder(
                              itemScrollController: _itemScrollController,
                              itemPositionsListener: _itemPositionsListener,
                              padding: const EdgeInsets.all(16),
                              itemCount: state.verses.length +
                                  1, // +1 for copyright footer
                              itemBuilder: (context, index) {
                                // Copyright footer at the end
                                if (index == state.verses.length) {
                                  if (state.selectedVersion != null) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 16),
                                      child: Text(
                                        CopyrightUtils.getCopyrightText(
                                          state.selectedVersion!.languageCode,
                                          state.selectedVersion!.name,
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              fontSize: 12,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.7),
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }

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
                                              ? Colors.yellow
                                                  .withValues(alpha: 0.2)
                                              : null,
                                      border: isSelected
                                          ? const Border(
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
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
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
                            // Show floating font controls when toggled
                            if (state.showFontControls)
                              FloatingFontControlButtons(
                                currentFontSize: state.fontSize,
                                onIncrease: () {
                                  final newSize =
                                      (state.fontSize + 2).clamp(12.0, 28.0);
                                  notifier.setFontSize(newSize);
                                },
                                onDecrease: () {
                                  final newSize =
                                      (state.fontSize - 2).clamp(12.0, 28.0);
                                  notifier.setFontSize(newSize);
                                },
                                onClose: () {
                                  notifier.toggleFontControls();
                                },
                              ),
                          ],
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
                            final l10n = AppLocalizations.of(context)!;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(l10n.copiedToClipboard)),
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
                              final l10n = AppLocalizations.of(context)!;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.versesSaved)),
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
