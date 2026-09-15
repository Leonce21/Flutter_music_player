import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/store_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/dialogs.dart';
import '../../../../core/widgets/mume_scaffold.dart';
import '../../../../core/widgets/mume_scrollbar.dart';
import '../../../../core/widgets/states.dart';

class PlaylistsScreen extends ConsumerWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lists = ref.watch(playlistsProvider);
    
    return MumeScaffold(
      title: 'Playlists',
      showSearch: false,
      moreIcon: AppIcons.add, // ✅ FIX 1: Use a plus icon for creating playlists
      onMore: () => _createPlaylist(context, ref),
      body: lists.isEmpty
          ? const _EmptyPlaylists()
          : MumeScrollbar(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                itemCount: lists.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  color: AppColors.divider,
                  thickness: 0.5,
                ),
                itemBuilder: (context, index) {
                  final entry = lists.entries.elementAt(index);
                  final name = entry.key;
                  final songIds = entry.value;

                  return InkWell(
                    onTap: () => context.push('/playlist/${Uri.encodeComponent(name)}'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenH,
                        vertical: AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primaryAlpha(40),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: const Icon(
                              AppIcons.playlists,
                              size: 24,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: AppTextStyles.subtitle),
                                const SizedBox(height: 4),
                                Text('${songIds.length} songs', style: AppTextStyles.caption),
                              ],
                            ),
                          ),
                          // ✅ FIX 3: Explicitly use a red trash icon for deletion
                          IconBtn(
                            icon: AppIcons.trash,
                            size: 18,
                            color: AppColors.error,
                            onTap: () async {
                              final confirm = await showConfirm(
                                context,
                                'Delete Playlist',
                                'Are you sure you want to delete "$name"?',
                                yes: 'Delete',
                              );
                              if (confirm) {
                                ref.read(playlistsProvider.notifier).delete(name);
                                if (context.mounted) {
                                  showSnack(context, 'Playlist deleted.');
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  void _createPlaylist(BuildContext context, WidgetRef ref) async {
    final name = await showTextDialog(context, 'Create Playlist', hint: 'Playlist name');
    if (name != null && name.trim().isNotEmpty) {
      ref.read(playlistsProvider.notifier).create(name.trim());
      if (context.mounted) showSnack(context, 'Playlist "$name" created.');
    }
  }
}

class _EmptyPlaylists extends StatelessWidget {
  const _EmptyPlaylists();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(AppIcons.playlists, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('No playlists yet', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tap the + icon at the top right to create your first playlist.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
          ],
        ),
      ),
    );
  }
}