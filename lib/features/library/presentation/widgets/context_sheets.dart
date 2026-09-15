import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart' hide ContextAction;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/services/store_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/context_sheet.dart';
import '../../../../core/widgets/cover_art.dart';
import '../../../../core/widgets/dialogs.dart';
import '../../../player/application/player_controller.dart';
import '../../application/library_providers.dart';

const _ringtoneChannel = MethodChannel('com.mume/ringtone');

void showSongContextSheet(BuildContext context, SongModel song) {
  final ref = ProviderScope.containerOf(context);
  final pc = ref.read(playerProvider);
  showContextSheet(
    context,
    header: SongContextHeader(song: song),
    actions: [
      ContextAction(
        icon: AppIcons.play,
        label: 'Play',
        onTap: () => pc.playNextInQueue(song),
      ),
      // ✅ UNCOMMENTED: Add to Playlist is now fully functional
      ContextAction(
        icon: AppIcons.addPlaylist,
        label: 'Add to Playlist',
        onTap: () {
          print('DEBUG: Add to Playlist tapped');
          showPlaylistPicker(context, song);
        },
      ),
      ContextAction(
        icon: AppIcons.info,
        label: 'Details',
        onTap: () => showSongDetailsDialog(context, song),
      ),
      if (Platform.isAndroid)
        ContextAction(
          icon: AppIcons.ringtone,
          label: 'Set as Ringtone',
          onTap: () async {
            try {
              final ok = await _ringtoneChannel.invokeMethod('setRingtone', {
                'uri': song.uri,
                'path': song.data,
              });
              if (ok != true && context.mounted) {
                showSnack(context, 'No app found to set ringtone.');
              }
            } catch (e) {
              if (context.mounted) {
                showSnack(context, 'Could not set ringtone: $e');
              }
            }
          },
        ),
      ContextAction(
        icon: AppIcons.share,
        label: 'Share',
        onTap: () => Share.shareXFiles([XFile(song.data)]),
      ),
      ContextAction(
        icon: AppIcons.trash,
        label: 'Delete from Device',
        destructive: true,
        onTap: () async {
          if (await showConfirm(
            context,
            'Delete',
            'Permanently delete "${song.title}" from this device?',
            yes: 'Delete',
          )) {
            bool deleted = false;
            String? error;
            try {
              final uri = song.uri ?? 'content://media/external/audio/media/${song.id}';
              if (uri.startsWith('content://')) {
                deleted = await _ringtoneChannel.invokeMethod('deleteAudioFile', {
                  'uri': uri,
                }) ?? false;
              }
              if (!deleted) {
                final f = File(song.data);
                if (f.existsSync()) {
                  f.deleteSync();
                  deleted = true;
                }
              }
            } catch (e) {
              error = e.toString();
            }
            if (deleted) {
              await ref.read(libraryProvider.notifier).refresh();
              if (context.mounted) showSnack(context, 'Deleted.');
            } else {
              if (context.mounted) {
                showSnack(context, 'Could not delete the file.${error != null ? '\n$error' : ''}');
              }
            }
          }
        },
      ),
    ],
  );
}

void showPlaylistPicker(BuildContext context, SongModel song) {
  print('DEBUG: showPlaylistPicker called');
  final ref = ProviderScope.containerOf(context);
  final lists = ref.read(playlistsProvider);
  print('DEBUG: Playlists found: ${lists.keys.toList()}');
  
  try {
    showContextSheet(
      context,
      header: lists.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text('No playlists yet. Create one first!', style: AppTextStyles.body),
            )
          : null,
      actions: [
        if (lists.isNotEmpty)
          for (final name in lists.keys)
            ContextAction(
              icon: AppIcons.playlists,
              label: name,
              onTap: () {
                print('DEBUG: Adding song ${song.title} to playlist: $name');
                ref.read(playlistsProvider.notifier).addTo(name, song.id);
                if (context.mounted) {
                  showSnack(context, 'Added to $name');
                }
              },
            ),
        ContextAction(
          icon: AppIcons.add,
          label: 'New playlist',
          onTap: () async {
            print('DEBUG: Creating new playlist');
            final name = await showTextDialog(context, 'Create playlist', hint: 'Playlist name');
            if (name != null && name.trim().isNotEmpty) {
              print('DEBUG: New playlist name: $name');
              ref.read(playlistsProvider.notifier).create(name.trim());
              ref.read(playlistsProvider.notifier).addTo(name.trim(), song.id);
              if (context.mounted) {
                showSnack(context, 'Created and added to "$name"');
              }
            }
          },
        ),
      ],
    );
  } catch (e) {
    print('ERROR in showPlaylistPicker: $e');
    if (context.mounted) {
      showSnack(context, 'Error: $e');
    }
  }
}

