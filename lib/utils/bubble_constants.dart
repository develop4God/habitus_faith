import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BubbleConstants {
  // Bubble IDs for different features
  static const String bibleNavigationBubble = 'bible_navigation_bubble';
  static const String bibleSearchBubble = 'bible_search_bubble';
  static const String versionSelectorBubble = 'version_selector_bubble';

  // Badge widget
  static Widget buildBadge({
    required String text,
    Color backgroundColor = const Color(0xffef4444),
    Color textColor = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class BubbleUtils {
  static Future<bool> shouldShowBubble(String bubbleId) async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(bubbleId) ?? false);
  }

  static Future<void> markAsShown(String bubbleId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(bubbleId, true);
  }

  static Future<void> resetBubble(String bubbleId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(bubbleId);
  }

  static Future<void> resetAllBubbles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(BubbleConstants.bibleNavigationBubble);
    await prefs.remove(BubbleConstants.bibleSearchBubble);
    await prefs.remove(BubbleConstants.versionSelectorBubble);
  }
}
