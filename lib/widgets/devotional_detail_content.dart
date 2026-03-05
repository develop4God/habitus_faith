import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../core/models/devocional_model.dart';
import '../l10n/app_localizations.dart';
import '../providers/devotional_providers.dart';
import '../bible_reader_core/bible_reader_core.dart';
import '../pages/bible_reader_page.dart';
import '../providers/bible_providers.dart';

class DevotionalDetailContent extends ConsumerWidget {
  final Devocional devocional;
  final bool shrinkWrap;
  final bool showVerseReference;

  const DevotionalDetailContent({
    super.key,
    required this.devocional,
    this.shrinkWrap = false,
    this.showVerseReference = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final textScaler = mediaQuery.textScaler;

    // Accessibility: Use relative sizes for better scaling
    final double headlineSize = textScaler.scale(22);
    final double bodySize = textScaler.scale(18);
    final double sectionTitleSize = textScaler.scale(14);

    return Padding(
      padding: EdgeInsets.fromLTRB(
          24,
          32,
          24,
          // Large safe space at the bottom for better reachability and avoiding system bars
          mediaQuery.padding.bottom + 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Verse Reference and Favorite
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (showVerseReference)
                Expanded(
                  child: AutoSizeText(
                    _extractVerseReference(devocional.versiculo),
                    style: TextStyle(
                      fontSize: headlineSize,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.primary,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 2,
                  ),
                )
              else
                const Spacer(),
              IconButton(
                icon: Icon(
                  ref
                          .watch(devotionalProvider.notifier)
                          .isFavorite(devocional.id)
                      ? Icons.star
                      : Icons.star_border,
                  color: ref
                          .watch(devotionalProvider.notifier)
                          .isFavorite(devocional.id)
                      ? Colors.amber
                      : null,
                ),
                onPressed: () {
                  ref
                      .read(devotionalProvider.notifier)
                      .toggleFavorite(devocional);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Read verse button (Bible Reader deep link)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.auto_stories_rounded, size: 20),
              label: AutoSizeText(
                l10n.readVerseFirst,
                maxLines: 1,
              ),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => _navigateToVerse(context, ref, devocional),
            ),
          ),
          const SizedBox(height: 40),

          // Reflection Section
          _buildSectionTitle(l10n.reflection, Icons.lightbulb_outline,
              colorScheme.primary, sectionTitleSize),
          const SizedBox(height: 16),
          Text(
            devocional.reflexion,
            style: TextStyle(
              fontSize: bodySize,
              height: 1.7,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 40),

          // Meditation Section
          if (devocional.paraMeditar.isNotEmpty) ...[
            _buildSectionTitle(l10n.forMeditation, Icons.auto_awesome_rounded,
                colorScheme.secondary, sectionTitleSize),
            const SizedBox(height: 20),
            ...devocional.paraMeditar
                .map((punto) => _buildMeditationItem(punto, isDark, bodySize)),
            const SizedBox(height: 40),
          ],

          // Prayer Section
          _buildSectionTitle(l10n.prayer, Icons.favorite_border_rounded,
              Colors.pink, sectionTitleSize),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.pink.withValues(alpha: isDark ? 0.1 : 0.05),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.pink.withValues(alpha: 0.1)),
            ),
            child: Text(
              devocional.oracion,
              style: TextStyle(
                fontSize: bodySize,
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

  Widget _buildSectionTitle(
      String title, IconData icon, Color color, double fontSize) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: AutoSizeText(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 1.5,
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildMeditationItem(ParaMeditar punto, bool isDark, double fontSize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
                color: Colors.amber, shape: BoxShape.circle),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Verse reference (cita)
                Text(
                  punto.cita,
                  style: TextStyle(
                    fontSize: fontSize * 0.9,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                // Meditation text
                Text(
                  punto.texto,
                  style: TextStyle(
                    fontSize: fontSize,
                    height: 1.6,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToVerse(
      BuildContext context, WidgetRef ref, Devocional devocional) async {
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
                (b['long_name'] as String).toLowerCase() ==
                    bookName.toLowerCase() ||
                (b['short_name'] as String).toLowerCase() ==
                    bookName.toLowerCase(),
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
