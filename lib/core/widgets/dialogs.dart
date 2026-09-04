import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

Future<bool> showConfirm(BuildContext context, String title, String message,
        {String yes = 'Confirm'}) async =>
    (await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg)),
            title: Text(title, style: AppTextStyles.title),
            content: Text(message, style: AppTextStyles.body),
            actions: [
              TextButton(onPressed: () => c.pop(false),
                  child: Text('Cancel', style: AppTextStyles.body)),
              TextButton(onPressed: () => c.pop(true),
                  child: Text(yes, style: AppTextStyles.button.copyWith(
                      color: AppColors.error))),
            ],
          ),
        )) ??
    false;

Future<String?> showTextDialog(BuildContext context, String title,
        {String hint = ''}) async {
  final ctl = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (c) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg)),
      title: Text(title, style: AppTextStyles.title),
      content: TextField(
        controller: ctl, autofocus: true,
        style: AppTextStyles.subtitle,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.body,
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.divider)),
          focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary)),
        ),
      ),
      actions: [
        TextButton(onPressed: () => c.pop(),
            child: Text('Cancel', style: AppTextStyles.body)),
        TextButton(
            onPressed: () => c.pop(
                ctl.text.trim().isEmpty ? null : ctl.text.trim()),
            child: Text('Save', style: AppTextStyles.button.copyWith(
                color: AppColors.primary))),
      ],
    ),
  );
}

void showSnack(BuildContext context, String msg) =>
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surface, content: Text(msg,
              style: AppTextStyles.subtitle)));