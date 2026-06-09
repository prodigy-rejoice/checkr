import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/enums/scan_status.dart';
import '../../../models/scan_result.dart';
import '../../../repositories/blacklist_repository.dart';
import '../../../services/ocr_service.dart';
import '../../../services/tflite_service.dart';

class ScanViewModel extends BaseViewModel {
  static const bool BYPASS_QUALITY_CHECKS = true;

  final _navigationService = locator<NavigationService>();
  final _tfliteService = locator<TfliteService>();
  final _ocrService = locator<OcrService>();
  final _blacklistRepository = locator<BlacklistRepository>();
  final _imagePicker = ImagePicker();

  ScanStatus _status = ScanStatus.idle;

  ScanStatus get status => _status;
  bool get isProcessing => _status == ScanStatus.processing;

  Future<void> captureAndScan() async {
    if (_status == ScanStatus.processing) return;

    print('[ScanViewModel] captureAndScan() called');

    final picked = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (picked == null) {
      print('[ScanViewModel] User cancelled image picker');
      return;
    }

    print('[ScanViewModel] Image picked: ${picked.path}');

    _status = ScanStatus.processing;
    notifyListeners();

    final stopwatch = Stopwatch()..start();

    try {
      final imageBytes = await picked.readAsBytes();
      print('[ScanViewModel] Image bytes read: ${imageBytes.length} bytes');

      if (BYPASS_QUALITY_CHECKS) {
        print('[ScanViewModel] Quality checks BYPASSED');
      }

      print('[ScanViewModel] Running OCR for note classification...');
      final rawText = await _ocrService.extractFullText(picked.path);
      final ocrText = rawText.toUpperCase();
      print('[ScanViewModel] OCR full text (uppercase): $ocrText');

      const nairaMarkers = [
        'NIGERIA', 'NAIRA', 'CENTRAL BANK', 'CBN', 'LEGAL TENDER', 'TENDER',
      ];
      const unsupportedWords = [
        'FIFTY', 'TWENTY', 'TEN NAIRA', 'FIVE NAIRA',
      ];

      final hasNairaMarker = nairaMarkers.any((m) => ocrText.contains(m));
      final isUnsupportedDenom = unsupportedWords.any((w) => ocrText.contains(w));

      print('[ScanViewModel] hasNairaMarker = $hasNairaMarker');
      print('[ScanViewModel] isUnsupportedDenom = $isUnsupportedDenom');

      print('[ScanViewModel] Running TFLite inference on path: ${picked.path}');
      final inferenceResult = await _tfliteService.runInference(picked.path);
      final mse = (inferenceResult['mseScore'] as num).toDouble();
      print('[ScanViewModel] Inference complete. MSE = $mse  threshold = ${AppConstants.threshold}');

      if (mse > AppConstants.threshold) {
        final ScanResult result;

        if (isUnsupportedDenom) {
          print('[ScanViewModel] Final verdict: OUT_OF_SCOPE (unsupported denomination)');
          result = ScanResult(
            isGenuine: false,
            isOutOfScope: true,
            mseScore: mse,
            passedVisualCheck: false,
            extractedSerial: null,
            serialFormatValid: false,
            serialBlacklisted: false,
            scannedAt: DateTime.now(),
            verdictReason:
                'Unsupported denomination. Checkr only verifies ₦200, ₦500 and ₦1,000 notes.',
          );
        } else if (hasNairaMarker) {
          print('[ScanViewModel] Final verdict: COUNTERFEIT (Naira marker found, high MSE)');
          result = ScanResult(
            isGenuine: false,
            mseScore: mse,
            passedVisualCheck: false,
            extractedSerial: null,
            serialFormatValid: false,
            serialBlacklisted: false,
            scannedAt: DateTime.now(),
            verdictReason:
                'Visual anomaly detected. This note does not match genuine Naira characteristics.',
          );
        } else {
          print('[ScanViewModel] Final verdict: NOT_A_NOTE (no Naira markers, high MSE)');
          result = ScanResult(
            isGenuine: false,
            isOutOfScope: true,
            mseScore: mse,
            passedVisualCheck: false,
            extractedSerial: null,
            serialFormatValid: false,
            serialBlacklisted: false,
            scannedAt: DateTime.now(),
            verdictReason:
                'Not a currency note. Please scan a Nigerian Naira banknote clearly in good lighting.',
          );
        }

        stopwatch.stop();
        print('[ScanViewModel] Total scan latency: ${stopwatch.elapsedMilliseconds}ms');
        _status = ScanStatus.complete;
        notifyListeners();
        await _navigationService.navigateToResultView(result: result);
        _status = ScanStatus.idle;
        notifyListeners();
        return;
      }

      print('[ScanViewModel] MSE within threshold — running serial OCR...');

      // First try extracting serial from the full OCR text we already have.
      String? rawSerial = _ocrService.extractSerialFromText(ocrText);
      print('[ScanViewModel] Serial from full text: $rawSerial');

      // Fall back to cropped-image OCR if full-text search didn't find it.
      if (rawSerial == null) {
        print('[ScanViewModel] Full-text miss — trying cropped image OCR...');
        rawSerial = await _ocrService.extractSerial(imageBytes);
        print('[ScanViewModel] Serial from cropped OCR: $rawSerial');
      }

      final serial = rawSerial != null ? _ocrService.normaliseSerial(rawSerial) : null;
      print('[ScanViewModel] OCR result: rawSerial = $rawSerial  normalised = $serial');

      final serialValid = serial != null && _ocrService.isValidCBNFormat(rawSerial!);
      print('[ScanViewModel] Serial format valid: $serialValid');

      final isBlacklisted = serial != null ? _blacklistRepository.isBlacklisted(serial) : false;
      print('[ScanViewModel] Serial blacklisted: $isBlacklisted');

      String reason;
      bool isGenuine;

      if (serial == null) {
        isGenuine = false;
        reason =
            'Visual check passed but serial number could not be extracted. '
            'Please retake the photo with the serial number clearly visible.';
        print('[ScanViewModel] Verdict: UNVERIFIED — serial not extracted');
      } else if (!serialValid) {
        isGenuine = false;
        reason =
            'Visual check passed but the serial number format is invalid. '
            'Detected: $serial';
        print('[ScanViewModel] Verdict: SUSPICIOUS — invalid serial format');
      } else if (isBlacklisted) {
        isGenuine = false;
        reason = 'Serial number is blacklisted.';
        print('[ScanViewModel] Verdict: COUNTERFEIT — serial blacklisted');
      } else {
        isGenuine = true;
        reason = 'Visual check passed and serial number verified.';
        print('[ScanViewModel] Verdict: GENUINE');
      }

      final result = ScanResult(
        isGenuine: isGenuine,
        mseScore: mse,
        passedVisualCheck: true,
        extractedSerial: serial,
        serialFormatValid: serialValid,
        serialBlacklisted: isBlacklisted,
        scannedAt: DateTime.now(),
        verdictReason: reason,
      );

      stopwatch.stop();
      print('[ScanViewModel] Total scan latency: ${stopwatch.elapsedMilliseconds}ms');
      _status = ScanStatus.complete;
      notifyListeners();
      print('[ScanViewModel] Navigating to ResultView...');
      await _navigationService.navigateToResultView(result: result);
      _status = ScanStatus.idle;
      notifyListeners();
    } catch (e, s) {
      print('[ScanViewModel] ERROR: $e\n$s');
      _status = ScanStatus.error;
      setError(e);
      notifyListeners();
    }
  }

  void cancel() {
    _navigationService.back();
  }
}
