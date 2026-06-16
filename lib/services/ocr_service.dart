import 'dart:io';
import 'dart:typed_data';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class OcrService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  // ^[A-Z]{1,2}\/?\d{1,2}\s?\d{6}$
  // Matches CBN SERIAL NUMBER FORMAT
  static final _serialRegex = RegExp(r'^[A-Z]{1,2}\/?\d{1,2}\s?\d{6}$');

  bool isValidCBNFormat(String serial) => _serialRegex.hasMatch(serial);

  // Strips spaces and slashes → canonical storage/lookup form.
  // "AA/9 334338" → "AA9334338", "Y/64 235913" → "Y64235913"
  String normaliseSerial(String serial) =>
      serial.replaceAll(RegExp(r'[\s/]'), '');

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

    // Write cropped image to a temp file so ML Kit can handle
    // format detection internally via fromFilePath.
    final croppedBytes = img.encodeJpg(cropped);
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/ocr_crop_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(croppedBytes);

    final inputImage = InputImage.fromFilePath(tempFile.path);

    final recognizedText = await _textRecognizer.processImage(inputImage);

    // Clean up the temp file after OCR is done.
    try { await tempFile.delete(); } catch (_) {}

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        for (final element in line.elements) {
          final text = element.text.trim().toUpperCase();
          if (_serialRegex.hasMatch(text)) return normaliseSerial(text);
        }
      }
    }

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final combined = line.text.replaceAll(' ', '').toUpperCase();
        if (_serialRegex.hasMatch(combined)) return normaliseSerial(combined);
      }
    }

    return null;
  }

  /// Search for a serial number in already-extracted OCR text.
  /// This avoids re-running OCR and works on the full image text.
  String? extractSerialFromText(String ocrText) {
    // Try each line/word individually
    for (final line in ocrText.split('\n')) {
      for (final word in line.split(RegExp(r'\s+'))) {
        final cleaned = word.trim().toUpperCase();
        if (_serialRegex.hasMatch(cleaned)) return cleaned;
      }
      // Also try the whole line with spaces removed
      final combined = line.replaceAll(' ', '').trim().toUpperCase();
      if (_serialRegex.hasMatch(combined)) return combined;
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
