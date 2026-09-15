import 'dart:async'; // ✅ ADD THIS for StreamSubscription
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:volume_controller/volume_controller.dart'; // ✅ v3.x import
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/cover_art.dart';
import '../../../../core/widgets/mume_scaffold.dart' show IconBtn;
import '../../../../core/widgets/states.dart';
import '../../application/player_controller.dart';

class NowPlayingScreen extends ConsumerStatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen> {
  bool _lyrics = false;
  final _lyricCtl = ScrollController();
  double _volume = 1.0;
  
  // ✅ v3.x API: Store the subscription returned by addListener
  StreamSubscription<double>? _volumeSubscription;

  @override
  void initState() {
    super.initState();
    _initVolumeController();
  }

  void _initVolumeController() {
    // ✅ v3.x API: Use .instance singleton
    VolumeController.instance.showSystemUI = false;
    
    // ✅ v3.x API: addListener returns a StreamSubscription and supports fetchInitialVolume
    _volumeSubscription = VolumeController.instance.addListener((volume) {
      if (mounted) {
        setState(() => _volume = volume);
      }
    }, fetchInitialVolume: true);
  }

  @override
  void dispose() {
    // ✅ v3.x API: Cancel the subscription to prevent memory leaks
    _volumeSubscription?.cancel();
    _lyricCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pc = ref.watch(playerProvider);
    return StreamBuilder<int?>(
      stream: pc.player.currentIndexStream,
      builder: (context, _) {
        final song = pc.currentSong;
        if (song == null) {
          return const MumeScaffoldPlain(
            child: EmptyState(message: 'Nothing playing.'),
          );
        }
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenH,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      IconBtn(
                        icon: AppIcons.back,
                        onTap: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      IconBtn(
                        icon: Icons.volume_up,
                        size: 22,
                        color: AppColors.textPrimary,
                        onTap: () => _showVolumeSheet(context, pc),
                      ),
                    ],
                  ),
                ),
                if (!_lyrics) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Hero(
                    tag: 'art-current',
                    child: ArtworkLoader(
                      id: song.albumId ?? song.id,
                      type: ArtworkType.ALBUM,
                      seed: song.title,
                      size: MediaQuery.of(context).size.width * 0.66,
                      radius: AppRadius.art,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    song.title,
                    style: AppTextStyles.title.copyWith(fontSize: 21),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${song.artist ?? ''}${song.artist != null && (song.album ?? '').isNotEmpty ? ', ${song.album}' : ''}',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ] else ...[
                  const SizedBox(height: AppSpacing.md),
                ],
                const _Progress(),
                const SizedBox(height: AppSpacing.sm),
                const _Controls(),
                const SizedBox(height: AppSpacing.md),
                _SecondaryRow(
                  onLyrics: () => setState(() => _lyrics = !_lyrics),
                  lyricsOpen: _lyrics,
                ),
                if (_lyrics) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenH,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Lyrics', style: AppTextStyles.title),
                          ),
                        ),
                        IconBtn(
                          icon: Icons.keyboard_arrow_down,
                          size: 24,
                          color: AppColors.textSecondary,
                          onTap: () => setState(() => _lyrics = false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: _LyricsPanel(pc: pc, ctl: _lyricCtl),
                  ),
                ] else
                  const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: InkWell(
                    onTap: () => setState(() => _lyrics = !_lyrics),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _lyrics
                              ? Icons.keyboard_arrow_down
                              : AppIcons.chevronUp,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _lyrics ? 'Close' : 'Lyrics',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showVolumeSheet(BuildContext context, PlayerController pc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
      builder: (c) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    const Icon(
                      Icons.volume_down,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Slider(
                        value: _volume,
                        min: 0.0,
                        max: 1.0,
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.divider,
                        onChanged: (v) {
                          setModalState(() => _volume = v);
                          setState(() => _volume = v);
                          // ✅ v3.x API: Use .instance to set volume
                          VolumeController.instance.setVolume(v);
                          // Keep player internal volume at max to prevent double-attenuation
                          pc.player.setVolume(1.0);
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Icon(
                      Icons.volume_up,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${(_volume * 100).round()}%',
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ... (Keep MumeScaffoldPlain, _Progress, _Controls, _SecondaryRow, and _LyricsPanel exactly as they were)
class MumeScaffoldPlain extends StatelessWidget {
  const MumeScaffoldPlain({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(body: child);
}

class _Progress extends ConsumerWidget {
  const _Progress();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pc = ref.watch(playerProvider);
    return StreamBuilder<Duration>(
      stream: pc.player.positionStream,
      builder: (c, pos) => StreamBuilder<Duration?>(
        stream: pc.player.durationStream,
        builder: (c, dur) {
          final p = pos.data ?? Duration.zero;
          final d = dur.data ?? Duration.zero;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
            child: Column(
              children: [
                Slider(
                  value: p.inMilliseconds.toDouble().clamp(
                    0,
                    d.inMilliseconds.toDouble().clamp(1, double.infinity),
                  ),
                  max: d.inMilliseconds.toDouble().clamp(1, double.infinity),
                  onChanged: (v) => pc.seek(Duration(milliseconds: v.toInt())),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Text(fmtDur(p), style: AppTextStyles.caption),
                      const Spacer(),
                      Text(fmtDur(d), style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Controls extends ConsumerWidget {
  const _Controls();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pc = ref.watch(playerProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconBtn(icon: AppIcons.skipPrev, size: 26, onTap: pc.previous),
        const SizedBox(width: AppSpacing.xl),
        IconBtn(
          icon: AppIcons.rewind10,
          size: 24,
          onTap: () => pc.seekBy(const Duration(seconds: -10)),
        ),
        const SizedBox(width: AppSpacing.xl),
        StreamBuilder<bool>(
          stream: pc.player.playingStream,
          builder: (c, s) => InkWell(
            onTap: pc.toggle,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryAlpha(90),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                (s.data ?? false) ? AppIcons.pause : AppIcons.play,
                size: 34,
                color: AppColors.background,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xl),
        IconBtn(
          icon: AppIcons.forward10,
          size: 24,
          onTap: () => pc.seekBy(const Duration(seconds: 10)),
        ),
        const SizedBox(width: AppSpacing.xl),
        IconBtn(icon: AppIcons.skipNext, size: 26, onTap: pc.next),
      ],
    );
  }
}

class _SecondaryRow extends ConsumerWidget {
  const _SecondaryRow({required this.onLyrics, required this.lyricsOpen});
  final VoidCallback onLyrics;
  final bool lyricsOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pc = ref.watch(playerProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        StreamBuilder<bool>(
          stream: pc.player.shuffleModeEnabledStream,
          builder: (c, s) => IconBtn(
            icon: AppIcons.shuffle,
            size: 20,
            color: (s.data ?? false)
                ? AppColors.primary
                : AppColors.textSecondary,
            onTap: pc.toggleShuffle,
          ),
        ),
        StreamBuilder<LoopMode>(
          stream: pc.player.loopModeStream,
          builder: (c, s) => IconBtn(
            icon: (s.data == LoopMode.one)
                ? AppIcons.repeatOne
                : AppIcons.repeat,
            size: 20,
            color: (s.data == LoopMode.off)
                ? AppColors.textSecondary
                : AppColors.primary,
            onTap: pc.cycleLoop,
          ),
        ),
        IconBtn(
          icon: AppIcons.speed,
          size: 20,
          color: AppColors.textSecondary,
          onTap: () => _speedSheet(context, pc),
        ),
        IconBtn(
          icon: AppIcons.timer,
          size: 20,
          color: AppColors.textSecondary,
          onTap: () => _sleepSheet(context, pc),
        ),
        IconBtn(
          icon: AppIcons.cast,
          size: 20,
          color: AppColors.textSecondary,
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.surface,
              content: Text(
                'Cast is unavailable offline.',
                style: AppTextStyles.subtitle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _speedSheet(BuildContext context, PlayerController pc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final v in [0.75, 1.0, 1.25, 1.5])
              ListTile(
                title: Text('${v}x', style: AppTextStyles.subtitle),
                trailing: StreamBuilder<double>(
                  stream: pc.player.speedStream,
                  builder: (cc, s) => Icon(
                    Icons.circle,
                    size: 10,
                    color: (s.data ?? 1.0) == v
                        ? AppColors.primary
                        : Colors.transparent,
                  ),
                ),
                onTap: () {
                  pc.player.setSpeed(v);
                  Navigator.pop(c);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _sleepSheet(BuildContext context, PlayerController pc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Off', style: AppTextStyles.subtitle),
              onTap: () {
                pc.setSleepTimer(null);
                Navigator.pop(c);
              },
            ),
            for (final m in [5, 15, 30, 60])
              ListTile(
                title: Text('$m minutes', style: AppTextStyles.subtitle),
                onTap: () {
                  pc.setSleepTimer(Duration(minutes: m));
                  Navigator.pop(c);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.surface,
                      content: Text(
                        'Sleep timer: $m min',
                        style: AppTextStyles.subtitle,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _LyricsPanel extends ConsumerStatefulWidget {
  const _LyricsPanel({required this.pc, required this.ctl});
  final PlayerController pc;
  final ScrollController ctl;
  @override
  ConsumerState<_LyricsPanel> createState() => _LyricsPanelState();
}

class _LyricsPanelState extends ConsumerState<_LyricsPanel> {
  int _active = -1;

  @override
  Widget build(BuildContext context) {
    final lines = widget.pc.lyrics;
    if (lines.isEmpty) {
      return const EmptyState(
        message:
            'No lyrics found for this track.\n'
            'Drop a matching .lrc file next to the audio file to enable synced lyrics.',
      );
    }
    return StreamBuilder<Duration>(
      stream: widget.pc.player.positionStream,
      builder: (c, snap) {
        final pos = snap.data ?? Duration.zero;
        var active = -1;
        for (var i = 0; i < lines.length; i++) {
          if (lines[i].time <= pos) {
            active = i;
          } else {
            break;
          }
        }
        if (active != _active) {
          _active = active;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (widget.ctl.hasClients) {
              widget.ctl.animateTo(
                (active * 44.0).clamp(0, double.infinity),
                duration: AppTheme.dur(300),
                curve: Curves.easeOutCubic,
              );
            }
          });
        }
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ListView.builder(
            controller: widget.ctl,
            itemCount: lines.length,
            itemBuilder: (c, i) => AnimatedDefaultTextStyle(
              duration: AppTheme.dur(200),
              style: i <= _active
                  ? AppTextStyles.subtitle.copyWith(color: AppColors.primary)
                  : AppTextStyles.subtitle.copyWith(
                      color: AppColors.textPrimary,
                    ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Text(lines[i].text),
              ),
            ),
          ),
        );
      },
    );
  }
}