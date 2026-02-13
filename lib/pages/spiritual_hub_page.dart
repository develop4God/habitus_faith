import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../l10n/app_localizations.dart';
import '../providers/devotional_providers.dart';
import '../core/models/devocional_model.dart';
import '../core/services/images/image_providers.dart';
import 'bible_reader_page.dart';
import 'devotional_discovery_page.dart';
import 'devotional_reader_page.dart';

class SpiritualHubPage extends ConsumerStatefulWidget {
  const SpiritualHubPage({super.key});

  @override
  ConsumerState<SpiritualHubPage> createState() => _SpiritualHubPageState();
}

class _SpiritualHubPageState extends ConsumerState<SpiritualHubPage> {
  bool _isNavigating = false;
  Devocional? _randomDevotional;
  String? _lastLanguage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(devotionalProvider.notifier).initialize();
    });
  }

  Future<void> _safeNavigate(Widget page) async {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
    
    if (mounted) {
      setState(() => _isNavigating = false);
    }
  }

  void _openDevotionalReader(Devocional devocional, String? imageUrl) {
    _safeNavigate(DevotionalReaderPage(
      devocional: devocional,
      imageUrl: imageUrl,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final devotionalState = ref.watch(devotionalProvider);
    final imageAsync = ref.watch(dailyDevotionalImageProvider);
    
    if (_lastLanguage != devotionalState.selectedLanguage) {
      _randomDevotional = null;
      _lastLanguage = devotionalState.selectedLanguage;
    }

    if (_randomDevotional == null && devotionalState.all.isNotEmpty) {
      _randomDevotional = devotionalState.all[Random().nextInt(devotionalState.all.length)];
    }

    final displayDevotional = _randomDevotional ?? Devocional(
      id: 'fallback',
      versiculo: 'Salmos 119:105 "Lámpara es a mis pies tu palabra, y lumbrera a mi camino."',
      reflexion: '',
      paraMeditar: [],
      oracion: '',
      date: DateTime.now(),
    );

    final imageUrl = imageAsync.asData?.value;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [const Color(0xFF0D1B2A), const Color(0xFF1B263B)]
                    : [const Color(0xFFF8FBFE), Colors.white],
              ),
            ),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                stretch: true,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
                  background: GestureDetector(
                    onTap: displayDevotional.id != 'fallback' 
                        ? () => _openDevotionalReader(displayDevotional, imageUrl)
                        : null,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (imageUrl != null)
                          Hero(
                            tag: 'devotional_image_${displayDevotional.id}',
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(color: Colors.blue.shade900),
                            ),
                          )
                        else
                          Container(color: Colors.blue.shade900),
                        
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.2),
                                Colors.black.withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(28, 80, 28, 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.auto_awesome, size: 12, color: Colors.amber),
                                    SizedBox(width: 8),
                                    Text(
                                      'PALABRA DE HOY',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (devotionalState.isLoading && devotionalState.all.isEmpty)
                                const SizedBox(
                                  height: 60,
                                  child: Center(child: CircularProgressIndicator(color: Colors.white)),
                                )
                              else
                                Hero(
                                  tag: 'devotional_verse_${displayDevotional.id}',
                                  child: Material(
                                    color: Colors.transparent,
                                    child: AutoSizeText(
                                      displayDevotional.versiculo,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w300,
                                        fontStyle: FontStyle.italic,
                                        height: 1.3,
                                        fontFamily: 'Georgia',
                                      ),
                                      maxLines: 5,
                                      minFontSize: 16,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 12),
                              const Row(
                                children: [
                                  Icon(Icons.menu_book_rounded, size: 14, color: Colors.white70),
                                  SizedBox(width: 8),
                                  Text(
                                    'Ver devocional completo',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      l10n.spiritual,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildFeatureCard(
                      context: context,
                      title: l10n.readBible,
                      description: 'Explora la Palabra de Dios con nuestro lector avanzado.',
                      icon: Icons.auto_stories_rounded,
                      color: const Color(0xFF007AFF),
                      onTap: () => _safeNavigate(const BibleReaderPage()),
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureCard(
                      context: context,
                      title: 'Devocionales',
                      description: 'Fortalece tu fe con reflexiones diarias personalizadas.',
                      icon: Icons.local_library_rounded,
                      color: const Color(0xFF5856D6),
                      onTap: () => _safeNavigate(const DevotionalDiscoveryPage()),
                    ),
                  ]),
                ),
              ),
            ],
          ),
          if (_isNavigating)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: color.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color.withValues(alpha: 0.2), size: 28),
          ],
        ),
      ),
    );
  }
}
