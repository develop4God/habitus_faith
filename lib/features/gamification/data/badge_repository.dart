import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/badge.dart';

/// Repository for managing badges and their unlock status
class BadgeRepository {
  final SharedPreferences _prefs;
  static const String _badgesKey = 'badges';

  BadgeRepository(this._prefs);

  /// Get all badges for a user
  Future<List<Badge>> getBadges(String userId) async {
    final jsonString = _prefs.getString('${_badgesKey}_$userId');
    if (jsonString == null) {
      // Initialize badges for new user
      return _initializeBadges(userId);
    }

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList
        .map((json) => Badge.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Initialize all badges for a user
  List<Badge> _initializeBadges(String userId) {
    return FruitOfSpirit.values.map((fruit) {
      return Badge(
        id: '${userId}_${fruit.name}',
        userId: userId,
        fruit: fruit,
        isUnlocked: false,
      );
    }).toList();
  }

  /// Save badges
  Future<void> saveBadges(List<Badge> badges) async {
    if (badges.isEmpty) return;
    
    final userId = badges.first.userId;
    final jsonList = badges.map((b) => b.toJson()).toList();
    await _prefs.setString('${_badgesKey}_$userId', json.encode(jsonList));
  }

  /// Unlock a specific badge
  Future<Badge> unlockBadge(String userId, FruitOfSpirit fruit, DateTime timestamp) async {
    final badges = await getBadges(userId);
    final index = badges.indexWhere((b) => b.fruit == fruit);
    
    if (index != -1) {
      badges[index] = badges[index].unlock(timestamp);
      await saveBadges(badges);
      return badges[index];
    }
    
    throw Exception('Badge not found: ${fruit.name}');
  }

  /// Get unlocked badges count
  Future<int> getUnlockedCount(String userId) async {
    final badges = await getBadges(userId);
    return badges.where((b) => b.isUnlocked).length;
  }

  /// Clear all badges (for testing)
  Future<void> clearAll() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_badgesKey)) {
        await _prefs.remove(key);
      }
    }
  }
}
