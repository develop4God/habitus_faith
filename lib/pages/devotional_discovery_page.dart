// lib/pages/devotional_discovery_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/devotional_providers.dart';
import '../providers/bible_providers.dart';
import '../core/models/devocional_model.dart';
import '../bible_reader_core/bible_reader_core.dart';
import 'bible_reader_page.dart';
import 'favorites_page.dart';
import 'package:intl/intl.dart';

/// Devotional Discovery Page
///
/// This page allows users to:
/// 1. Browse devotionals
/// 2. Select a verse to read first
/// 3. Then view the devotional content
class DevotionalDiscoveryPage extends ConsumerStatefulWidget {
  const DevotionalDiscoveryPage({super.key});

  @override
  ConsumerState<DevotionalDiscoveryPage> createState() =>
      _DevotionalDiscoveryPageState();
}

class _DevotionalDiscoveryPageState
    extends ConsumerState<DevotionalDiscoveryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    // Initialize devotionals on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(devotionalProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(devotionalProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Daily Devotional',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          // Language selector
          IconButton(
            icon: Icon(
              Icons.language,
              color: isDark ? Colors.white : Colors.black87,
            ),
            tooltip: 'Select Language',
            onPressed: () => _showLanguageSelector(context),
          ),
          // Favorites page
          IconButton(
            icon: Icon(
              Icons.star_border,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesPage(),
                ),
              );
            },
            tooltip: 'Favorites',
          ),
        ],
      ),
      body: Column(
        children: [
          // Hero header with gradient
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [Colors.deepPurple[900]!, Colors.purple[800]!]
                    : [colorScheme.primary, colorScheme.secondary],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, MMMM d').format(DateTime.now()),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search bar (minimal and modern)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search devotionals...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  suffixIcon: _searchTerm.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchTerm = '');
                            ref
                                .read(devotionalProvider.notifier)
                                .filterBySearch('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                onChanged: (value) {
                  setState(() => _searchTerm = value);
                  ref.read(devotionalProvider.notifier).filterBySearch(value);
                },
              ),
            ),
          ),

          // Loading indicator
          if (state.isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),

          // Error message
          if (state.errorMessage != null && !state.isLoading)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.error),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(devotionalProvider.notifier).initialize();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),

          // Devotional list
          if (!state.isLoading && state.errorMessage == null)
            Expanded(
              child: state.filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.book_outlined,
                            size: 64,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No devotionals found',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: state.filtered.length,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemBuilder: (context, index) {
                        final devocional = state.filtered[index];
                        return _buildDevocionalCard(
                            context, devocional, colorScheme);
                      },
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildDevocionalCard(
      BuildContext context, Devocional devocional, ColorScheme colorScheme) {
    final isFavorite =
        ref.read(devotionalProvider.notifier).isFavorite(devocional.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use the new display date method that shows future dates
    final displayDate = _getDisplayDate(devocional);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showDevocionalDetail(context, devocional),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero image section with gradient overlay
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _getGradientColors(isDark, devocional.tags),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative pattern
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.1,
                          child: CustomPaint(
                            painter: _DotPatternPainter(),
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date and favorite
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    displayDate,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      isFavorite
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: isFavorite
                                          ? Colors.amber
                                          : Colors.white,
                                      size: 22,
                                    ),
                                    onPressed: () {
                                      ref
                                          .read(devotionalProvider.notifier)
                                          .toggleFavorite(devocional);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            // Verse reference (hero element)
                            Text(
                              _extractVerseReference(devocional.versiculo),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Verse text preview
                      Text(
                        _extractVerseText(devocional.versiculo),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey[300] : Colors.grey[800],
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Tags
                      if (devocional.tags != null &&
                          devocional.tags!.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: devocional.tags!.take(2).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey[800]
                                    : colorScheme.primaryContainer
                                        .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : colorScheme.primary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 16),

                      // Read button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              _navigateToVerse(context, devocional),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? Colors.purple[700]
                                : colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_stories_outlined, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Read Verse First',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper to get display date - converts past dates to future dates
  String _getDisplayDate(Devocional devocional) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final devDate = DateTime(
        devocional.date.year, devocional.date.month, devocional.date.day);

    // If date is today, show "Today"
    if (devDate == today) {
      return 'Today';
    }

    // If date is in the past, project it to the future
    // by adding years until it's in the future
    DateTime displayDate = devDate;
    while (displayDate.isBefore(today)) {
      displayDate =
          DateTime(displayDate.year + 1, displayDate.month, displayDate.day);
    }

    // Check if it's tomorrow
    final tomorrow = today.add(const Duration(days: 1));
    if (displayDate == tomorrow) {
      return 'Tomorrow';
    }

    // Check if it's within this week
    final daysUntil = displayDate.difference(today).inDays;
    if (daysUntil <= 7 && daysUntil > 1) {
      return DateFormat('EEEE').format(displayDate); // e.g., "Monday"
    }

    // Otherwise show the date
    return DateFormat('MMM dd').format(displayDate);
  }

  // Extract verse reference (e.g., "John 3:16" or "Marcos 7:20-23")
  String _extractVerseReference(String versiculo) {
    // The format is typically: "BookName Chapter:Verse Version: 'Text'"
    // We want to extract "BookName Chapter:Verse"

    // Split by version indicator (usually the version code followed by colon)
    final parts = versiculo.split(RegExp(r'\s+[A-Z]{2,}[0-9]*:'));
    if (parts.isNotEmpty) {
      final refPart = parts[0].trim();
      return refPart;
    }

    // Fallback: try to extract everything before the quote
    final quoteIndex = versiculo.indexOf('"');
    if (quoteIndex > 0) {
      return versiculo.substring(0, quoteIndex).trim();
    }

    return versiculo;
  }

  // Extract verse text (the actual quote)
  String _extractVerseText(String versiculo) {
    // Extract text between quotes
    final quoteStart = versiculo.indexOf('"');
    final quoteEnd = versiculo.lastIndexOf('"');
    if (quoteStart != -1 && quoteEnd != -1 && quoteEnd > quoteStart) {
      return versiculo.substring(quoteStart + 1, quoteEnd);
    }
    return versiculo;
  }

  // Get gradient colors based on tags
  List<Color> _getGradientColors(bool isDark, List<String>? tags) {
    if (tags != null && tags.isNotEmpty) {
      final tag = tags.first.toLowerCase();
      if (tag.contains('love') || tag.contains('amor')) {
        return isDark
            ? [Colors.pink[900]!, Colors.red[800]!]
            : [Colors.pink[400]!, Colors.red[400]!];
      } else if (tag.contains('peace') || tag.contains('paz')) {
        return isDark
            ? [Colors.blue[900]!, Colors.indigo[800]!]
            : [Colors.blue[400]!, Colors.indigo[400]!];
      } else if (tag.contains('faith') || tag.contains('fe')) {
        return isDark
            ? [Colors.purple[900]!, Colors.deepPurple[800]!]
            : [Colors.purple[400]!, Colors.deepPurple[400]!];
      } else if (tag.contains('hope') || tag.contains('esperanza')) {
        return isDark
            ? [Colors.teal[900]!, Colors.cyan[800]!]
            : [Colors.teal[400]!, Colors.cyan[400]!];
      }
    }

    return isDark
        ? [Colors.deepPurple[900]!, Colors.purple[800]!]
        : [Colors.deepPurple[400]!, Colors.purple[400]!];
  }

  // Language selector dialog
  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Language',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 20),
                _buildLanguageOption(context, 'es', 'Español', '🇪🇸'),
                _buildLanguageOption(context, 'en', 'English', '🇺🇸'),
                _buildLanguageOption(context, 'pt', 'Português', '🇧🇷'),
                _buildLanguageOption(context, 'fr', 'Français', '🇫🇷'),
                _buildLanguageOption(
                    context, 'zh', 'Chinese (Coming Soon)', '🇨🇳',
                    disabled: true),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String code,
    String name,
    String flag, {
    bool disabled = false,
  }) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(name),
      enabled: !disabled,
      onTap: disabled
          ? () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chinese devotionals coming soon! 即将推出中文灵修内容！'),
                  duration: Duration(seconds: 3),
                ),
              );
            }
          : () {
              Navigator.pop(context);
              ref.read(devotionalProvider.notifier).changeLanguage(code);
            },
    );
  }

  void _navigateToVerse(BuildContext context, Devocional devocional) async {
    // Parse the verse reference from the devotional
    final verseRef = _extractVerseReference(devocional.versiculo);

    // Try to parse the reference (e.g., "Marcos 7:20-23" -> book, chapter, verse)
    final parsed = BibleReferenceParser.parse(verseRef);

    if (parsed != null) {
      final bookName = parsed['bookName'] as String;
      final chapter = parsed['chapter'] as int;
      // final verse = parsed['verse'] as int?; // TODO: Implement scroll to verse

      // Navigate to Bible reader
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const BibleReaderPage(),
        ),
      );

      // Wait a bit for the page to load, then navigate to the specific passage
      await Future.delayed(const Duration(milliseconds: 500));

      if (context.mounted) {
        // Use the Bible reader provider to navigate to the specific passage
        try {
          final notifier = ref.read(bibleReaderProvider.notifier);

          // Find the book by name
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

            // If we have a specific verse, we could scroll to it
            // (would need to implement scrollToVerse method in Bible reader)
          }
        } catch (e) {
          debugPrint('Error navigating to verse: $e');
        }
      }
    } else {
      // If parsing fails, just open Bible reader
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const BibleReaderPage(),
        ),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening Bible to: ${devocional.versiculo}'),
          ),
        );
      }
    }
  }

  void _showDevocionalDetail(BuildContext context, Devocional devocional) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return _buildDevocionalDetailContent(
              context, devocional, scrollController);
        },
      ),
    );
  }

  Widget _buildDevocionalDetailContent(BuildContext context,
      Devocional devocional, ScrollController controller) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      child: ListView(
        controller: controller,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  devocional.versiculo,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final isFav = ref
                      .read(devotionalProvider.notifier)
                      .isFavorite(devocional.id);
                  return IconButton(
                    icon: Icon(
                      isFav ? Icons.star : Icons.star_border,
                      color: isFav ? Colors.amber : null,
                    ),
                    onPressed: () {
                      ref
                          .read(devotionalProvider.notifier)
                          .toggleFavorite(devocional);
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Read verse button
          ElevatedButton.icon(
            icon: const Icon(Icons.menu_book),
            label: const Text('Read Verse First'),
            onPressed: () {
              Navigator.pop(context);
              _navigateToVerse(context, devocional);
            },
          ),
          const SizedBox(height: 24),

          // Reflection
          Text(
            'Reflection',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            devocional.reflexion,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          // Meditation points
          if (devocional.paraMeditar.isNotEmpty) ...[
            Text(
              'For Meditation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...devocional.paraMeditar.map((punto) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        punto.cita,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.secondary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        punto.texto,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 24),
          ],

          // Prayer
          Text(
            'Prayer',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              devocional.oracion,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for decorative pattern
class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    const dotSize = 2.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
