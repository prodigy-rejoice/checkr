import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../models/quality_check_result.dart';

class ImageQualityService {
  static const bool BYPASS_QUALITY_CHECKS = false;

  static const double _minLaplacianVariance = 30.0;
  static const double _minBrightness = 40.0;
  static const double _maxBrightness = 220.0;
  static const double _minNoteAreaRatio = 0.20;

  QualityCheckResult checkQuality(Uint8List imageBytes) {
    if (BYPASS_QUALITY_CHECKS) {
      return const QualityCheckResult(
        passedBlur: true,
        passedBrightness: true,
        passedNotePresence: true,
        feedbackMessage: 'Hold steady to scan',
      );
    }

    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      return const QualityCheckResult(
        passedBlur: false,
        passedBrightness: false,
        passedNotePresence: false,
        feedbackMessage: 'Position the note within the frame',
      );
    }

    final passedBlur = _checkBlur(decoded);
    final avgBrightness = _averageBrightness(decoded);
    final passedBrightness =
        avgBrightness >= _minBrightness && avgBrightness <= _maxBrightness;
    final passedNotePresence = _checkNotePresence(decoded);

    String feedbackMessage;
    if (!passedNotePresence) {
      feedbackMessage = 'Move closer — note must fill more of the frame';
    } else if (!passedBlur) {
      feedbackMessage = 'Image too blurry — hold the camera still';
    } else if (avgBrightness < _minBrightness) {
      feedbackMessage = 'Image too dark — move to better lighting';
    } else if (avgBrightness > _maxBrightness) {
      feedbackMessage = 'Image too bright — reduce direct light';
    } else {
      feedbackMessage = 'Hold steady to scan';
    }

    return QualityCheckResult(
      passedBlur: passedBlur,
      passedBrightness: passedBrightness,
      passedNotePresence: passedNotePresence,
      feedbackMessage: feedbackMessage,
    );
  }

  bool _checkBlur(img.Image image) =>
      _laplacianVariance(image) >= _minLaplacianVariance;

  double _laplacianVariance(img.Image image) {
    final grayscale = img.grayscale(image);
    final width = grayscale.width;
    final height = grayscale.height;

    double sum = 0.0;
    double sumSq = 0.0;
    int count = 0;

    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        final center = grayscale.getPixel(x, y).r.toDouble();
        final top = grayscale.getPixel(x, y - 1).r.toDouble();
        final bottom = grayscale.getPixel(x, y + 1).r.toDouble();
        final left = grayscale.getPixel(x - 1, y).r.toDouble();
        final right = grayscale.getPixel(x + 1, y).r.toDouble();

        final laplacian = (4 * center) - top - bottom - left - right;
        sum += laplacian;
        sumSq += laplacian * laplacian;
        count++;
      }
    }

    if (count == 0) return 0.0;
    final mean = sum / count;
    return (sumSq / count) - (mean * mean);
  }

  double _averageBrightness(img.Image image) {
    double total = 0.0;
    final pixelCount = image.width * image.height;
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final p = image.getPixel(x, y);
        total += (p.r + p.g + p.b) / 3.0;
      }
    }
    return total / pixelCount;
  }

  bool _checkNotePresence(img.Image image) {
    int nonBackground = 0;
    final pixelCount = image.width * image.height;
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final p = image.getPixel(x, y);
        final brightness = (p.r + p.g + p.b) / 3.0;
        if (brightness > 30 && brightness < 240) nonBackground++;
      }
    }
    return (nonBackground / pixelCount) >= _minNoteAreaRatio;
  }
}
