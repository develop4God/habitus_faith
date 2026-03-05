// lib/pages/encounters_list_page.dart
//
// List of encounter tiles.
// published  → full opacity, tappable → navigates to EncounterIntroPage
// coming_soon → reduced opacity, badge, not tappable

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/core/models/encounter_index_entry.dart';
import 'package:habitus_faith/pages/encounter_intro_page.dart';
import 'package:habitus_faith/providers/devotional_providers.dart';
import 'package:habitus_faith/providers/encounter_provider.dart';

class EncountersListPage extends ConsumerStatefulWidget {
  const EncountersListPage({super.key});

  @override
  ConsumerState<EncountersListPage> createState() => _EncountersListPageState();
}

class _EncountersListPageState extends ConsumerState<EncountersListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final encounterState = ref.read(encounterProvider);
      if (encounterState.index.isEmpty && !encounterState.isLoading) {
        final lang = ref.read(devotionalProvider).selectedLanguage;
        ref.read(encounterProvider.notifier).loadIndex(languageCode: lang);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final encounterState = ref.watch(encounterProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0a0e1a) : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Encounters',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w900,
          ),
        ),
        leading: const SizedBox.shrink(),
      ),
      body: _buildBody(encounterState, isDark),
    );
  }

  Widget _buildBody(EncounterState state, bool isDark) {
    if (state.isLoading && state.index.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.index.isEmpty) {
      return _buildError(state.errorMessage!);
    }

    if (state.index.isEmpty) {
      return _buildEmpty(isDark);
    }

    final lang = ref.read(devotionalProvider).selectedLanguage;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: state.index.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) return _buildHeader(isDark);
        final entry = state.index[i - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _EncounterCard(
            entry: entry,
            lang: lang,
            isCompleted: state.isCompleted(entry.id),
            onTap: entry.isPublished ? () => _openEncounter(entry, lang) : null,
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText(
            'Biblical Encounters',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.0,
              color: isDark ? Colors.white : Colors.black87,
            ),
            maxLines: 1,
          ),
          const SizedBox(height: 6),
          Text(
            'Step into the moments that changed history',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _openEncounter(EncounterIndexEntry entry, String lang) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EncounterIntroPage(entry: entry, lang: lang),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.explore_outlined,
              size: 64, color: isDark ? Colors.white38 : Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No encounters available yet',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white60 : Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back soon for new experiences',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white38 : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final lang = ref.read(devotionalProvider).selectedLanguage;
              ref
                  .read(encounterProvider.notifier)
                  .loadIndex(languageCode: lang, forceRefresh: true);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Encounter Card Widget
// ---------------------------------------------------------------------------

class _EncounterCard extends StatelessWidget {
  final EncounterIndexEntry entry;
  final String lang;
  final bool isCompleted;
  final VoidCallback? onTap;

  const _EncounterCard({
    required this.entry,
    required this.lang,
    required this.isCompleted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPublished = entry.isPublished;
    final accentColor = _parseColor(entry.accentColor) ?? Colors.blueAccent;
    final bool isNew = !isCompleted && isPublished;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isPublished ? 1.0 : 0.45,
        child: Container(
          height: 260,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: accentColor.withValues(alpha: 0.15),
            boxShadow: isPublished
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    )
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background colour (replace with CachedNetworkImage if needed)
                if (entry.introImage != null)
                  Image.network(
                    'https://raw.githubusercontent.com/develop4God/Devocionales-assets/main/images/encounters/${entry.introImage}',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: accentColor),
                  )
                else
                  Container(color: accentColor),

                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.0),
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.95),
                      ],
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge row
                      Row(
                        children: [
                          if (isCompleted)
                            _StatusBadge(
                              label: 'COMPLETED',
                              icon: Icons.verified_rounded,
                              color: Colors.greenAccent,
                            )
                          else if (isNew)
                            _StatusBadge(
                              label: 'NEW',
                              icon: Icons.new_releases_rounded,
                              color: Colors.cyanAccent,
                            ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              entry.emoji ?? '✨',
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Title
                      Text(
                        entry.titleFor(lang),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                          letterSpacing: -0.8,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      // Subtitle
                      Text(
                        entry.subtitleFor(lang),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 20),
                      // Meta
                      Row(
                        children: [
                          _MetaInfo(
                            icon: Icons.timer,
                            text:
                                '${entry.readingMinutesFor(lang)} min',
                          ),
                          const SizedBox(width: 20),
                          _MetaInfo(
                            icon: Icons.auto_stories_outlined,
                            text: entry
                                .scriptureFor(lang)
                                .toUpperCase(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Coming Soon overlay
                if (!isPublished)
                  Container(
                    color: Colors.black.withValues(alpha: 0.7),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          'COMING SOON',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3.0,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    try {
      final clean = hex.replaceAll('#', '');
      if (clean.length == 6) return Color(int.parse('FF$clean', radix: 16));
      if (clean.length == 8) return Color(int.parse(clean, radix: 16));
    } catch (_) {}
    return null;
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _StatusBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaInfo({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
