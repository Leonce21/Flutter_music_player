import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mume/features/identify/application/audio_recorder_service.dart';
import 'package:mume/features/identify/application/identify_notifier.dart';
import 'package:mume/features/identify/application/song_recognition_service.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/bottom_nav.dart';
import '../../../../core/widgets/mini_player.dart';
import '../../../favorites/favorites_screen.dart';
import '../../../playlists/playlists_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import 'home_screen.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: child, bottomNavigationBar: const _Dock());
}

class _Dock extends StatelessWidget {
  const _Dock();

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final index = loc.startsWith('/favorites')
        ? 1
        : loc.startsWith('/playlists')
            ? 2
            : loc.startsWith('/settings')
                ? 3
                : 0;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayerBar(),
          MumeBottomNav(
            index: index,
            onIdentify: () => _showIdentifySheet(context),
          ),
        ],
      ),
    );
  }

  void _showIdentifySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (c) => const _IdentifySheet(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// IDENTIFY SHEET
// ─────────────────────────────────────────────────────────────
class _IdentifySheet extends ConsumerStatefulWidget {
  const _IdentifySheet();
  @override
  ConsumerState<_IdentifySheet> createState() => _IdentifySheetState();
}

class _IdentifySheetState extends ConsumerState<_IdentifySheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  Timer? _copyResetTimer;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _sheetController.dispose();
    _copyResetTimer?.cancel();
    super.dispose();
  }

  // ── Sheet sizing ───────────────────────────────────────────
  double _extentFor(IdentifyState s) {
    switch (s.status) {
      case IdentifyStatus.success:
        return 0.42;
      case IdentifyStatus.notFound:
        return 0.40;
      case IdentifyStatus.error:
        final msg = (s.errorMessage ?? '').toLowerCase();
        return msg.contains('permission') ? 0.42 : 0.50;
      default:
        return 0.65;
    }
  }

  void _syncSheetExtent(IdentifyState s) {
    if (!_sheetController.isAttached) return;
    _sheetController.animateTo(
      _extentFor(s),
      duration: AppTheme.dur(320),
      curve: Curves.easeOutCubic,
    );
  }

  // ── Listening control ──────────────────────────────────────
  void _toggleListening() {
    final state = ref.read(identifyProvider);
    if (state.status == IdentifyStatus.listening) {
      ref.read(identifyProvider.notifier).stopListening();
    } else {
      ref.read(identifyProvider.notifier).startListening();
    }
  }

  // ── Result actions ─────────────────────────────────────────
  String _resultText(SongRecognitionResult r) {
    final b = StringBuffer('${r.title} — ${r.artist}');
    if (r.album != null && r.album!.isNotEmpty) b.write(' · ${r.album}');
    return b.toString();
  }

  Future<void> _copyResult(SongRecognitionResult r) async {
    await Clipboard.setData(ClipboardData(text: _resultText(r)));
    if (!mounted) return;
    HapticFeedback.lightImpact();
    setState(() => _copied = true);
    _copyResetTimer?.cancel();
    _copyResetTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  void _shareResult(SongRecognitionResult r) {
    Share.share('🎵 ${_resultText(r)}\nIdentified with Sonora');
  }

  void _closeSheet() {
    final st = ref.read(identifyProvider).status;
    if (st == IdentifyStatus.listening) {
      ref.read(identifyProvider.notifier).stopListening();
    }
    Navigator.pop(context);
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString();
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(identifyProvider);

    ref.listen<IdentifyState>(identifyProvider, (prev, next) {
      if (prev?.status == next.status) return;
      _syncSheetExtent(next);
      if (next.status != IdentifyStatus.success && _copied) {
        _copyResetTimer?.cancel();
        setState(() => _copied = false);
      }
      switch (next.status) {
        case IdentifyStatus.success:
          HapticFeedback.mediumImpact();
        case IdentifyStatus.error:
          HapticFeedback.mediumImpact();
        case IdentifyStatus.notFound:
          HapticFeedback.lightImpact();
        default:
          break;
      }
    });

    final isTerminal = state.status == IdentifyStatus.success ||
        state.status == IdentifyStatus.error ||
        state.status == IdentifyStatus.notFound;

    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.65,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.lg,
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildBody(state),
              const SizedBox(height: 80),
              if (isTerminal)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        ref.read(identifyProvider.notifier).reset(),
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: const Text('Search again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: _closeSheet,
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.button
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ),
              const SizedBox(height: 30),
              if (isTerminal) const Spacer(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(IdentifyState state) {
    switch (state.status) {
      case IdentifyStatus.idle:
      case IdentifyStatus.listening:
        return _buildListeningUI(state.status == IdentifyStatus.listening, state.elapsedSeconds);
      case IdentifyStatus.processing:
        return _buildProcessingUI();
      case IdentifyStatus.success:
        return _buildSuccessUI(state.result!);
      case IdentifyStatus.notFound:
        return _buildNotFoundUI();
      case IdentifyStatus.error:
        return _buildErrorUI(state.errorMessage ?? 'An unknown error occurred.');
    }
  }

  // ── LISTENING (Continuous with count-up timer) ─────────────
  Widget _buildListeningUI(bool isListening, int elapsedSeconds) {
    return Expanded(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _toggleListening,
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return Container(
                      width: 120 + (40 * _animController.value),
                      height: 120 + (40 * _animController.value),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(
                            alpha: 0.1 + (0.2 * _animController.value)),
                      ),
                      child: Icon(
                        isListening ? Icons.mic : Icons.mic_none,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
              ),
              if (isListening) ...[
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDeep,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: AppColors.divider),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              Text(
                isListening ? 'Listening...' : 'Tap to Search for a Song',
                style: AppTextStyles.title,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                isListening
                    ? 'Tap the mic to stop manually'
                    : 'Play music nearby and tap the mic',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ... Keep _buildProcessingUI, _buildSuccessUI, _buildNotFoundUI, _buildErrorUI, 
  // and all the reusable components (_StatusBadge, _ResultCard, etc.) exactly as they were ...

  // ── PROCESSING (layout unchanged) ──────────────────────────
  Widget _buildProcessingUI() {
    return Expanded(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 72,
                height: 72,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Identifying...', style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.md),
              Text('Matching the audio fingerprint', style: AppTextStyles.body),
            ],
          ),
        ),
      ),
    );
  }

  // ── SUCCESS (shrink-wrapped: sits right under the handle) ──
  Widget _buildSuccessUI(SongRecognitionResult result) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _StatusBadge(
            icon: Icons.check_rounded,
            color: AppColors.success,
            label: 'Song identified',
          ),
          const SizedBox(height: AppSpacing.xl),
          _ResultCard(result: result),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _ActionPill(
                  icon: _copied ? Icons.check_rounded : Icons.copy_rounded,
                  label: _copied ? 'Copied!' : 'Copy result',
                  filled: true,
                  fillColor: _copied ? AppColors.success : null,
                  onTap: _copied ? null : () => _copyResult(result),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _ActionPill(
                  icon: AppIcons.share,
                  label: 'Share',
                  onTap: () => _shareResult(result),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── NOT FOUND (shrink-wrapped) ─────────────────────────────
  Widget _buildNotFoundUI() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _StatusBadge(
            icon: Icons.search_off_rounded,
            color: AppColors.primary,
            label: 'No match found',
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'We couldn\'t identify that song',
            style: AppTextStyles.title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'The audio sample didn\'t match anything\nin the recognition database.',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          const _TipsCard(
            title: 'Tips for a better match',
            tips: [
              'Move closer to the speaker or music source',
              'Make sure the music plays loud and clear',
              'Avoid background noise, voices or TV audio',
            ],
          ),
        ],
      ),
    );
  }

  // ── ERROR (shrink-wrapped) ─────────────────────────────────
  Widget _buildErrorUI(String message) {
    final isPermission = message.toLowerCase().contains('permission');
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.error.withValues(alpha: 0.14),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            isPermission ? 'Microphone access denied' : 'Identification failed',
            style: AppTextStyles.title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isPermission
                ? 'Sonora needs microphone access to listen for songs. '
                    'Enable it in your device settings, then try again.'
                : 'Something went wrong while identifying the song. '
                    'Check the details below and try again.',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceDeep,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 6),
                Flexible(child: Text(message, style: AppTextStyles.caption)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (isPermission)
            SizedBox(
              width: double.infinity,
              child: _ActionPill(
                icon: AppIcons.settings,
                label: 'Open Settings',
                filled: true,
                onTap: () => AudioRecorderService().openSettings(),
              ),
            )
          else
            const _TipsCard(
              title: 'What you can try',
              tips: [
                'Check your internet connection',
                'Try again in a quieter environment',
                'Keep the mic pointed at the music source',
              ],
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// REUSABLE RESULT COMPONENTS (unchanged)
// ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.icon,
    required this.color,
    required this.label,
  });
  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.18),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: AppTextStyles.subtitle.copyWith(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _Overline extends StatelessWidget {
  const _Overline(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          fontSize: 10,
          letterSpacing: 1.4,
          fontWeight: FontWeight.w600,
          color: AppColors.textTertiary,
        ),
      );
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});
  final SongRecognitionResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceDeep,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ResultArtwork(url: result.artworkUrl),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const _Overline('Track'),
                const SizedBox(height: 2),
                Text(
                  result.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title.copyWith(
                    fontSize: 19,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const _Overline('Artist'),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.person_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        result.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.subtitle.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (result.album != null && result.album!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(
                        AppIcons.album,
                        size: 13,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          result.album!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultArtwork extends StatelessWidget {
  const _ResultArtwork({this.url, this.size = 88});
  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: url != null && url!.isNotEmpty
            ? Image.network(
                url!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _ArtFallback(),
                loadingBuilder: (c, child, progress) =>
                    progress == null ? child : const _ArtFallback(),
              )
            : const _ArtFallback(),
      ),
    );
  }
}

class _ArtFallback extends StatelessWidget {
  const _ArtFallback();

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: Icon(
            AppIcons.musicNote,
            size: 32,
            color: AppColors.textPrimary.withValues(alpha: 0.9),
          ),
        ),
      );
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.icon,
    required this.label,
    this.onTap,
    this.filled = false,
    this.fillColor,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool filled;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    final solid = fillColor != null;
    final emphasized = filled || solid;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.dur(200),
        height: 46,
        decoration: BoxDecoration(
          gradient: (filled && !solid) ? AppColors.primaryGradient : null,
          color: solid ? fillColor : (filled ? null : AppColors.surfaceDeep),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border:
              (!filled && !solid) ? Border.all(color: AppColors.divider) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: emphasized ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.button.copyWith(
                fontSize: 14,
                color: emphasized
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard({required this.title, required this.tips});
  final String title;
  final List<String> tips;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceDeep,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTextStyles.subtitle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < tips.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(tips[i], style: AppTextStyles.body)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context) => switch (index) {
        1 => const FavoritesScreen(),
        2 => const PlaylistsScreen(),
        3 => const SettingsScreen(),
        _ => const HomeScreen(),
      };
}