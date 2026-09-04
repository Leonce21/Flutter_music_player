import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../../../core/services/prefs.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/cover_art.dart';
import '../../../../core/widgets/mume_scaffold.dart';
import '../../../../core/widgets/song_list_tile.dart';
import '../../../../core/widgets/states.dart';
import 'package:go_router/go_router.dart';
import '../../application/library_providers.dart';

class SeeAllScreen extends ConsumerWidget {
  const SeeAllScreen({super.key, required this.type});
  final String type; // recent | artists | most

  String get _title => switch (type) {
        'artists' => 'Artists',
        'most' => 'Most Played',
        _ => 'Recently Played',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lib = ref.watch(libraryProvider);
    return MumeScaffold(
      kind: AppBarKind.back,
      onMore: () {},
      body: lib.when(
        loading: () => const LoadingState(),
        error: (e, _) => ErrorState(message: '$e'),
        data: (s) {
          if (type == 'artists') {
            return ListView.builder(
              itemCount: s.artists.length,
              itemBuilder: (c, i) {
                final a = s.artists[i];
                return InkWell(
                  onTap: () => context.push('/artist/${a.id}'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenH,
                        vertical: AppSpacing.sm),
                    child: Row(children: [
                      CircleAvatarArt(id: a.id, seed: a.artist ?? ''),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: Text(a.artist ?? 'Unknown',
                          style: const TextStyle())),
                    ]),
                  ),
                );
              },
            );
          }
          final byId = {for (final x in s.songs) x.id: x};
          List<SongModel> songs;
          if (type == 'most') {
            songs = [...s.songs]..sort((a, b) =>
                Prefs.playCount(b.id).compareTo(Prefs.playCount(a.id)));
          } else {
            songs = [for (final id in Prefs.recentsOrder())
              if (byId[id] != null) byId[id]!];
            if (songs.isEmpty) songs = s.songs;
          }
          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (c, i) =>
                SongListTile(song: songs[i], queue: songs),
          );
        },
      ),
    );
  }
}