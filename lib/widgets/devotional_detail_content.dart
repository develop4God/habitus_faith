import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/devocional_model.dart';
import '../l10n/app_localizations.dart';
import '../providers/devotional_providers.dart';
import '../bible_reader_core/bible_reader_core.dart';
import '../pages/bible_reader_page.dart';
import '../providers/bible_providers.dart';

class DevotionalDetailContent extends ConsumerWidget {
  final Devocional devocional;
  final bool shrinkWrap;

  const DevotionalDetailContent({
    super.key,
    required this.devocional,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Verse Reference and Favorite
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _extractVerseReference(devocional.versiculo),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: colorScheme.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  ref.watch(devotionalProvider.notifier).isFavorite(devocional.id)
                      ? Icons.star
                      : Icons.star_border,
                  color: ref.watch(devotionalProvider.notifier).isFavorite(devocional.id)
                      ? Colors.amber
                      : null,
                ),
                onPressed: () {
                  ref.read(devotionalProvider.notifier).toggleFavorite(devocional);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Read verse button (Bible Reader deep link)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.menu_book_rounded, size: 20),
              label: Text(l10n.readVerseFirst),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => _navigateToVerse(context, ref, devocional),
            ),
          ),
          const SizedBox(height: 40),

          // Reflection Section
          _buildSectionTitle(l10n.reflection, Icons.lightbulb_outline, colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            devocional.reflexion,
            style: TextStyle(
              fontSize: 18,
              height: 1.7,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 40),

          // Meditation Section
          if (devocional.paraMeditar.isNotEmpty) ...[
            _buildSectionTitle(l10n.forMeditation, Icons.auto_awesome_rounded, colorScheme.secondary),
            const SizedBox(height: 20),
            ...devocional.paraMeditar.map((punto) => _buildMeditationItem(punto, isDark)),
            const SizedBox(height: 40),
          ],

          // Prayer Section
          _buildSectionTitle(l10n.prayer, Icons.favorite_border_rounded, Colors.pink),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.pink.withOpacity(isDark ? 0.1 : 0.05),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.pink.withOpacity(0.1)),
            ),
            child: Text(
              devocional.oracion,
              style: TextStyle(
                fontSize: 18,
                height: 1.7,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                fontFamily: 'Georgia',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildMeditationItem(ParaMeditar punto, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              punto.texto,
              style: TextStyle(
                fontSize: 17,
                height: 1.6,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToVerse(BuildContext context, WidgetRef ref, Devocional devocional) async {
    final verseRef = _extractVerseReference(devocional.versiculo);
    final parsed = BibleReferenceParser.parse(verseRef);

    if (parsed != null) {
      final bookName = parsed['bookName'] as String;
      final chapter = parsed['chapter'] as int;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BibleReaderPage()),
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (context.mounted) {
        try {
          final notifier = ref.read(bibleReaderProvider.notifier);
          final state = ref.read(bibleReaderProvider);
          final book = state.books.firstWhere(
            (b) =>
                (b['long_name'] as String).toLowerCase() == bookName.toLowerCase() ||
                (b['short_name'] as String).toLowerCase() == bookName.toLowerCase(),
            orElse: () => {},
          );

          if (book.isNotEmpty) {
            await notifier.selectBook(book);
            await notifier.selectChapter(chapter);
          }
        } catch (e) {
          debugPrint('Error navigating to verse: $e');
        }
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BibleReaderPage()),
      );
    }
  }

  String _extractVerseReference(String versiculo) {
    final parts = versiculo.split(RegExp(r'\s+[A-Z]{2,}[0-9]*:'));
    if (parts.isNotEmpty) {
      return parts[0].trim();
    }
    final quoteIndex = versiculo.indexOf('"');
    if (quoteIndex > 0) {
      return versiculo.substring(0, quoteIndex).trim();
    }
    return versiculo;
  }
}
