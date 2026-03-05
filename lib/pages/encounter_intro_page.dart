// lib/pages/encounter_intro_page.dart
//
// Cinematic intro page for Encounters.
// Pre-loads the study while showing the intro so the reader opens instantly.

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/core/config/devotional_constants.dart';
import 'package:habitus_faith/core/models/encounter_index_entry.dart';
import 'package:habitus_faith/pages/encounter_detail_page.dart';
import 'package:habitus_faith/providers/encounter_provider.dart';

class EncounterIntroPage extends ConsumerStatefulWidget {
  final EncounterIndexEntry entry;
  final String lang;

  const EncounterIntroPage({
    required this.entry,
    required this.lang,
    super.key,
  });

  @override
  ConsumerState<EncounterIntroPage> createState() => _EncounterIntroPageState();
}

class _EncounterIntroPageState extends ConsumerState<EncounterIntroPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _imageFade;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;
  late Animation<double> _emojiScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _imageFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );
    _emojiScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOutBack),
    );
    _contentFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 0.9, curve: Curves.easeIn),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
    ));

    _controller.forward();

    // Pre-load the study
    final id = widget.entry.id;
    final encounterState = ref.read(encounterProvider);
    if (!encounterState.isStudyLoaded(id)) {
      final filename =
          widget.entry.fileFor(widget.lang) ?? '${id}_${widget.lang}.json';
      ref
          .read(encounterProvider.notifier)
          .loadStudy(id, widget.lang, filename: filename);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _beginEncounter(EncounterState state) {
    final study = state.getStudy(widget.entry.id);
    if (study == null) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EncounterDetailPage(entry: widget.entry, lang: widget.lang),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final accentColor =
        _parseColor(entry.accentColor) ?? const Color(0xFF1e3a5f);

    final String? imageUrl = entry.introImage != null
        ? DevotionalConstants.getEncounterImageUrl(entry.introImage!)
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0a0e1a),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          if (imageUrl != null)
            FadeTransition(
              opacity: _imageFade,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFF0a0e1a)),
              ),
            ),

          // Gradient overlays
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.1),
                  const Color(0xFF0a0e1a).withValues(alpha: 0.95),
                  const Color(0xFF0a0e1a),
                ],
                stops: const [0.0, 0.2, 0.7, 1.0],
              ),
            ),
          ),

          // Decorative orb
          Positioned(
            top: 100,
            left: -100,
            child: _Orb(color: accentColor.withValues(alpha: 0.2), size: 400),
          ),

          // Main content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: IconButton(
                    icon: const Icon(Icons.close,
                        color: Colors.white70, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),

                        // Hero emoji badge
                        ScaleTransition(
                          scale: _emojiScale,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1)),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.3),
                                  blurRadius: 40,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Text(
                              entry.emoji ?? '✨',
                              style: const TextStyle(fontSize: 64),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Text reveal
                        FadeTransition(
                          opacity: _contentFade,
                          child: SlideTransition(
                            position: _contentSlide,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AutoSizeText(
                                  entry.titleFor(widget.lang),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 44,
                                    fontWeight: FontWeight.w900,
                                    height: 1.0,
                                    letterSpacing: -1.5,
                                  ),
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  entry.subtitleFor(widget.lang),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 40),
                                _FeatureRow(
                                  icon: Icons.auto_stories_outlined,
                                  label: entry.scriptureFor(widget.lang),
                                ),
                                const SizedBox(height: 16),
                                _FeatureRow(
                                  icon: Icons.bolt_rounded,
                                  label:
                                      '${entry.readingMinutesFor(widget.lang)} min immersive journey',
                                ),
                                if (entry.testament != null) ...[
                                  const SizedBox(height: 16),
                                  _FeatureRow(
                                    icon: Icons.explore_rounded,
                                    label:
                                        '${entry.testament!.toUpperCase()} TESTAMENT EXPERIENCE',
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),

                // Bottom action
                FadeTransition(
                  opacity: _contentFade,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
                    child: Consumer(
                      builder: (context, ref, _) {
                        final state = ref.watch(encounterProvider);
                        final isLoaded = state.isStudyLoaded(entry.id);
                        final hasError = state.errorMessage != null;

                        return SizedBox(
                          width: double.infinity,
                          height: 72,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 72,
                                child: ElevatedButton(
                                  onPressed: isLoaded
                                      ? () => _beginEncounter(state)
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF0a0e1a),
                                    disabledBackgroundColor:
                                        Colors.white.withValues(alpha: 0.90),
                                    disabledForegroundColor:
                                        const Color(0xFF0a0e1a)
                                            .withValues(alpha: 0.5),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  child: Text(
                                    hasError
                                        ? 'Error loading — tap to retry'
                                        : 'BEGIN ENCOUNTER',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                ),
                              ),
                              if (!isLoaded && !hasError)
                                const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation(
                                        Color(0xFF0a0e1a)),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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

class _Orb extends StatelessWidget {
  final Color color;
  final double size;

  const _Orb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color, blurRadius: size / 2, spreadRadius: 20),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.amberAccent, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}
