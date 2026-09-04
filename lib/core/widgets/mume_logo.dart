// lib/core/widgets/mume_logo.dart
import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class MumeLogo extends StatelessWidget {
  const MumeLogo({super.key, this.size = 34, this.showWordmark = true});
  
  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ✅ NEW: Display the actual Sonora logo image
        ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.22), // Matches the rounded square shape
          child: Image.asset(
            'assets/icon/sonora_icon.png',
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
        if (showWordmark) ...[
          const SizedBox(width: 1),
          Text(
            'Sonora', // ✅ Updated from 'Mume'
            style: AppTextStyles.h1.copyWith(fontSize: size * 0.62),
          ),
        ],
      ],
    );
  }
}