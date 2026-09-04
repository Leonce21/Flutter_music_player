// lib/features/player/application/player_controller.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../../core/services/prefs.dart';
import '../../../core/services/store_providers.dart';
import '../../../core/utils/lrc.dart';

class PlayerController {
  PlayerController(this._ref) {
    _sub = player.currentIndexStream.listen((i) {
      if (i != null && i < queue.length) {
        _ref.read(recentsProvider.notifier).log(queue[i].id);
        Prefs.bumpCount(queue[i].id);
        _loadLyrics(queue[i]);
      }
    });
  }

  final Ref _ref;
  final AudioPlayer player = AudioPlayer();
  List<SongModel> queue = [];
  Timer? _sleep;
  StreamSubscription<int?>? _sub;
  List<LrcLine> lyrics = [];

  SongModel? get currentSong =>
      queue.isEmpty ? null : queue[player.currentIndex ?? 0];

  Future<void> playQueue(List<SongModel> songs, int index) async {
    queue = List.of(songs);
    final sources = queue.map((s) => AudioSource.uri(
          Uri.file(s.data),
          tag: MediaItem(
            id: 'mume-${s.id}',
            title: s.title,
            artist: s.artist ?? 'Unknown artist',
            album: s.album ?? '',
            duration: s.duration == null
                ? null : Duration(milliseconds: s.duration!),
          ),
        )).toList();
    await player.setAudioSource(
      ConcatenatingAudioSource(children: sources),
      initialIndex: index,
    );
    await player.play();
  }

  Future<void> toggle() async =>
      player.playing ? await player.pause() : await player.play();

  Future<void> next() => player.seekToNext();
  Future<void> previous() => player.seekToPrevious();
  Future<void> seekBy(Duration d) async =>
      player.seek(player.position + d);
  Future<void> seek(Duration d) => player.seek(d);

  /// FIXED: Handle empty queue safely.
  void playNextInQueue(SongModel s) {
    if (queue.isEmpty || player.audioSource == null) {
      playQueue([s], 0);
      return;
    }
    final at = (player.currentIndex ?? 0) + 1;
    final clampedAt = at.clamp(0, queue.length);
    queue.insert(clampedAt, s);
    _insertSource(clampedAt, s);
  }

  void enqueue(SongModel s) {
    queue.add(s);
    _insertSource(queue.length - 1, s);
  }

  void _insertSource(int i, SongModel s) {
    final source = AudioSource.uri(
      Uri.file(s.data),
      tag: MediaItem(
        id: 'mume-${s.id}',
        title: s.title,
        artist: s.artist ?? '',
        album: s.album ?? '',
      ),
    );
    (player.audioSource as ConcatenatingAudioSource?)?.insert(i, source);
  }

  Future<void> toggleShuffle() =>
      player.setShuffleModeEnabled(!player.shuffleModeEnabled);

  Future<void> cycleLoop() async {
    switch (player.loopMode) {
      case LoopMode.off: await player.setLoopMode(LoopMode.all); break;
      case LoopMode.all: await player.setLoopMode(LoopMode.one); break;
      case LoopMode.one: await player.setLoopMode(LoopMode.off); break;
    }
  }

  void setSleepTimer(Duration? d) {
    _sleep?.cancel();
    if (d != null) _sleep = Timer(d, () => player.pause());
  }

  void _loadLyrics(SongModel s) async {
    lyrics = [];
    final base = s.data.replaceAll(RegExp(r'\.[a-z0-9]+$'), '');
    for (final ext in ['.lrc', '.Lrc', '.LRC']) {
      final f = File(base + ext);
      if (f.existsSync()) {
        lyrics = LrcParser.parse(await f.readAsString()) ?? [];
        break;
      }
    }
  }

  void dispose() { _sub?.cancel(); _sleep?.cancel(); player.dispose(); }
}

final playerProvider = Provider<PlayerController>((ref) {
  final c = PlayerController(ref);
  ref.onDispose(c.dispose);
  return c;
});