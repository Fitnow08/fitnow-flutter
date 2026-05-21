import 'package:fitnow/core/configs/theme/app_colors.dart';
import 'package:flutter/material.dart';

class BasicAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BasicAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.hideBack = false,
    this.centerTitle = true,
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool hideBack;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title ?? const Text('FitNow'),
      centerTitle: centerTitle,
      elevation: 0,
      backgroundColor: AppColors.appBarBG,
      automaticallyImplyLeading: !hideBack,
      leading: leading,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
