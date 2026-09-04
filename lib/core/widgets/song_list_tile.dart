import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mume/core/widgets/mume_scaffold.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../features/player/application/player_controller.dart';
import '../../features/library/presentation/widgets/context_sheets.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'cover_art.dart';
import 'play_pause_icon.dart';
import '../utils/formatters.dart';

class SongListTile extends ConsumerWidget {
  const SongListTile({super.key, required this.song, required this.queue});
  final SongModel song;
  final List<SongModel> queue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pc = ref.watch(playerProvider);
    return StreamBuilder<int?>(
      stream: pc.player.currentIndexStream,
      builder: (context, _) {
        final isCurrent = pc.currentSong?.id == song.id;
        return StreamBuilder<bool>(
          stream: pc.player.playingStream,
          builder: (context, ps) {
            final playing = (ps.data ?? false) && isCurrent;
            return InkWell(
              onTap: () => isCurrent
                  ? pc.toggle()
                  : pc.playQueue(queue, queue.indexOf(song)),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenH,
                    vertical: AppSpacing.sm),
                child: Row(children: [
                  ArtworkLoader(id: song.albumId ?? song.id,
                      type: ArtworkType.ALBUM, seed: song.title),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(song.title, maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.subtitle.copyWith(
                                color: isCurrent
                                    ? AppColors.primary
                                    : AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text(
                            '${song.artist ?? 'Unknown'}  |  '
                            '${fmtMs(song.duration)}',
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption),
                      ])),
                  const SizedBox(width: AppSpacing.sm),
                  PlayPauseIcon(playing: playing, onTap: () => isCurrent
                      ? pc.toggle() : pc.playQueue(queue, queue.indexOf(song)),
                      size: 20, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  IconBtn(icon: AppIcons.more, size: 18,
                      color: AppColors.textSecondary,
                      onTap: () => showSongContextSheet(context, song)),
                ]),
              ),
            );
          },
        );
      },
    );
  }
}