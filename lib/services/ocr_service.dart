import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import '../core/constants/app_constants.dart';

class OcrService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final _serialRegex = RegExp(AppConstants.serialPattern);

  bool isValidCBNFormat(String serial) {
    return _serialRegex.hasMatch(serial);
  }

  Future<String?> extractSerial(Uint8List imageBytes) async {
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) return null;

    final roiHeight = (decoded.height / 3).round();
    final cropped = img.copyCrop(
      decoded,
      x: 0,
      y: 0,
      width: decoded.width,
      height: roiHeight,
    );

    final croppedBytes = img.encodeJpg(cropped);
    final inputImage = InputImage.fromBytes(
      bytes: Uint8List.fromList(croppedBytes),
      metadata: InputImageMetadata(
        size: Size(cropped.width.toDouble(), cropped.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.bgra8888,
        bytesPerRow: cropped.width * 4,
      ),
    );

    final recognizedText = await _textRecognizer.processImage(inputImage);

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        for (final element in line.elements) {
          final text = element.text.trim().toUpperCase();
          if (_serialRegex.hasMatch(text)) {
            return text;
          }
        }
      }
    }

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final combined = line.text.replaceAll(' ', '').toUpperCase();
        if (_serialRegex.hasMatch(combined)) {
          return combined;
        }
      }
    }

    return null;
  }

  Future<String> extractFullText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognized = await _textRecognizer.processImage(inputImage);
    return recognized.text;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
