import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../../../core/services/store_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/mume_scaffold.dart' show IconBtn;
import '../../../../core/widgets/song_list_tile.dart';
import '../../../library/application/library_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctl = TextEditingController();
  Timer? _deb;
  String _q = '';

  @override
  void dispose() { _deb?.cancel(); _ctl.dispose(); super.dispose(); }

  void _onChanged(String v) {
    _deb?.cancel();
    _deb = Timer(AppTheme.dur(300).inMilliseconds == 0
        ? Duration.zero : const Duration(milliseconds: 300), () {
      if (v.trim().isNotEmpty) {
        ref.read(historyProvider.notifier).log(v.trim());
      }
      setState(() => _q = v.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final lib = ref.watch(libraryProvider).valueOrNull;
    final history = ref.watch(historyProvider);
    final q = _q.toLowerCase();
    final songs = q.isEmpty ? <SongModel>[] :
        (lib?.songs ?? []).where((s) =>
            s.title.toLowerCase().contains(q) ||
            (s.artist ?? '').toLowerCase().contains(q)).toList();
    final artists = q.isEmpty ? <ArtistModel>[] :
        (lib?.artists ?? []).where((a) =>
            (a.artist ?? '').toLowerCase().contains(q)).toList();

    return Scaffold(
      body: SafeArea(bottom: false, child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenH,
              AppSpacing.md, AppSpacing.screenH, AppSpacing.md),
          child: Row(children: [
            IconBtn(icon: AppIcons.back, onTap: () => context.pop()),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primaryAlpha(20),
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: TextField(
                  controller: _ctl,
                  autofocus: true,
                  onChanged: _onChanged,
                  style: AppTextStyles.subtitle,
                  decoration: InputDecoration(
                    isDense: true, border: InputBorder.none,
                    prefixIcon: const Icon(AppIcons.search,
                        size: 18, color: AppColors.primary),
                    hintText: 'Search songs, artists…',
                    hintStyle: AppTextStyles.body,
                  ),
                ),
              ),
            ),
          ]),
        ),
        Expanded(
          child: q.isEmpty
              ? _History(history: history,
                  onPick: (v) => setState(() { _q = v; _ctl.text = v; }))
              : ListView(children: [
                  for (final s in songs)
                    SongListTile(song: s, queue: songs),
                  if (songs.isEmpty && artists.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Text('No results for "$_q"',
                          style: AppTextStyles.body),
                    ),
                  if (artists.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.screenH),
                      child: Text('Artists', style: AppTextStyles.title),
                    ),
                  for (final a in artists)
                    ListTile(
                      title: Text(a.artist,
                          style: AppTextStyles.subtitle),
                      onTap: () => context.push('/artist/${a.id}'),
                    ),
                ]),
        ),
      ])),
    );
  }
}

class _History extends ConsumerWidget {
  const _History({required this.history, required this.onPick});
  final List<String> history;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
        child: Row(children: [
          Text('Recent Searches', style: AppTextStyles.title),
          const Spacer(),
          InkWell(onTap: () => ref.read(historyProvider.notifier).clear(),
              child: Text('Clear All', style: AppTextStyles.caption
                  .copyWith(color: AppColors.primary,
                      fontWeight: FontWeight.w600))),
        ]),
      ),
      const SizedBox(height: AppSpacing.md),
      for (final h in history)
        InkWell(
          onTap: () => onPick(h),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenH, vertical: AppSpacing.md),
            child: Row(children: [
              Expanded(child: Text(h, style: AppTextStyles.subtitle
                  .copyWith(color: AppColors.textSecondary))),
              IconBtn(icon: AppIcons.x, size: 16,
                  color: AppColors.textSecondary,
                  onTap: () => ref.read(historyProvider.notifier).remove(h)),
            ]),
          ),
        ),
    ]);
  }
}