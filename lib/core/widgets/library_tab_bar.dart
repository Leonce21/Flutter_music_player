import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

// const libraryTabs = ['Suggested', 'Songs', 'Artists', 'Albums', 'Folders'];
const libraryTabs = ['Songs', 'Artists', 'Albums', 'Folders'];
class LibraryTabBar extends StatelessWidget {
  const LibraryTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      isScrollable: true,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      labelStyle: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w600),
      unselectedLabelStyle: AppTextStyles.subtitle,
      indicatorColor: AppColors.primary,
      indicatorWeight: 2.5,
      tabAlignment: TabAlignment.start,
      splashFactory: NoSplash.splashFactory,
      tabs: [
        for (final t in libraryTabs)
          Tab(child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenH - 6),
              child: Text(t))),
      ],
    );
  }
}