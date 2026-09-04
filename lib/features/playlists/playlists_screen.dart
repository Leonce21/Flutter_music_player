// playlists_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/store_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
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
      showSearch: true,
      body: lists.isEmpty
          ? const EmptyState(message: 'Create a playlist to get started.')
          : MumeScrollbar(
              child: ListView(
                children: [
                  for (final e in lists.entries)
                    InkWell(
                      onTap: () => context.push(
                          '/playlist/${Uri.encodeComponent(e.key)}'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenH,
                            vertical: AppSpacing.sm),
                        child: Row(children: [
                          const Icon(AppIcons.playlists, size: 40,
                              color: AppColors.primary),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(e.key, style: AppTextStyles.subtitle),
                                    Text('${e.value.length} songs',
                                        style: AppTextStyles.caption),
                                  ])),
                          IconBtn(
                              icon: AppIcons.trash, size: 18,
                              color: AppColors.textSecondary,
                              onTap: () => ref
                                  .read(playlistsProvider.notifier)
                                  .delete(e.key)),
                        ]),
                      ),
                    ),
                ],
              ),
            ),
      onMore: () async {
        final name = await showTextDialog(context, 'Create playlist',
            hint: 'Playlist name');
        if (name != null) {
          ref.read(playlistsProvider.notifier).create(name);
        }
      },
    );
  }
}