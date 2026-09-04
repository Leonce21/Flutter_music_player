import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'shuffle_play_row.dart';

class DetailHeader extends StatelessWidget {
  const DetailHeader({super.key, required this.art, required this.name,
      required this.stats, required this.onShuffle, required this.onPlay});
  final Widget art; final String name; final String stats;
  final VoidCallback onShuffle; final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(children: [
        art,
        const SizedBox(height: AppSpacing.lg),
        Text(name, style: AppTextStyles.title.copyWith(fontSize: 21),
            textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.xs),
        Text(stats, style: AppTextStyles.caption),
        const SizedBox(height: AppSpacing.lg),
        ShufflePlayButtonRow(onShuffle: onShuffle, onPlay: onPlay),
      ]),
    );
  }
}