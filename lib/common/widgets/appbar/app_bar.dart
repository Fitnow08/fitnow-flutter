import 'package:fitnow/core/configs/theme/app_colors.dart';
import 'package:flutter/material.dart';

class BasicAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BasicAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('FitNow'),
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.dartBG,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
