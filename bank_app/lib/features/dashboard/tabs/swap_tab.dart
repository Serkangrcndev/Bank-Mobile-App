import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SwapTab extends StatelessWidget {
  const SwapTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerHigh,
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: const Icon(
              Icons.swap_vert_rounded,
              color: AppColors.primaryFixed,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Trade & Swap',
            style: AppTextStyles.headlineMd(color: AppColors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Trade and swap assets instantly.',
            style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
