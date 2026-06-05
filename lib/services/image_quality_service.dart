import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../core/constants/app_constants.dart';
import '../models/quality_check_result.dart';

class ImageQualityService {
  QualityCheckResult checkQuality(Uint8List imageBytes) {
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
    final passedBrightness = _checkBrightness(decoded);
    final passedNotePresence = _checkNotePresence(decoded);

    final feedbackMessage = _buildFeedback(
      passedBlur,
      passedBrightness,
      passedNotePresence,
    );

    return QualityCheckResult(
      passedBlur: passedBlur,
      passedBrightness: passedBrightness,
      passedNotePresence: passedNotePresence,
      feedbackMessage: feedbackMessage,
    );
  }

  bool _checkBlur(img.Image image) {
    final variance = _laplacianVariance(image);
    return variance >= AppConstants.minLaplacianVariance;
  }

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

  bool _checkBrightness(img.Image image) {
    double totalBrightness = 0.0;
    final pixelCount = image.width * image.height;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        totalBrightness += (pixel.r + pixel.g + pixel.b) / 3.0;
      }
    }

    final avgBrightness = totalBrightness / pixelCount;
    return avgBrightness >= AppConstants.minBrightness &&
        avgBrightness <= AppConstants.maxBrightness;
  }

  bool _checkNotePresence(img.Image image) {
    int nonBackgroundCount = 0;
    final pixelCount = image.width * image.height;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toDouble();
        final g = pixel.g.toDouble();
        final b = pixel.b.toDouble();

        final brightness = (r + g + b) / 3.0;
        if (brightness > 30 && brightness < 240) {
          nonBackgroundCount++;
        }
      }
    }

    return (nonBackgroundCount / pixelCount) >= AppConstants.minNoteAreaRatio;
  }

  String _buildFeedback(
    bool passedBlur,
    bool passedBrightness,
    bool passedNotePresence,
  ) {
    if (!passedNotePresence) return 'Position the note within the frame';
    if (!passedBlur) return 'Too blurry — hold the camera still';
    if (!passedBrightness) return 'Adjust lighting for better visibility';
    return 'Hold steady to scan';
  }
}
