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

  void _showDevotionalDetail(BuildContext context, Devocional devocional) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return _buildDevocionalDetailContent(context, devocional, scrollController);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final devotionalState = ref.watch(devotionalProvider);
    final imageAsync = ref.watch(dailyDevotionalImageProvider);
    
    // Reset random devotional if language changes
    if (_lastLanguage != devotionalState.selectedLanguage) {
      _randomDevotional = null;
      _lastLanguage = devotionalState.selectedLanguage;
    }

    // Pick a random devotional once data is available
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
                expandedHeight: 300,
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                stretch: true,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
                  background: GestureDetector(
                    onTap: displayDevotional.id != 'fallback' 
                        ? () => _showDevotionalDetail(context, displayDevotional)
                        : null,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        imageAsync.when(
                          data: (imageUrl) => Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.blue.shade900, Colors.indigo.shade900],
                                ),
                              ),
                            ),
                          ),
                          loading: () => Container(color: Colors.blue.shade900),
                          error: (_, __) => Container(color: Colors.blue.shade900),
                        ),
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
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.auto_awesome, size: 12, color: Colors.amber),
                                    const SizedBox(width: 8),
                                    Text(
                                      'PALABRA DE HOY',
                                      style: const TextStyle(
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
                                Expanded(
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
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.menu_book_rounded, size: 14, color: Colors.white70),
                                  const SizedBox(width: 8),
                                  Text(
                                    displayDevotional.id == 'fallback' ? 'Sincronizando...' : 'Ver devocional completo',
                                    style: const TextStyle(
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
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const CircularProgressIndicator(strokeWidth: 5),
                ),
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

  Widget _buildDevocionalDetailContent(BuildContext context, Devocional devocional, ScrollController controller) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      children: [
        Center(
          child: Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          devocional.versiculo,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 32),
        _buildSectionTitle(l10n.reflection, Icons.lightbulb_outline, colorScheme.primary),
        const SizedBox(height: 12),
        Text(
          devocional.reflexion,
          style: TextStyle(
            fontSize: 17,
            height: 1.6,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 32),
        if (devocional.paraMeditar.isNotEmpty) ...[
          _buildSectionTitle(l10n.forMeditation, Icons.Self_improvement_outlined, colorScheme.secondary),
          const SizedBox(height: 16),
          ...devocional.paraMeditar.map((punto) => _buildMeditationItem(punto, isDark)),
          const SizedBox(height: 32),
        ],
        _buildSectionTitle(l10n.prayer, Icons.favorite_border_rounded, Colors.pink),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.pink.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.pink.withValues(alpha: 0.1)),
          ),
          child: Text(
            devocional.oracion,
            style: TextStyle(
              fontSize: 17,
              height: 1.6,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildMeditationItem(ParaMeditar punto, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              punto.texto,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
