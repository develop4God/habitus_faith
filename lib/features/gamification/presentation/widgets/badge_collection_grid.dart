import 'package:flutter/material.dart';
import '../../domain/models/badge.dart' as gamification;

/// Widget to display the collection of badges
class BadgeCollectionGrid extends StatelessWidget {
  final List<gamification.Badge> badges;
  final VoidCallback? onBadgeTap;

  const BadgeCollectionGrid({
    super.key,
    required this.badges,
    this.onBadgeTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Fruit of the Spirit Badges',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];
            return _BadgeItem(
              badge: badge,
              onTap: onBadgeTap,
            );
          },
        ),
      ],
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final gamification.Badge badge;
  final VoidCallback? onTap;

  const _BadgeItem({
    required this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLocked = !badge.isUnlocked;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: isLocked ? 1 : 4,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: isLocked
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.primaryColor.withValues(alpha: 0.1),
                      theme.primaryColor.withValues(alpha: 0.05),
                    ],
                  ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    badge.fruit.emoji,
                    style: TextStyle(
                      fontSize: 48,
                      color: isLocked ? Colors.grey[400] : null,
                    ),
                  ),
                  if (isLocked)
                    Icon(
                      Icons.lock,
                      color: Colors.grey[600],
                      size: 24,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                badge.fruit.displayName,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isLocked ? Colors.grey : null,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (isLocked)
                Text(
                  '${badge.fruit.requiredPoints} pts',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
