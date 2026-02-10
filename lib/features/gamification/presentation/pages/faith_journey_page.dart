import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/auth_provider.dart';
import '../gamification_providers.dart';
import '../widgets/journey_progress_card.dart';
import '../widgets/badge_collection_grid.dart';

/// Page to display the user's faith journey progression
class FaithJourneyPage extends ConsumerWidget {
  const FaithJourneyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(userIdProvider);

    if (userId == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final journeyLevelAsync = ref.watch(journeyLevelProvider(userId));
    final badgesAsync = ref.watch(badgesProvider(userId));
    final totalPointsAsync = ref.watch(totalFaithPointsProvider(userId));
    final pointsTodayAsync = ref.watch(pointsTodayProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Faith Journey'),
        actions: [
          if (pointsTodayAsync.hasValue)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Chip(
                avatar: const Icon(Icons.stars, size: 16),
                label: Text(
                  '+${pointsTodayAsync.value} today',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Journey progress card
            journeyLevelAsync.when(
              data: (level) => JourneyProgressCard(level: level),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
            const SizedBox(height: 16),
            // Badges collection
            badgesAsync.when(
              data: (badges) => BadgeCollectionGrid(badges: badges),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
            const SizedBox(height: 32),
            // Motivational message
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        size: 48,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Keep Growing!',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete your daily habits to earn faith points and unlock new devotional content.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.blue[800],
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
