import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../core/constants/app_colors.dart';
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
        final isGenuine = vm.result.isGenuine;
        return Scaffold(
          backgroundColor:
              isGenuine ? AppColors.genuineLight : AppColors.counterfeitLight,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildVerdictIcon(isGenuine),
                  const SizedBox(height: 16),
                  _buildVerdictText(isGenuine),
                  const SizedBox(height: 8),
                  _buildDenomination(),
                  const SizedBox(height: 24),
                  VerdictCardWidget(vm: vm),
                  const SizedBox(height: 16),
                  _buildAdvisory(isGenuine),
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

  Widget _buildVerdictIcon(bool isGenuine) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: isGenuine ? AppColors.genuine : AppColors.counterfeit,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isGenuine ? Icons.check : Icons.close,
        color: Colors.white,
        size: 52,
      ),
    );
  }

  Widget _buildVerdictText(bool isGenuine) {
    return Text(
      isGenuine ? 'GENUINE' : 'COUNTERFEIT',
      style: AppTypography.verdictLarge.copyWith(
        color: isGenuine ? AppColors.genuine : AppColors.counterfeit,
      ),
    );
  }

  Widget _buildDenomination() {
    return Text(
      'Nigerian Naira Note',
      style: AppTypography.heading2.copyWith(color: AppColors.textSecondary),
    );
  }

  Widget _buildAdvisory(bool isGenuine) {
    final text = isGenuine
        ? 'This note shows no signs of tampering. Both visual and serial checks passed.'
        : 'This note has been flagged. Do not accept it. Report suspicious notes to the CBN.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isGenuine ? AppColors.genuineLight : AppColors.counterfeitLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isGenuine ? AppColors.genuine : AppColors.counterfeit,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: AppTypography.body2.copyWith(
          color: isGenuine ? AppColors.genuine : AppColors.counterfeit,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActions(ResultViewModel vm) {
    return Column(
      children: [
        PrimaryButtonWidget(
          label: 'Scan Another',
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
