import 'package:flutter/material.dart';
import '../../domain/models/journey_level.dart';

/// Widget to display the user's current journey stage and progress
class JourneyProgressCard extends StatelessWidget {
  final JourneyLevel level;

  const JourneyProgressCard({
    super.key,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nextStage = level.nextStage;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStageIcon(level.currentStage),
                  size: 32,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.currentStage.displayName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        level.currentStage.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${level.totalPoints} Faith Points',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (nextStage != null) ...[
              const SizedBox(height: 16),
              Text(
                'Next: ${nextStage.displayName}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: level.progressToNext,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(level.progressToNext * 100).toInt()}% to next stage',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getStageIcon(JourneyStage stage) {
    switch (stage) {
      case JourneyStage.wilderness:
        return Icons.explore;
      case JourneyStage.desert:
        return Icons.wb_sunny;
      case JourneyStage.jordan:
        return Icons.water;
      case JourneyStage.canaan:
        return Icons.landscape;
      case JourneyStage.jerusalem:
        return Icons.location_city;
      case JourneyStage.promisedLand:
        return Icons.auto_awesome;
    }
  }
}
