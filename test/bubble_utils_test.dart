import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/utils/bubble_constants.dart';

void main() {
  group('Bubble Utils Tests', () {
    setUp(() {
      // Set up mock shared preferences
      SharedPreferences.setMockInitialValues({});
    });

    test('shouldShowBubble returns true for new bubble', () async {
      final shouldShow = await BubbleUtils.shouldShowBubble('test_bubble');
      expect(shouldShow, isTrue);
    });

    test('shouldShowBubble returns false after marking as shown', () async {
      await BubbleUtils.markAsShown('test_bubble');
      final shouldShow = await BubbleUtils.shouldShowBubble('test_bubble');
      expect(shouldShow, isFalse);
    });

    test('resetBubble resets bubble state', () async {
      await BubbleUtils.markAsShown('test_bubble');
      await BubbleUtils.resetBubble('test_bubble');
      final shouldShow = await BubbleUtils.shouldShowBubble('test_bubble');
      expect(shouldShow, isTrue);
    });

    test('resetAllBubbles resets all bubbles', () async {
      await BubbleUtils.markAsShown(BubbleConstants.bibleNavigationBubble);
      await BubbleUtils.markAsShown(BubbleConstants.bibleSearchBubble);
      await BubbleUtils.resetAllBubbles();

      final shouldShowNav = await BubbleUtils.shouldShowBubble(
          BubbleConstants.bibleNavigationBubble);
      final shouldShowSearch =
          await BubbleUtils.shouldShowBubble(BubbleConstants.bibleSearchBubble);

      expect(shouldShowNav, isTrue);
      expect(shouldShowSearch, isTrue);
    });
  });
}