void showPlaylistSongContextSheet(BuildContext context, String playlistName, SongModel song, WidgetRef ref) {
  showContextSheet(
    context,
    header: SongContextHeader(song: song),
    actions: [
      ContextAction(
        icon: AppIcons.play,
        label: 'Play',
        onTap: () {
          ref.read(playerProvider).playQueue([song], 0);
        },
      ),
      ContextAction(
        icon: AppIcons.trash,
        label: 'Remove from Playlist',
        destructive: true,
        onTap: () {
          ref.read(playlistsProvider.notifier).removeFrom(playlistName, song.id);
          showSnack(context, 'Removed from playlist');
        },
      ),
    ],
  );
}

class SongContextHeader extends ConsumerWidget {
  const SongContextHeader({super.key, required this.song});
  final SongModel song;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fav = ref.watch(favoritesProvider).contains(song.id);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.lg,
        AppSpacing.screenH,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          ArtworkLoader(
            id: song.albumId ?? song.id,
            type: ArtworkType.ALBUM,
            seed: song.title,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.subtitle,
                ),
                const SizedBox(height: 2),
                Text(
                  '${song.artist ?? 'Unknown'}  |  ${fmtMs(song.duration)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => ref.read(favoritesProvider.notifier).toggle(song.id),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                AppIcons.heart,
                size: 22,
                color: fav ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showArtistContextSheet(BuildContext context, ArtistModel artist) {
  final ref = ProviderScope.containerOf(context);
  final pc = ref.read(playerProvider);
  final repo = ref.read(libraryRepoProvider);
  Future<List<SongModel>> songs() => repo.fromArtist(artist.id);
  showContextSheet(
    context,
    actions: [
      ContextAction(
        icon: AppIcons.play,
        label: 'Play',
        onTap: () async => pc.playQueue(await songs(), 0),
      ),
      ContextAction(
        icon: AppIcons.playNext,
        label: 'Play Next',
        onTap: () async {
          final s = await songs();
          if (s.isNotEmpty) pc.playNextInQueue(s.first);
        },
      ),
      ContextAction(
        icon: AppIcons.queue,
        label: 'Add to Playing Queue',
        onTap: () async {
          final s = await songs();
          if (s.isNotEmpty) pc.enqueue(s.first);
        },
      ),
      ContextAction(
        icon: AppIcons.addPlaylist,
        label: 'Add to Playlist',
        onTap: () async {
          final s = await songs();
          if (s.isNotEmpty && context.mounted) {
            showPlaylistPicker(context, s.first);
          }
        },
      ),
      ContextAction(
        icon: AppIcons.share,
        label: 'Share',
        onTap: () => showSnack(context, 'Artist share is not available.'),
      ),
    ],
  );
}

void showSongDetailsDialog(BuildContext context, SongModel s) {
  final rows = [
    ['Title', s.title],
    ['Artist', s.artist ?? '—'],
    ['Album', s.album ?? '—'],
    ['Composer', s.composer ?? '—'],
    ['Duration', fmtMs(s.duration)],
    ['Size', fmtBytes(s.size)],
    ['Format', s.fileExtension],
    ['Path', s.data],
  ];
  showDialog(
    context: context,
    builder: (c) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text('Details', style: AppTextStyles.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  SizedBox(
                    width: 84,
                    child: Text(r[0], style: AppTextStyles.caption),
                  ),
                  Expanded(
                    child: Text(
                      r[1],
                      style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => c.pop(),
          child: Text(
            'Close',
            style: AppTextStyles.button.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    ),
  );
}

int shuffleSeed = Random().nextInt(1 << 31);