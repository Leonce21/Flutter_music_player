// lib/features/library/application/library_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../../core/services/store_providers.dart';
import '../data/library_repository.dart';

final audioQueryProvider = Provider<OnAudioQuery>((ref) => OnAudioQuery());
final libraryRepoProvider = Provider((ref) =>
    LibraryRepository(ref.watch(audioQueryProvider)));

class LibraryState {
  const LibraryState({this.songs = const [], this.albums = const [],
      this.artists = const [], this.folders = const []});
  final List<SongModel> songs;
  final List<AlbumModel> albums;
  final List<ArtistModel> artists;
  final List<FolderItem> folders;
}

class LibraryNotifier extends AsyncNotifier<LibraryState> {
  Future<LibraryState>? _buildLock;

  @override
  Future<LibraryState> build() async {
    // If a build is already in flight, wait for it.
    // This prevents refresh() from launching a second concurrent scan.
    if (_buildLock != null) return _buildLock!;
    _buildLock = _build();
    try {
      return await _buildLock!;
    } finally {
      _buildLock = null;
    }
  }

  Future<LibraryState> _build() async {
    final repo = ref.watch(libraryRepoProvider);
    if (!await repo.ensurePermission()) {
      return const LibraryState(); // empty, permission denied
    }
    final bl = ref.watch(blacklistProvider);
    final songs = await repo.songs(bl);
    final albums = await repo.albums();
    final artists = await repo.artists();
    final folders = await repo.folders();
    return LibraryState(
      songs: songs,
      albums: albums,
      artists: artists,
      folders: folders,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

final libraryProvider =
    AsyncNotifierProvider<LibraryNotifier, LibraryState>(LibraryNotifier.new);

final artistAlbumCounts = Provider<Map<String, int>>((ref) {
  final counts = <String, int>{};
  for (final a in ref.watch(libraryProvider).valueOrNull?.albums ?? []) {
    final k = (a.artist ?? '').toLowerCase();
    counts[k] = (counts[k] ?? 0) + 1;
  }
  return counts;
});

final songById = Provider<Map<int, SongModel>>((ref) =>
    {for (final s in ref.watch(libraryProvider).valueOrNull?.songs ?? []) s.id: s});