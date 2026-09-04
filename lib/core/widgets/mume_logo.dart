import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_text_styles.dart';

class MumeLogo extends StatelessWidget {
  const MumeLogo({super.key, this.size = 34, this.showWordmark = true});
  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: size, height: size,
        decoration: const BoxDecoration(
            color: AppColors.primary, shape: BoxShape.circle),
        child: Icon(AppIcons.musicNote,
            size: size * 0.55, color: AppColors.textPrimary),
      ),
      if (showWordmark) ...[
        const SizedBox(width: 10),
        Text('Mume', style: AppTextStyles.h1.copyWith(fontSize: size * 0.62)),
      ],
    ]);
  }
}