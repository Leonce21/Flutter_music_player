import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../features/player/application/player_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'cover_art.dart';
import 'mume_scaffold.dart';
import 'play_pause_icon.dart';

class MiniPlayerBar extends ConsumerWidget {
  const MiniPlayerBar({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pc = ref.watch(playerProvider);
    return StreamBuilder<int?>(
      stream: pc.player.currentIndexStream,
      builder: (context, _) {
        final song = pc.currentSong;
        if (song == null) return const SizedBox.shrink();
        return Material(
          color: AppColors.surfaceDeep,
          child: InkWell(
            onTap: () => context.push('/now'),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenH, vertical: AppSpacing.sm),
              child: Row(children: [
                Hero(
                  tag: 'art-current',
                  child: ArtworkLoader(id: song.albumId ?? song.id,
                      type: ArtworkType.ALBUM, seed: song.title, size: 44),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _Meta(song: song)),
                _Ctl(song: song),
              ]),
            ),
          ),
        );
      },
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.song});
  final SongModel song;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
        children: [
          Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: AppTextStyles.subtitle),
          Text('${song.artist ?? 'Unknown'} · ${song.album ?? ''}',
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption),
        ]);
}

class _Ctl extends ConsumerWidget {
  const _Ctl({required this.song});
  final SongModel song;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pc = ref.watch(playerProvider);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      StreamBuilder<bool>(
        stream: pc.player.playingStream,
        builder: (c, s) => PlayPauseIcon(playing: s.data ?? false,
            size: 26, color: AppColors.primary, onTap: pc.toggle),
      ),
      const SizedBox(width: AppSpacing.md),
      IconBtn(icon: AppIcons.skipNext, onTap: pc.next),
    ]);
  }
}