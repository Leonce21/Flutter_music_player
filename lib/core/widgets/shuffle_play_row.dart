import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class ShufflePlayButtonRow extends StatelessWidget {
  const ShufflePlayButtonRow({super.key,
      required this.onShuffle, required this.onPlay});
  final VoidCallback onShuffle; final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _Pill(label: 'Shuffle', icon: AppIcons.shuffle, filled: true,
          onTap: onShuffle),
      const SizedBox(width: AppSpacing.lg),
      _Pill(label: 'Play', icon: AppIcons.play, filled: false, onTap: onPlay),
    ]);
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.icon,
      required this.filled, required this.onTap});
  final String label; final IconData icon;
  final bool filled; final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      onTap: onTap,
      child: Container(
        width: 148, height: 46,
        decoration: BoxDecoration(
          gradient: filled ? AppColors.primaryGradient : null,
          color: filled ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: filled
              ? [BoxShadow(color: AppColors.primaryAlpha(90),
                  blurRadius: 14, offset: const Offset(0, 6))]
              : null,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18,
              color: filled ? AppColors.textPrimary : AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTextStyles.button),
        ]),
      ),
    );
  }
}