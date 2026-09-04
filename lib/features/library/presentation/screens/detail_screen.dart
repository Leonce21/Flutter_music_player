import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../../../core/services/store_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/cover_art.dart';
import '../../../../core/widgets/detail_header.dart';
import '../../../../core/widgets/mume_scaffold.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/song_list_tile.dart';
import '../../../../core/widgets/states.dart';
import '../../../player/application/player_controller.dart';
import '../../application/library_providers.dart';
import '../../data/library_repository.dart';

enum DetailKind { artist, album, folder, playlist }

class DetailScreen extends ConsumerStatefulWidget {
  const DetailScreen({super.key, required this.kind, this.id, this.name});
  final DetailKind kind;
  final int? id;
  final String? name;

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  List<SongModel>? _songs;
  String _title = '';
  String _stats = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(libraryRepoProvider);
    List<SongModel> songs = [];
    switch (widget.kind) {
      case DetailKind.artist:
        songs = await repo.fromArtist(widget.id!);
        final lib = ref.read(libraryProvider).valueOrNull;
        final albums =
            lib?.albums
                .where(
                  (a) =>
                      (a.artist ?? '').toLowerCase() ==
                      (songs.isNotEmpty ? songs.first.artist ?? '' : '')
                          .toLowerCase(),
                )
                .length ??
            0;
        _title = songs.isNotEmpty ? songs.first.artist ?? 'Unknown' : 'Artist';
        _stats =
            '$albums Album  |  ${songs.length} Songs  |  '
            '${fmtLong(_total(songs))} mins';
      case DetailKind.album:
        songs = await repo.fromAlbum(widget.id!);
        _title = songs.isNotEmpty ? songs.first.album ?? 'Album' : 'Album';
        _stats = '${songs.first.artist ?? ''}  |  ${songs.length} songs';
      case DetailKind.folder:
        final lib = ref.read(libraryProvider).valueOrNull;
        final folder = lib?.folders.firstWhere(
          (f) => f.id == widget.id,
          orElse: () => FolderItem('', '', []),
        );
        songs = folder?.songs ?? [];
        _title = folder?.name ?? 'Folder';
        _stats = '${songs.length} Songs  |  ${fmtLong(_total(songs))} mins';
      case DetailKind.playlist:
        final ids = ref.read(playlistsProvider)[widget.name] ?? [];
        final byId = ref.read(songById);
        songs = [
          for (final i in ids)
            if (byId[i] != null) byId[i]!,
        ];
        _title = widget.name ?? 'Playlist';
        _stats = '${songs.length} Songs  |  ${fmtLong(_total(songs))} mins';
    }
    if (mounted) setState(() => _songs = songs);
  }

  Duration _total(List<SongModel> s) =>
      Duration(milliseconds: s.fold<int>(0, (p, e) => p + (e.duration ?? 0)));

  @override
  Widget build(BuildContext context) {
    final songs = _songs;
    final pc = ref.watch(playerProvider);
    return MumeScaffold(
      kind: AppBarKind.back,
      onMore: () {},
      body: songs == null
          ? const LoadingState()
          : ListView(
              children: [
                DetailHeader(
                  art: _art(),
                  name: _title,
                  stats: _stats,
                  onShuffle: () => pc.playQueue(List.of(songs)..shuffle(), 0),
                  onPlay: () => pc.playQueue(songs, 0),
                ),
                const SizedBox(height: AppSpacing.section),
                SectionHeader(title: 'Songs'),
                const SizedBox(height: AppSpacing.sm),
                for (final s in songs) SongListTile(song: s, queue: songs),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
    );
  }

  Widget _art() {
    switch (widget.kind) {
      case DetailKind.folder:
        return const FolderGlyph(size: 150);
      case DetailKind.playlist:
        return Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: AppColors.primaryAlpha(40),
            borderRadius: BorderRadius.circular(AppRadius.art),
          ),
          child: const Icon(
            Icons.playlist_play,
            size: 64,
            color: AppColors.primary,
          ),
        );
      case DetailKind.album:
        return ArtworkLoader(
          id: widget.id!,
          type: ArtworkType.ALBUM,
          seed: _title,
          size: 210,
          radius: AppRadius.art,
        );
      default:
        return ArtworkLoader(
          id: _songs?.firstOrNull?.artistId ?? widget.id!,
          type: ArtworkType.ARTIST,
          seed: _title,
          size: 210,
          radius: AppRadius.art,
        );
    }
  }
}
