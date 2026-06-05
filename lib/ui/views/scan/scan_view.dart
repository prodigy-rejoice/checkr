import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/enums/quality_status.dart';
import '../../widgets/quality_indicator_widget.dart';
import '../../widgets/scan_overlay_widget.dart';
import 'scan_viewmodel.dart';

class ScanView extends StatelessWidget {
  const ScanView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ScanViewModel>.reactive(
      viewModelBuilder: () => ScanViewModel(),
      onViewModelReady: (vm) => vm.initialise(),
      disposeViewModel: true,
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: _buildBody(context, vm),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ScanViewModel vm) {
    final controller = vm.cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
        ),
      );
    }

    final size = MediaQuery.of(context).size;

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(controller),
        Container(color: AppColors.scanOverlay),
        ScanOverlayWidget(qualityResult: vm.qualityResult),
        Positioned(
          top: size.height * 0.3,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              QualityIndicatorWidget(
                label: 'Blur',
                status: vm.qualityResult == null
                    ? QualityStatus.marginal
                    : (vm.qualityResult!.passedBlur
                        ? QualityStatus.passing
                        : QualityStatus.failing),
              ),
              const SizedBox(width: 8),
              QualityIndicatorWidget(
                label: 'Light',
                status: vm.qualityResult == null
                    ? QualityStatus.marginal
                    : (vm.qualityResult!.passedBrightness
                        ? QualityStatus.passing
                        : QualityStatus.failing),
              ),
              const SizedBox(width: 8),
              QualityIndicatorWidget(
                label: 'Frame',
                status: vm.qualityResult == null
                    ? QualityStatus.marginal
                    : (vm.qualityResult!.passedNotePresence
                        ? QualityStatus.passing
                        : QualityStatus.failing),
              ),
            ],
          ),
        ),
        Positioned(
          top: size.height * 0.58,
          left: 24,
          right: 24,
          child: Text(
            vm.qualityResult?.feedbackMessage ??
                'Position the note within the frame',
            style: AppTypography.body2.copyWith(color: AppColors.textInverse),
            textAlign: TextAlign.center,
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
            color: Colors.black54,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: vm.cancel,
                  child: Text(
                    'Cancel',
                    style: AppTypography.button.copyWith(
                      color: AppColors.textInverse,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: vm.captureAndScan,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: vm.toggleTorch,
                  icon: Icon(
                    vm.isTorchOn ? Icons.flash_on : Icons.flash_off,
                    color: AppColors.textInverse,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
