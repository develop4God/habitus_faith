import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? titleText;
  final Widget? titleWidget;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    this.titleText,
    this.titleWidget,
    this.bottom,
  });

  @override
  Size get preferredSize {
    final double appBarHeight =
        kToolbarHeight + (bottom?.preferredSize.height ?? 0);
    return Size.fromHeight(appBarHeight);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppBar(
      title: titleWidget ??
          Text(
            titleText ?? '',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onPrimary,
            ),
          ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      iconTheme: IconThemeData(
        color: colorScheme.onPrimary,
      ),
      bottom: bottom,
    );
  }
}
