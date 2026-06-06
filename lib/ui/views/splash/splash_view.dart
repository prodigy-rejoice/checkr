import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import 'splash_viewmodel.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SplashViewModel>.reactive(
      viewModelBuilder: () => SplashViewModel(),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: AppColors.primary,
          body: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  _buildLogo(),
                  const SizedBox(height: 16),
                  _buildTagline(),
                  const Spacer(),
                  _buildLoader(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: AppColors.gold,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '₦',
              textAlign: TextAlign.center,
              style: AppTypography.display2.copyWith(
                color: AppColors.primaryDark,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Checkr',
          textAlign: TextAlign.center,
          style: AppTypography.display1.copyWith(
            color: AppColors.gold,
            fontSize: 40,
          ),
        ),
      ],
    );
  }

  Widget _buildTagline() {
    return Text(
      'Verify. Protect. Trust.',
      textAlign: TextAlign.center,
      style: AppTypography.body1.copyWith(color: AppColors.textInverse),
    );
  }

  Widget _buildLoader() {
    return const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
      strokeWidth: 2,
    );
  }
}
