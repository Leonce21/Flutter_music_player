// lib/core/widgets/context_sheet.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class ContextAction {
  const ContextAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;
}

class ItemContextSheet extends StatelessWidget {
  const ItemContextSheet({super.key, this.header, required this.actions});
  final Widget? header;
  final List<ContextAction> actions;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            if (header != null) header!,
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: actions.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                color: AppColors.divider,
                thickness: 0.5,
              ),
              itemBuilder: (c, i) {
                final a = actions[i];
                return InkWell(
                  onTap: () async {
                    // ✅ Close the modal FIRST, then execute the action
                    Navigator.pop(c);
                    // Wait for the modal to close before showing the snackbar
                    await Future.delayed(const Duration(milliseconds: 100));
                    a.onTap();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenH,
                      vertical: AppSpacing.md + 2,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          a.icon,
                          size: 20,
                          color: a.destructive
                              ? AppColors.error
                              : AppColors.textPrimary,
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Text(
                          a.label,
                          style: AppTextStyles.subtitle.copyWith(
                            color: a.destructive
                                ? AppColors.error
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
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

Future<T?> showContextSheet<T>(
  BuildContext context, {
  Widget? header,
  required List<ContextAction> actions,
}) {
  print('DEBUG: showContextSheet called with ${actions.length} actions');
  print('DEBUG: context.mounted = ${context.mounted}');
  return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        useSafeArea: false,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
        builder: (_) {
          print('DEBUG: showModalBottomSheet builder called');
          return ItemContextSheet(header: header, actions: actions);
        },
      )
      .then((result) {
        print('DEBUG: showModalBottomSheet closed with result: $result');
        return result;
      })
      .catchError((error) {
        print('ERROR in showModalBottomSheet: $error');
        return null;
      });
}
