// lib/features/home/presentation/widgets/suggested_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mume/core/theme/app_colors.dart';
import 'package:mume/core/theme/app_radius.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../../../core/services/store_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cover_art.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/states.dart';
import '../../../../features/player/application/player_controller.dart';
import '../../../library/application/library_providers.dart';

class SuggestedTab extends ConsumerWidget {
  const SuggestedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lib = ref.watch(libraryProvider);
    return lib.when(
      loading: () => const LoadingState(),
      error: (e, _) => ErrorState(
        message: '$e',
        onRetry: () => ref.read(libraryProvider.notifier).refresh(),
      ),
      data: (state) {
        if (state.songs.isEmpty) {
          return const EmptyState(
            message:
                'No music found.\n'
                'Make sure you have granted storage permission '
                'and have audio files on your device.',
          );
        }
        final recents = ref
            .watch(recentsProvider)
            .map((id) => ref.read(songById)[id])
            .whereType<SongModel>()
            .toList();
        final recent = recents.isEmpty
            ? state.songs.take(6).toList()
            : recents.take(6).toList();
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.read(libraryProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            children: [
              SectionHeader(
                title: 'Recently Played',
                onSeeAll: () => context.push('/see-all/recent'),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 160,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenH,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: recent.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.md),
                  itemBuilder: (c, i) =>
                      _ArtCard(song: recent[i], queue: recent),
                ),
              ),
              const SizedBox(height: AppSpacing.section),
              SectionHeader(
                title: 'Artists',
                onSeeAll: () => context.push('/see-all/artists'),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenH,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: state.artists.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.lg),
                  itemBuilder: (c, i) {
                    final a = state.artists[i];
                    return _ArtistChip(id: a.id, name: a.artist);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.section),
              SectionHeader(
                title: 'Most Played',
                onSeeAll: () => context.push('/see-all/most'),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 160,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenH,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: state.songs.length < 8 ? state.songs.length : 8,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.md),
                  itemBuilder: (c, i) =>
                      _ArtCard(song: state.songs[i], queue: state.songs),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ArtCard extends ConsumerWidget {
  const _ArtCard({required this.song, required this.queue});
  final SongModel song;
  final List<SongModel> queue;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () =>
          ref.read(playerProvider).playQueue(queue, queue.indexOf(song)),
      child: SizedBox(
        width: 108,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ArtworkLoader(
              id: song.albumId ?? song.id,
              type: ArtworkType.ALBUM,
              seed: song.title,
              size: 108,
              radius: AppRadius.md,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              song.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtistChip extends StatelessWidget {
  const _ArtistChip({required this.id, required this.name});
  final int id;
  final String name;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/artist/$id'),
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            CircleAvatarArt(id: id, seed: name, size: 76),
            const SizedBox(height: AppSpacing.sm),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
