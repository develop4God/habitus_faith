// lib/pages/favorites_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/devotional_providers.dart';
import '../core/models/devocional_model.dart';
import 'package:intl/intl.dart';

/// Favorites Page - Shows all favorited devotionals
class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(devotionalProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: 24),
            const SizedBox(width: 8),
            const Text('My Favorites'),
          ],
        ),
        elevation: 0,
      ),
      body: state.favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_outline,
                    size: 80,
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isDark ? Colors.grey[600] : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the star icon on any devotional to save it here',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.grey[700] : Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.explore),
                    label: const Text('Explore Devotionals'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: state.favorites.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final devocional = state.favorites[index];
                return _FavoriteCard(
                  devocional: devocional,
                  colorScheme: colorScheme,
                  isDark: isDark,
                );
              },
            ),
    );
  }
}

/// Favorite card widget
class _FavoriteCard extends ConsumerWidget {
  final Devocional devocional;
  final ColorScheme colorScheme;
  final bool isDark;

  const _FavoriteCard({
    required this.devocional,
    required this.colorScheme,
    required this.isDark,
  });

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

  String _extractVerseText(String versiculo) {
    final quoteStart = versiculo.indexOf('"');
    final quoteEnd = versiculo.lastIndexOf('"');
    if (quoteStart != -1 && quoteEnd != -1 && quoteEnd > quoteStart) {
      return versiculo.substring(quoteStart + 1, quoteEnd);
    }
    return versiculo;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? Colors.grey[900] : Colors.white,
      child: InkWell(
        onTap: () {
          // Navigate back to discovery page and show detail
          Navigator.pop(context);
          // TODO: Could implement showing the detail directly
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with star and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _extractVerseReference(devocional.versiculo),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        dateFormat.format(devocional.date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 22,
                        ),
                        onPressed: () {
                          // Remove from favorites
                          ref
                              .read(devotionalProvider.notifier)
                              .toggleFavorite(devocional);
                        },
                        tooltip: 'Remove from favorites',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Verse text preview
              Text(
                _extractVerseText(devocional.versiculo),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),

              // Reflection preview
              Text(
                devocional.reflexion,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),

              // Tags
              if (devocional.tags != null && devocional.tags!.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: devocional.tags!.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey[800]
                            : colorScheme.primaryContainer.withOpacity(0.3),
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
            ],
          ),
        ),
      ),
    );
  }
}
