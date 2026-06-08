import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_typography.dart';
import '../views/result/result_viewmodel.dart';

class VerdictCardWidget extends StatelessWidget {
  final ResultViewModel vm;

  const VerdictCardWidget({required this.vm, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppConstants.cardShadow],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildRow(
            'Visual Check',
            _buildStatusBadge(
              vm.result.passedVisualCheck ? 'Pass' : 'Fail',
              vm.result.passedVisualCheck,
            ),
          ),
          _buildDivider(),
          _buildRow(
            'MSE Score',
            Text(vm.formattedMse, style: AppTypography.mono),
          ),
          _buildDivider(),
          _buildRow(
            'Serial Number',
            Text(
              vm.displaySerial,
              style: vm.result.extractedSerial != null
                  ? AppTypography.mono
                  : AppTypography.body2.copyWith(color: AppColors.textMuted),
            ),
          ),
          _buildDivider(),
          _buildRow(
            'Blacklist Check',
            _buildStatusBadge(
              vm.result.serialBlacklisted ? 'Flagged' : 'Clear',
              !vm.result.serialBlacklisted,
            ),
          ),
          _buildDivider(),
          _buildRow(
            'Reason',
            Flexible(
              child: Text(
                vm.verdictReason,
                style: AppTypography.body2.copyWith(
                  color: vm.result.isOutOfScope
                      ? AppColors.warning
                      : vm.result.isGenuine
                          ? AppColors.genuine
                          : AppColors.counterfeit,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body2),
          value,
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(color: AppColors.divider, height: 1);
  }

  Widget _buildStatusBadge(String text, bool isPositive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isPositive
            ? AppColors.genuine.withValues(alpha: 0.1)
            : AppColors.counterfeit.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: AppTypography.label.copyWith(
          color: isPositive ? AppColors.genuine : AppColors.counterfeit,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
