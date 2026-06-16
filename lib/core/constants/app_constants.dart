import 'package:flutter/material.dart';

class AppConstants {
  static const double mu = 0.051376;
  static const double sigma = 0.013475;
  static const double threshold = 0.078327;

  static const int inputSize = 224;
  static const double normalisationScale = 127.5;

  static const String serialPattern = r'^[A-Z]{2}\d{8}$';

  static const double minLaplacianVariance = 100.0;
  static const double minBrightness = 40.0;
  static const double maxBrightness = 220.0;
  static const double minNoteAreaRatio = 0.35;

  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 16,
    offset: Offset(0, 4),
  );

  static const BoxShadow buttonShadow = BoxShadow(
    color: Color(0x331B5E37),
    blurRadius: 12,
    offset: Offset(0, 4),
  );
}
