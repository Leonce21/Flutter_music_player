// lib/features/library/data/library_repository.dart
import 'dart:async';
import 'package:mume/core/services/permissions.dart';
import 'package:on_audio_query/on_audio_query.dart';

class FolderItem {
  FolderItem(this.name, this.path, this.songs);
  final String name;
  final String path;
  final List<SongModel> songs;
  int get id => path.hashCode;
  int get numOfSongs => songs.length;
}

class LibraryRepository {
  LibraryRepository(this._q);
  final OnAudioQuery _q;

  // ── Serialization lock ──────────────────────────────────────
  // The on_audio_query plugin crashes with "Reply already submitted"
  // when two native queries run concurrently. This guard ensures
  // only one query executes at a time.
  Future? _active;

  Future<T> _guard<T>(Future<T> Function() fn) async {
    while (_active != null) {
      await _active!;
    }
    final c = Completer<void>();
    _active = c.future;
    try {
      return await fn();
    } finally {
      c.complete();
      _active = null;
    }
  }
  // ───────────────────────────────────────────────────────────

  Future<bool> ensurePermission() => PermissionsService.ensureAudioPermission();

  Future<List<SongModel>> songs(List<int> blacklist) => _guard(() async {
    if (!await ensurePermission()) {
      print('Permission denied in songs()');
      return [];
    }
    final all = await _q.querySongs();
    print('querySongs returned ${all.length} songs');
    for (final s in all.take(5)) {
      print('  ${s.title} - ${s.data}');
    }
    return all.where((s) => !blacklist.contains(s.id)).toList();
  });

  Future<List<AlbumModel>> albums() => _guard(() async {
    if (!await ensurePermission()) return [];
    return _q.queryAlbums();
  });

  Future<List<ArtistModel>> artists() => _guard(() async {
    if (!await ensurePermission()) return [];
    return _q.queryArtists();
  });

  Future<List<FolderItem>> folders() => _guard(() async {
    if (!await ensurePermission()) return [];
    final all = await _q.querySongs();
    final map = <String, List<SongModel>>{};
    for (final s in all) {
      final path = s.data;
      final lastSlash = path.lastIndexOf('/');
      final dir = lastSlash == -1 ? '/' : path.substring(0, lastSlash);
      map.putIfAbsent(dir, () => []).add(s);
    }
    return map.entries.map((e) {
      final name = e.key.split('/').last;
      return FolderItem(name.isEmpty ? e.key : name, e.key, e.value);
    }).toList();
  });

  Future<List<SongModel>> fromAlbum(int id) => _guard(() async {
    if (!await ensurePermission()) return [];
    return _q.queryAudiosFrom(AudiosFromType.ALBUM_ID, id);
  });

  Future<List<SongModel>> fromArtist(int id) => _guard(() async {
    if (!await ensurePermission()) return [];
    return _q.queryAudiosFrom(AudiosFromType.ARTIST_ID, id);
  });

  Future<List<SongModel>> fromFolder(String path) => _guard(() async {
    if (!await ensurePermission()) return [];
    final all = await _q.querySongs();
    return all.where((s) => s.data.startsWith(path)).toList();
  });

  Future<void> rescan() => _guard(() => _q.scanMedia('')).then((_) {});
}
