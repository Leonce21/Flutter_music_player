import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../../../core/services/store_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/sort.dart';
import '../../../../core/widgets/cover_art.dart';
import '../../../../core/widgets/mume_scaffold.dart';
import '../../../../core/widgets/mume_scrollbar.dart'; 
import '../../../../core/widgets/song_list_tile.dart';
import '../../../../core/widgets/sort_menu.dart';
import '../../../../core/widgets/states.dart';
import '../../application/library_providers.dart';
import 'context_sheets.dart';

class _TabHeader extends StatelessWidget {
  const _TabHeader({required this.count, required this.tab});
  final String count;
  final String tab;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.screenH,
      vertical: AppSpacing.md,
    ),
    child: Row(
      children: [
        Text(count, style: AppTextStyles.subtitle),
        const Spacer(),
        SortMenu(tab: tab),
      ],
    ),
  );
}

List<T> _sorted<T>(List<T> src, String key, int Function(T, T, String) cmp) =>
    [...src]..sort((a, b) => cmp(a, b, key));

class SongsTab extends ConsumerWidget {
  const SongsTab({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lib = ref.watch(libraryProvider);
    final sort = ref.watch(sortPrefProvider('songs'));
    return lib.when(
      loading: () => const LoadingState(),
      error: (e, _) => ErrorState(
        message: '$e',
        onRetry: () => ref.read(libraryProvider.notifier).refresh(),
      ),
      data: (s) {
        final songs = _sorted(s.songs, sort, compareSongs);
        return Column(
          children: [
            _TabHeader(count: '${songs.length} songs', tab: 'songs'),
            Expanded(
              child: MumeScrollbar( // <-- WRAPPED
                child: ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (c, i) =>
                      SongListTile(song: songs[i], queue: songs),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ArtistsTab extends ConsumerWidget {
  const ArtistsTab({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lib = ref.watch(libraryProvider);
    final sort = ref.watch(sortPrefProvider('artists'));
    final counts = ref.watch(artistAlbumCounts);
    return lib.when(
      loading: () => const LoadingState(),
      error: (e, _) => ErrorState(message: '$e'),
      data: (s) {
        final artists = _sorted(s.artists, sort, (a, b, k) {
          if (k == 'Descending') return b.artist.compareTo(a.artist);
          return a.artist.toLowerCase().compareTo(b.artist.toLowerCase());
        });
        return Column(
          children: [
            _TabHeader(count: '${artists.length} artists', tab: 'artists'),
            Expanded(
              child: MumeScrollbar( // <-- WRAPPED
                child: ListView.builder(
                  itemCount: artists.length,
                  itemBuilder: (c, i) {
                    final a = artists[i];
                    final name = a.artist;
                    final albums = counts[name.toLowerCase()] ?? 0;
                    return InkWell(
                      onTap: () => context.push('/artist/${a.id}'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenH,
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            CircleAvatarArt(id: a.id, seed: name),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.subtitle,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$albums Album  |  ${a.numberOfTracks ?? 0} Songs',
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ),
                            IconBtn(
                              icon: AppIcons.more,
                              size: 18,
                              color: AppColors.textSecondary,
                              onTap: () => showArtistContextSheet(context, a),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class AlbumsTab extends ConsumerWidget {
  const AlbumsTab({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lib = ref.watch(libraryProvider);
    final sort = ref.watch(sortPrefProvider('albums'));
    return lib.when(
      loading: () => const LoadingState(),
      error: (e, _) => ErrorState(message: '$e'),
      data: (s) {
        final albums = _sorted(s.albums, sort, (a, b, k) {
          if (k == 'Descending') return b.album.compareTo(a.album);
          if (k == 'Year') return 0;
          return a.album.toLowerCase().compareTo(b.album.toLowerCase());
        });
        return Column(
          children: [
            _TabHeader(count: '${albums.length} albums', tab: 'albums'),
            Expanded(
              child: MumeScrollbar( // <-- WRAPPED
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenH,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.lg,
                    crossAxisSpacing: AppSpacing.lg,
                    childAspectRatio: 0.62,
                  ),
                  itemCount: albums.length,
                  itemBuilder: (c, i) {
                    final al = albums[i];
                    return InkWell(
                      onTap: () => context.push('/album/${al.id}'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ArtworkLoader(
                              id: al.id,
                              type: ArtworkType.ALBUM,
                              seed: al.album,
                              size: 400,
                              radius: AppRadius.md,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            al.album,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.subtitle,
                          ),
                          Text(
                            '${al.artist ?? ''}',
                            maxLines: 1,
                            style: AppTextStyles.caption,
                          ),
                          Text(
                            '${al.numOfSongs} songs',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class FoldersTab extends ConsumerWidget {
  const FoldersTab({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lib = ref.watch(libraryProvider);
    return lib.when(
      loading: () => const LoadingState(),
      error: (e, _) => ErrorState(message: '$e'),
      data: (s) => Column(
        children: [
          const _TabHeader(count: '', tab: 'folders'),
          Expanded(
            child: MumeScrollbar( // <-- WRAPPED
              child: ListView.builder(
                itemCount: s.folders.length,
                itemBuilder: (c, i) {
                  final f = s.folders[i];
                  return InkWell(
                    onTap: () => context.push('/folder/${f.id}'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenH,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          const FolderGlyph(size: 46),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  f.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.subtitle,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${f.numOfSongs} songs',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            AppIcons.more,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}