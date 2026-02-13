import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'bible_reader_page.dart';
import 'devotional_discovery_page.dart';

class SpiritualHubPage extends StatelessWidget {
  const SpiritualHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF000000), const Color(0xFF1A1A1A)]
                : [const Color(0xFFFFFFFF), const Color(0xFFF0F7FF)],
          ),
        ),
        child: Stack(
          children: [
            // Decorative elements for "Wow" factor
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withValues(alpha: 0.05),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'CRECIMIENTO', // TODO: Localize "GROWTH"
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Vida\nEspiritual', // TODO: Localize "Spiritual Life"
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF1A1C1E),
                        letterSpacing: -1.5,
                        height: 1.0,
                        fontSize: 40,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Alimenta tu alma con la Palabra.', // TODO: Localize
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildHubCard(
                            context: context,
                            title: l10n.readBible,
                            subtitle: 'Explorar las Escrituras',
                            icon: Icons.auto_stories_rounded,
                            color: const Color(0xFF3478F6),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const BibleReaderPage()),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildHubCard(
                            context: context,
                            title: 'Devocionales',
                            subtitle: 'Inspiración para hoy',
                            icon: Icons.local_library_rounded,
                            color: const Color(0xFF8E55E9),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const DevotionalDiscoveryPage()),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHubCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                bottom: -30,
                child: Icon(
                  icon,
                  size: 180,
                  color: color.withValues(alpha: 0.05),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1A1C1E),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 24,
                top: 0,
                bottom: 0,
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
