import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'mume_logo.dart';

enum AppBarKind { logo, back }

class MumeScaffold extends StatelessWidget {
  const MumeScaffold({super.key, this.kind = AppBarKind.logo, this.title,
      required this.body, this.onMore, this.bottom, this.showSearch = true});
  final AppBarKind kind;
  final String? title;
  final Widget body;
  final VoidCallback? onMore;
  final Widget? bottom; // Changed from PreferredSizeWidget? to Widget?
  final bool showSearch;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenH, vertical: AppSpacing.md),
            child: Row(children: [
              if (kind == AppBarKind.back)
                IconBtn(icon: AppIcons.back,
                    onTap: () => context.canPop()
                        ? context.pop() : context.go('/home'))
              else if (title != null)
                Text(title!, style: AppTextStyles.h1.copyWith(fontSize: 22))
              else
                const MumeLogo(size: 30),
              const Spacer(),
              if (showSearch)
                IconBtn(icon: AppIcons.search,
                    onTap: () => context.push('/search')),
              if (onMore != null) ...[
                const SizedBox(width: AppSpacing.md),
                IconBtn(icon: AppIcons.moreCircle, onTap: onMore),
              ],
            ]),
          ),
          if (bottom != null) bottom!,
          Expanded(child: body),
        ]),
      ),
    );
  }
}

class IconBtn extends StatelessWidget {
  const IconBtn({super.key, required this.icon, this.onTap,
      this.size = 22, this.color});
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(icon, size: size,
              color: color ?? AppColors.textPrimary),
        ),
      );
}