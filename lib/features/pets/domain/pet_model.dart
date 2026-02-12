import 'package:flutter/foundation.dart';

@immutable
class Pet {
  final String name;
  final String lottieAsset;
  final String emoji;
  final bool isUnlocked;

  const Pet({
    required this.name,
    required this.lottieAsset,
    required this.emoji,
    this.isUnlocked = false,
  });
}
