import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/prefs.dart';
import '../services/store_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/sort.dart';

class SortMenu extends ConsumerWidget {
  const SortMenu({super.key, required this.tab, this.onChanged});
  final String tab;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(sortPrefProvider(tab));
    return PopupMenuButton<String>(
      color: AppColors.surface,
      elevation: 0,
      offset: const Offset(0, 6),
      constraints: const BoxConstraints(minWidth: 176),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md)),
      onSelected: (v) {
        Prefs.setSort(tab, v);
        ref.read(sortPrefProvider(tab).notifier).state = v;
        onChanged?.call(v);
      },
      itemBuilder: (_) => [
        for (final k in sortKeys)
          PopupMenuItem(
            value: k,
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(children: [
              Text(k, style: AppTextStyles.subtitle.copyWith(fontSize: 14)),
              const Spacer(),
              _RadioDot(active: k == current),
            ]),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(current, style: AppTextStyles.caption.copyWith(
              color: AppColors.primary, fontWeight: FontWeight.w600)),
          const SizedBox(width: AppSpacing.xs),
          const Icon(AppIcons.sort, size: 14, color: AppColors.primary),
        ]),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.active});
  final bool active;
  @override
  Widget build(BuildContext context) => Container(
        width: 16, height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? AppColors.primary : Colors.transparent,
          border: Border.all(color: AppColors.primary, width: 1.6),
        ),
        child: active
            ? const Center(child: Icon(Icons.circle, size: 6,
                color: AppColors.surface))
            : null,
      );
}