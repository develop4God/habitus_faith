import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/images/image_providers.dart';

/// A card widget with a blurred background image.
///
/// This widget wraps its child in a card with a beautiful blurred
/// background image fetched from the devotional image repository.
///
/// The image is loaded asynchronously and cached for the day.
class BackgroundImageCard extends ConsumerWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final Color backgroundColor;
  final BorderSide? borderSide;
  final double elevation;
  final double imageHeight;
  final double blurSigma;
  final double overlayOpacity;

  const BackgroundImageCard({
    super.key,
    required this.child,
    this.borderRadius = 22,
    this.padding = const EdgeInsets.all(26),
    this.backgroundColor = Colors.white,
    this.borderSide,
    this.elevation = 2,
    this.imageHeight = 200,
    this.blurSigma = 10,
    this.overlayOpacity = 0.15,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageAsync = ref.watch(dailyDevotionalImageProvider);

    return imageAsync.when(
      data: (imageUrl) => _buildCardWithBackground(imageUrl),
      loading: () => _buildCardWithoutBackground(),
      error: (_, __) => _buildCardWithoutBackground(),
    );
  }

  Widget _buildCardWithBackground(String imageUrl) {
    // Don't show background if it's a placeholder
    if (imageUrl.contains('placeholder')) {
      return _buildCardWithoutBackground();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        children: [
          // Background image layer with blur
          Positioned.fill(
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.grey.shade100);
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(color: Colors.grey.shade100);
              },
            ),
          ),
          // Blur and overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: Container(
                color: backgroundColor.withValues(alpha: overlayOpacity),
              ),
            ),
          ),
          // Card content
          Card(
            elevation: elevation,
            color: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              side: borderSide ?? BorderSide.none,
            ),
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardWithoutBackground() {
    return Card(
      elevation: elevation,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: borderSide ?? BorderSide.none,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

