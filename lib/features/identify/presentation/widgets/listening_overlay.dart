import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class ListeningOverlay extends StatelessWidget {
  const ListeningOverlay({
    super.key,
    required this.status,
    required this.isProcessing,
    required this.hasError,
    required this.onCancel,
    required this.onRetry,
  });

  final String status;
  final bool isProcessing;
  final bool hasError;
  final VoidCallback onCancel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Remove solid background, use transparent with lower opacity overlay
      color: Colors.transparent,
      child: Stack(
        children: [
          // Shaded overlay with lower opacity
          Container(
            color: AppColors.background.withOpacity(0.6),
          ),
          // Content centered
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated listening circle
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.8),
                        AppColors.primary.withOpacity(0.4),
                        AppColors.primary.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.mic,
                    size: 48,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  isProcessing ? 'Listening...' : status,
                  style: AppTextStyles.title,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (hasError)
                  ElevatedButton(
                    onPressed: onRetry,
                    child: const Text('Retry'),
                  )
                else
                  TextButton(
                    onPressed: onCancel,
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.subtitle.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}