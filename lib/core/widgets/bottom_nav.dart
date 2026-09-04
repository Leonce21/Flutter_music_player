import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

class MumeBottomNav extends StatelessWidget {
  const MumeBottomNav({super.key, required this.index});
  final int index;

  static const _items = [
    ('/home', 'Home', AppIcons.home),
    ('/favorites', 'Favorites', AppIcons.heart),
    ('/playlists', 'Playlists', AppIcons.playlists),
    ('/settings', 'Settings', AppIcons.settings),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceDeep,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < _items.length; i++)
            _NavTile(
              icon: _items[i].$3, label: _items[i].$2, active: i == index,
              onTap: () => context.go(_items[i].$1),
            ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.icon, required this.label,
      required this.active, required this.onTap});
  final IconData icon; final String label;
  final bool active; final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = active ? AppColors.primary : AppColors.textTertiary;
    return InkWell(
      onTap: onTap,
      child: AnimatedScale(
        scale: active ? 1.05 : 1,
        duration: AppTheme.dur(150), curve: Curves.easeOutCubic,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 22, color: c),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.navLabel.copyWith(
                color: active ? AppColors.primary : AppColors.textTertiary)),
          ]),
        ),
      ),
    );
  }
}