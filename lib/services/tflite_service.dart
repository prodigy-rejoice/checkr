import 'package:flutter/services.dart';

import '../core/constants/app_constants.dart';

class TfliteService {
  static const MethodChannel _channel = MethodChannel('checkr/tflite');

  bool _loaded = false;

  Future<void> loadModel() async {
    try {
      final ok = await _channel.invokeMethod<bool>(
        'loadModel',
        <String, dynamic>{'assetPath': 'assets/models/naira_autoencoder_v2.tflite'},
      );
      _loaded = ok ?? false;
      print('[TfliteService] loadModel result: $_loaded');
    } catch (e, s) {
      _loaded = false;
      print('[TfliteService] loadModel failed: $e\n$s');
      rethrow;
    }
  }

  bool get isLoaded => _loaded;

  Future<Map<String, dynamic>> runInference(String imagePath) async {
    print('[TfliteService] runInference called. isLoaded=$_loaded, path=$imagePath');

    if (!_loaded) {
      print('[TfliteService] Model not loaded — returning mse=0.0');
      return {'mseScore': 0.0, 'isGenuine': false};
    }

    try {
      final mse = await _channel.invokeMethod<double>(
        'runInference',
        <String, dynamic>{'imagePath': imagePath},
      );

      if (mse == null) {
        print('[TfliteService] Kotlin returned null MSE');
        return {'mseScore': 0.0, 'isGenuine': false};
      }

      final isGenuine = mse <= AppConstants.threshold;
      print('[TfliteService] MSE=$mse  isGenuine=$isGenuine  threshold=${AppConstants.threshold}');
      return {'mseScore': mse, 'isGenuine': isGenuine};
    } catch (e, s) {
      print('[TfliteService] runInference error: $e\n$s');
      rethrow;
    }
  }

  Future<void> dispose() async {
    await _channel.invokeMethod('dispose');
    _loaded = false;
  }
}
