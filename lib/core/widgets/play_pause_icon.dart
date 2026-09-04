import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// AnimatedIcon play↔pause morph, 200ms ease.
class PlayPauseIcon extends StatefulWidget {
  const PlayPauseIcon({super.key, required this.playing, required this.onTap,
      this.size = 24, this.color = AppColors.primary,
      this.filledCircle = false});
  final bool playing;
  final VoidCallback onTap;
  final double size;
  final Color color;
  final bool filledCircle;

  @override
  State<PlayPauseIcon> createState() => _PlayPauseIconState();
}

class _PlayPauseIconState extends State<PlayPauseIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: AppTheme.dur(200),
      value: widget.playing ? 1 : 0);

  @override
  void didUpdateWidget(PlayPauseIcon old) {
    super.didUpdateWidget(old);
    if (old.playing != widget.playing) {
      widget.playing ? _c.forward() : _c.reverse();
    }
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final glyph = AnimatedIcon(
        icon: AnimatedIcons.play_pause, progress: _c,
        size: widget.size, color: widget.color);
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: widget.onTap,
      child: widget.filledCircle
          ? Container(
              width: widget.size * 2.1, height: widget.size * 2.1,
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
              child: AnimatedIcon(icon: AnimatedIcons.play_pause,
                  progress: _c, size: widget.size,
                  color: AppColors.background))
          : glyph,
    );
  }
}