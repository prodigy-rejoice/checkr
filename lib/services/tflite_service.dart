import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../core/constants/app_constants.dart';

class TfliteService {
  Interpreter? _interpreter;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/models/naira_autoencoder.tflite',
    );
  }

  bool get isLoaded => _interpreter != null;

  Future<Map<String, dynamic>> runInference(Uint8List imageBytes) async {
    final interpreter = _interpreter;
    if (interpreter == null) {
      return {'mseScore': 0.0, 'isGenuine': false};
    }

    final inputTensor = _preprocessImage(imageBytes);
    final outputTensor = List.generate(
      1,
      (_) => List.generate(
        AppConstants.inputSize,
        (_) => List.generate(
          AppConstants.inputSize,
          (_) => List.filled(3, 0.0),
        ),
      ),
    );

    interpreter.run(inputTensor, outputTensor);

    final mse = _computeMse(inputTensor[0], outputTensor[0]);
    return {'mseScore': mse, 'isGenuine': mse <= AppConstants.threshold};
  }

  List<List<List<List<double>>>> _preprocessImage(Uint8List imageBytes) {
    final decoded = img.decodeImage(imageBytes);
    final resized = img.copyResize(
      decoded!,
      width: AppConstants.inputSize,
      height: AppConstants.inputSize,
    );

    final input = List.generate(
      1,
      (_) => List.generate(
        AppConstants.inputSize,
        (y) => List.generate(
          AppConstants.inputSize,
          (x) {
            final pixel = resized.getPixel(x, y);
            return [
              (pixel.r / AppConstants.normalisationScale) - 1.0,
              (pixel.g / AppConstants.normalisationScale) - 1.0,
              (pixel.b / AppConstants.normalisationScale) - 1.0,
            ];
          },
        ),
      ),
    );
    return input;
  }

  double _computeMse(
    List<List<List<double>>> input,
    List<List<List<double>>> output,
  ) {
    double sum = 0.0;
    int count = 0;
    for (int y = 0; y < AppConstants.inputSize; y++) {
      for (int x = 0; x < AppConstants.inputSize; x++) {
        for (int c = 0; c < 3; c++) {
          final diff = input[y][x][c] - output[y][x][c];
          sum += diff * diff;
          count++;
        }
      }
    }
    return sum / count;
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
