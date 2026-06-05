import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/enums/quality_status.dart';

class QualityIndicatorWidget extends StatelessWidget {
  final String label;
  final QualityStatus status;

  const QualityIndicatorWidget({
    required this.label,
    required this.status,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _backgroundColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _foregroundColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _foregroundColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.label.copyWith(color: _foregroundColor),
          ),
        ],
      ),
    );
  }

  Color get _foregroundColor {
    switch (status) {
      case QualityStatus.passing:
        return AppColors.genuine;
      case QualityStatus.marginal:
        return AppColors.warning;
      case QualityStatus.failing:
        return AppColors.counterfeit;
    }
  }

  Color get _backgroundColor {
    switch (status) {
      case QualityStatus.passing:
        return AppColors.genuineLight;
      case QualityStatus.marginal:
        return AppColors.warningLight;
      case QualityStatus.failing:
        return AppColors.counterfeitLight;
    }
  }
}
