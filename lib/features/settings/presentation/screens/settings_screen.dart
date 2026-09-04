// lib/features/settings/presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/services/store_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/dialogs.dart';
import '../../../../core/widgets/mume_logo.dart';
import '../../../../core/widgets/mume_scaffold.dart';
import '../../../library/application/library_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lib = ref.watch(libraryProvider).valueOrNull;

    return MumeScaffold(
      title: 'Settings',
      showSearch: false,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        children: [
          // ── LIBRARY SECTION ──
          const _SectionHeader(title: 'Library'),
          _SettingsTile(
            icon: AppIcons.musicNote,
            iconColor: AppColors.primary,
            title: 'Rescan Media Library',
            subtitle: '${lib?.songs.length ?? 0} songs indexed',
            onTap: () async {
              final repo = ref.read(libraryRepoProvider);
              await repo.rescan();
              await ref.read(libraryProvider.notifier).refresh();
              if (context.mounted) showSnack(context, 'Library refreshed.');
            },
          ),

          // ── DATA & PRIVACY SECTION ──
          const _SectionHeader(title: 'Data & Privacy'),
          _SettingsTile(
            icon: AppIcons.timer,
            iconColor: AppColors.primary,
            title: 'Clear Recently Played',
            onTap: () {
              ref.read(recentsProvider.notifier).clear();
              showSnack(context, 'Recently played cleared.');
            },
          ),
          _SettingsTile(
            icon: AppIcons.search,
            iconColor: AppColors.primary,
            title: 'Clear Search History',
            onTap: () {
              ref.read(historyProvider.notifier).clear();
              showSnack(context, 'Search history cleared.');
            },
          ),
          _SettingsTile(
            icon: AppIcons.heart,
            iconColor: AppColors.error,
            title: 'Clear Favorites',
            isDestructive: true,
            onTap: () async {
              if (await showConfirm(
                context,
                'Clear Favorites',
                'Are you sure you want to remove all favorite songs?',
              )) {
                ref.read(favoritesProvider.notifier).clear();
                if (context.mounted) showSnack(context, 'Favorites cleared.');
              }
            },
          ),

          // ── APP SECTION ──
          const _SectionHeader(title: 'App'),
          _SettingsTile(
            icon: AppIcons.share,
            iconColor: AppColors.primary,
            title: 'Share Mume',
            subtitle: 'Tell your friends about us',
            onTap: () {
              Share.share(
                'Check out Mume, a beautiful offline music player! Enjoy your music with zero distractions.',
              );
            },
          ),

          // ── ABOUT SECTION ──
          const _SectionHeader(title: 'About'),
          _SettingsTile(
            icon: AppIcons.info,
            iconColor: AppColors.primary,
            title: 'About Mume',
            subtitle: 'Version 1.0.0',
            onTap: () => _showAboutDialog(context),
          ),

          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Text(
              'Made with ❤️ by FOTSO Leonce',
              style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Row(
          children: [
            const MumeLogo(size: 32, showWordmark: false),
            const SizedBox(width: 12),
            Text('Mume', style: AppTextStyles.title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0', style: AppTextStyles.body),
            const SizedBox(height: 12),
            Text(
              'An offline-first, beautiful local music player designed for audiophiles. Enjoy your music with zero distractions.',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Text(
              'Developed with ❤️ using Flutter',
              style: AppTextStyles.caption,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Close',
              style: AppTextStyles.button.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

/// ── UI COMPONENTS ─────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.lg,
        AppSpacing.screenH,
        AppSpacing.sm,
      ),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenH,
            vertical: AppSpacing.md + 2,
          ),
          child: Row(
            children: [
              // Tinted Icon Container
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: AppSpacing.lg),
              
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.subtitle.copyWith(
                        color: isDestructive ? AppColors.error : AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ],
                ),
              ),
              
              // Trailing Chevron
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.textTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}