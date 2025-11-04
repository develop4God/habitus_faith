// lib/pages/devotional_discovery_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/devotional_providers.dart';
import '../core/models/devocional_model.dart';
import 'bible_reader_page.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Devotional Discovery'),
        actions: [
          // Language selector
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            tooltip: 'Select Language',
            onSelected: (language) {
              // Check if language is coming soon
              if (language == 'zh') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chinese devotionals coming soon! 即将推出中文灵修内容！'),
                    duration: Duration(seconds: 3),
                  ),
                );
                return;
              }
              ref.read(devotionalProvider.notifier).changeLanguage(language);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'es', child: Text('Español')),
              PopupMenuItem(value: 'en', child: Text('English')),
              PopupMenuItem(value: 'pt', child: Text('Português')),
              PopupMenuItem(value: 'fr', child: Text('Français')),
              PopupMenuItem(
                value: 'zh',
                child: Text('Chinese (Coming Soon)'),
              ),
            ],
          ),
          // Favorites filter (future implementation)
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: Show favorites only
            },
            tooltip: 'Favorites',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search devotionals...',
                prefixIcon: const Icon(Icons.search),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchTerm = value);
                ref.read(devotionalProvider.notifier).filterBySearch(value);
              },
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
                            color: colorScheme.onSurface.withOpacity(0.5),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showDevocionalDetail(context, devocional),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date and favorite
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateFormat.format(devocional.date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : null,
                    ),
                    onPressed: () {
                      ref
                          .read(devotionalProvider.notifier)
                          .toggleFavorite(devocional);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Bible verse reference
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  devocional.versiculo,
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
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
                  spacing: 4,
                  runSpacing: 4,
                  children: devocional.tags!
                      .take(3)
                      .map((tag) => Chip(
                            label: Text(
                              tag,
                              style: const TextStyle(fontSize: 10),
                            ),
                            padding: const EdgeInsets.all(4),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),

              // Read verse first button
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.menu_book),
                label: const Text('Read Verse First'),
                onPressed: () => _navigateToVerse(context, devocional),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToVerse(BuildContext context, Devocional devocional) {
    // Navigate to Bible reader with the verse
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BibleReaderPage(),
      ),
    );
    // TODO: Parse verse reference and navigate to specific location
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening Bible to: ${devocional.versiculo}'),
      ),
    );
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

  Widget _buildDevocionalDetailContent(
      BuildContext context, Devocional devocional, ScrollController controller) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFavorite =
        ref.read(devotionalProvider.notifier).isFavorite(devocional.id);

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
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                onPressed: () {
                  ref
                      .read(devotionalProvider.notifier)
                      .toggleFavorite(devocional);
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
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
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
              color: colorScheme.primaryContainer.withOpacity(0.3),
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
