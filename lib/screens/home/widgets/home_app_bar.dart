import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../widgets/kfy_logo.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key, required this.onMenuTap});

  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
      child: Row(
        children: [
          const KfyLogo(size: 28, showWordmark: true),
          const Spacer(),
          IconButton(
            tooltip: 'Settings',
            onPressed: onMenuTap,
            style: IconButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            icon: const Icon(Icons.menu_rounded, size: 26),
          ),
        ],
      ),
    );
  }
}
