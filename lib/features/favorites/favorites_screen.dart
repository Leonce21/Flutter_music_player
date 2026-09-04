// lib/features/favorites/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/store_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/mume_scaffold.dart';
import '../../core/widgets/mume_scrollbar.dart';
import '../../core/widgets/song_list_tile.dart';
import '../../core/widgets/states.dart';
import '../library/application/library_providers.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lib = ref.watch(libraryProvider);
    final favIds = ref.watch(favoritesProvider);
    final byId = ref.watch(songById);

    return MumeScaffold(
      title: 'Favorites',
      showSearch: false,
      body: lib.when(
        loading: () => const LoadingState(),
        error: (e, _) => ErrorState(
          message: '$e',
          onRetry: () => ref.read(libraryProvider.notifier).refresh(),
        ),
        data: (_) {
          final songs = [
            for (final id in favIds)
              if (byId[id] != null) byId[id]!,
          ];

          return songs.isEmpty
              ? const _EmptyFavorites()
              : MumeScrollbar(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm),
                    itemCount: songs.length,
                    itemBuilder: (context, index) =>
                        SongListTile(song: songs[index], queue: songs),
                  ),
                );
        },
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

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
              child:
                  Icon(AppIcons.heart, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('No favorites yet', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Songs you heart will appear here.\n'
              'Tap the heart icon on any song to add it.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
          ],
        ),
      ),
    );
  }
}