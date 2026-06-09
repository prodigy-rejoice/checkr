import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../../models/scan_result.dart';
import '../../widgets/primary_button_widget.dart';
import '../../widgets/verdict_card_widget.dart';
import 'result_viewmodel.dart';

class ResultView extends StatelessWidget {
  final ScanResult result;

  const ResultView({required this.result, super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ResultViewModel>.reactive(
      viewModelBuilder: () => ResultViewModel(),
      onViewModelReady: (vm) => vm.initialise(result),
      builder: (context, vm, child) {
        final r = vm.result;
        final backgroundColor = r.isOutOfScope
            ? AppColors.warningLight
            : r.isGenuine
                ? AppColors.genuineLight
                : AppColors.counterfeitLight;

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildVerdictIcon(r),
                  const SizedBox(height: 16),
                  _buildVerdictText(r),
                  const SizedBox(height: 8),
                  _buildDenomination(),
                  const SizedBox(height: 24),
                  VerdictCardWidget(vm: vm),
                  const SizedBox(height: 12),
                  _buildDebugPanel(vm),
                  const SizedBox(height: 16),
                  _buildAdvisory(r),
                  const SizedBox(height: 32),
                  _buildActions(vm),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerdictIcon(ScanResult r) {
    final Color color;
    final IconData icon;

    if (r.isOutOfScope) {
      color = AppColors.warning;
      icon = Icons.info_outline;
    } else if (r.isGenuine) {
      color = AppColors.genuine;
      icon = Icons.check;
    } else {
      color = AppColors.counterfeit;
      icon = Icons.close;
    }

    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 52),
    );
  }

  Widget _buildVerdictText(ScanResult r) {
    final Color color;
    final String text;

    if (r.isOutOfScope) {
      color = AppColors.warning;
      text = 'UNVERIFIED';
    } else if (r.isGenuine) {
      color = AppColors.genuine;
      text = 'GENUINE';
    } else {
      color = AppColors.counterfeit;
      text = 'COUNTERFEIT';
    }

    return Text(
      text,
      style: AppTypography.verdictLarge.copyWith(color: color),
    );
  }

  Widget _buildDenomination() {
    return Text(
      'Nigerian Naira Note',
      style: AppTypography.heading2.copyWith(color: AppColors.textSecondary),
    );
  }

  Widget _buildDebugPanel(ResultViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [AppConstants.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _debugRow('MSE', vm.formattedMse),
          const SizedBox(height: 4),
          _debugRow('Serial', vm.displaySerial),
          const SizedBox(height: 4),
          _debugRow('Reason', vm.verdictReason),
        ],
      ),
    );
  }

  Widget _debugRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 56,
          child: Text(
            '$label:',
            style: AppTypography.label.copyWith(color: AppColors.textMuted),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value, style: AppTypography.mono),
        ),
      ],
    );
  }

  Widget _buildAdvisory(ScanResult r) {
    final Color bgColor;
    final Color borderColor;
    final Color textColor;
    final String text;

    if (r.isOutOfScope) {
      bgColor = AppColors.warningLight;
      borderColor = AppColors.warning;
      textColor = AppColors.warning;
      text = r.verdictReason;
    } else if (r.isGenuine) {
      bgColor = AppColors.genuineLight;
      borderColor = AppColors.genuine;
      textColor = AppColors.genuine;
      text = 'This note shows no signs of tampering. Both visual and serial checks passed.';
    } else {
      bgColor = AppColors.counterfeitLight;
      borderColor = AppColors.counterfeit;
      textColor = AppColors.counterfeit;
      text = 'This note has been flagged. Do not accept it. Report suspicious notes to the CBN.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Text(
        text,
        style: AppTypography.body2.copyWith(color: textColor),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActions(ResultViewModel vm) {
    return Column(
      children: [
        PrimaryButtonWidget(
          label: 'Scan Again',
          onPressed: vm.scanAnother,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: vm.goHome,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Go Home',
              style: AppTypography.button.copyWith(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
