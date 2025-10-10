import 'package:flutter/material.dart';
import '../utils/theme_constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: ThemeConstants.appBarGradient,
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: leading,
        title: subtitle != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: ThemeConstants.appBarTitleStyle,
                  ),
                  Text(
                    subtitle!,
                    style: ThemeConstants.appBarSubtitleStyle,
                  ),
                ],
              )
            : Text(
                title,
                style: ThemeConstants.appBarTitleStyle,
              ),
        actions: actions,
        bottom: bottom,
        iconTheme: const IconThemeData(color: ThemeConstants.onPrimaryColor),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );
}
