import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/enums/scan_status.dart';
import '../../../models/quality_check_result.dart';
import '../../../models/scan_result.dart';
import '../../../repositories/blacklist_repository.dart';
import '../../../services/image_quality_service.dart';
import '../../../services/ocr_service.dart';
import '../../../services/tflite_service.dart';

class ScanViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _tfliteService = locator<TfliteService>();
  final _ocrService = locator<OcrService>();
  final _blacklistRepository = locator<BlacklistRepository>();
  final _imageQualityService = locator<ImageQualityService>();

  CameraController? _cameraController;
  ScanStatus _status = ScanStatus.idle;
  QualityCheckResult? _qualityResult;
  bool _isTorchOn = false;
  DateTime _lastQualityCheck = DateTime(0);

  CameraController? get cameraController => _cameraController;
  ScanStatus get status => _status;
  QualityCheckResult? get qualityResult => _qualityResult;
  bool get isTorchOn => _isTorchOn;

  Future<void> initialise() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      _cameraController!.startImageStream(_onCameraFrame);
      notifyListeners();
    } catch (e) {
      setError(e);
    }
  }

  void _onCameraFrame(CameraImage frame) {
    final now = DateTime.now();
    if (now.difference(_lastQualityCheck).inMilliseconds < 500) return;
    if (_status != ScanStatus.idle && _status != ScanStatus.checkingQuality) {
      return;
    }

    _lastQualityCheck = now;
    _status = ScanStatus.checkingQuality;

    final bytes = _cameraImageToBytes(frame);
    if (bytes != null) {
      _qualityResult = _imageQualityService.checkQuality(bytes);
      notifyListeners();
    }
    _status = ScanStatus.idle;
  }

  Uint8List? _cameraImageToBytes(CameraImage frame) {
    try {
      if (frame.format.group == ImageFormatGroup.yuv420) {
        return frame.planes[0].bytes;
      } else if (frame.format.group == ImageFormatGroup.bgra8888) {
        return frame.planes[0].bytes;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> captureAndScan() async {
    if (_status == ScanStatus.processing) return;
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    _status = ScanStatus.processing;
    notifyListeners();

    try {
      await controller.stopImageStream();
      final image = await controller.takePicture();
      final imageBytes = await image.readAsBytes();

      final qualityResult = _imageQualityService.checkQuality(imageBytes);
      if (!qualityResult.allPassed) {
        _status = ScanStatus.idle;
        notifyListeners();
        await controller.startImageStream(_onCameraFrame);
        return;
      }

      final inferenceResult = await _tfliteService.runInference(imageBytes);
      final serial = await _ocrService.extractSerial(imageBytes);

      final isBlacklisted =
          serial != null ? _blacklistRepository.isBlacklisted(serial) : false;

      final serialValid =
          serial != null && RegExp(r'^[A-Z]{2}\d{8}$').hasMatch(serial);

      final isGenuine =
          (inferenceResult['isGenuine'] as bool) && !isBlacklisted;

      final result = ScanResult(
        isGenuine: isGenuine,
        mseScore: inferenceResult['mseScore'] as double,
        passedVisualCheck: inferenceResult['isGenuine'] as bool,
        extractedSerial: serial,
        serialFormatValid: serialValid,
        serialBlacklisted: isBlacklisted,
        scannedAt: DateTime.now(),
      );

      _status = ScanStatus.complete;
      await _navigationService.navigateToResultView(result: result);
    } catch (e) {
      _status = ScanStatus.error;
      setError(e);
    }

    notifyListeners();
  }

  Future<void> toggleTorch() async {
    final controller = _cameraController;
    if (controller == null) return;
    _isTorchOn = !_isTorchOn;
    await controller.setFlashMode(
      _isTorchOn ? FlashMode.torch : FlashMode.off,
    );
    notifyListeners();
  }

  void cancel() {
    _navigationService.back();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
