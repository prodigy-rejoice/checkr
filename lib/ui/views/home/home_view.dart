import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_typography.dart';
import '../../widgets/primary_button_widget.dart';
import 'home_viewmodel.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(),
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              _buildTopSection(context, vm),
              Expanded(child: _buildBottomSection(vm)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopSection(BuildContext context, HomeViewModel vm) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.40,
      color: AppColors.primary,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildAppBar(),
              const Spacer(),
              _buildHeadline(),
              const SizedBox(height: 8),
              _buildSubtitle(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Checkr',
          style: AppTypography.heading1.copyWith(color: AppColors.textInverse),
        ),
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.gold,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '₦',
              style: AppTypography.body1.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeadline() {
    return Text(
      'Detect\nCounterfeit\nNaira',
      style: AppTypography.display1.copyWith(color: AppColors.textInverse),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Scan any ₦200, ₦500 or ₦1,000 note instantly',
      style: AppTypography.body2.copyWith(
        color: AppColors.textInverse.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildBottomSection(HomeViewModel vm) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 32),
          _buildFeatureCard(vm),
          const SizedBox(height: 16),
          Text(
            'Supports ₦200 · ₦500 · ₦1,000',
            style: AppTypography.label,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(HomeViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [AppConstants.cardShadow],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildFeatureRow(
              Icons.shield_outlined,
              'Visual anomaly detection',
            ),
            const SizedBox(height: 16),
            _buildFeatureRow(
              Icons.text_fields_outlined,
              'Serial number verification',
            ),
            const SizedBox(height: 16),
            _buildFeatureRow(Icons.wifi_off_outlined, '100% offline'),
            const SizedBox(height: 24),
            PrimaryButtonWidget(
              label: 'Scan a Note',
              onPressed: vm.navigateToScan,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceGreen,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: AppTypography.body1),
        ),
      ],
    );
  }
}
