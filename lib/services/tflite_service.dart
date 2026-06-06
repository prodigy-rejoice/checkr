import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

import '../core/constants/app_constants.dart';

class TfliteService {
  static const MethodChannel _channel = MethodChannel('checkr/tflite');

  bool _loaded = false;

  Future<void> loadModel() async {
    final ok = await _channel.invokeMethod<bool>(
      'loadModel',
      <String, dynamic>{'assetPath': 'assets/models/naira_autoencoder_v2.tflite'},
    );
    _loaded = ok ?? false;
  }

  bool get isLoaded => _loaded;

  Future<Map<String, dynamic>> runInference(Uint8List imageBytes) async {
    if (!_loaded) {
      return {'mseScore': 0.0, 'isGenuine': false};
    }

    final inputBytes = _preprocessToFloat32Bytes(imageBytes);
    if (inputBytes == null) {
      return {'mseScore': 0.0, 'isGenuine': false};
    }

    final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'runInference',
      <String, dynamic>{'input': inputBytes},
    );

    if (result == null) {
      return {'mseScore': 0.0, 'isGenuine': false};
    }

    final mse = (result['mseScore'] as num).toDouble();
    final genuine = result['isGenuine'] as bool? ?? (mse <= AppConstants.threshold);
    return {'mseScore': mse, 'isGenuine': genuine};
  }

  Uint8List? _preprocessToFloat32Bytes(Uint8List imageBytes) {
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) return null;
    final resized = img.copyResize(
      decoded,
      width: AppConstants.inputSize,
      height: AppConstants.inputSize,
    );

    final floats = Float32List(
      AppConstants.inputSize * AppConstants.inputSize * 3,
    );
    var i = 0;
    for (var y = 0; y < AppConstants.inputSize; y++) {
      for (var x = 0; x < AppConstants.inputSize; x++) {
        final p = resized.getPixel(x, y);
        floats[i++] = (p.r / AppConstants.normalisationScale) - 1.0;
        floats[i++] = (p.g / AppConstants.normalisationScale) - 1.0;
        floats[i++] = (p.b / AppConstants.normalisationScale) - 1.0;
      }
    }
    return floats.buffer.asUint8List();
  }

  Future<void> dispose() async {
    await _channel.invokeMethod('dispose');
    _loaded = false;
  }
}
