class ScanResult {
  final bool isGenuine;
  final double mseScore;
  final bool passedVisualCheck;
  final String? extractedSerial;
  final bool serialFormatValid;
  final bool serialBlacklisted;
  final DateTime scannedAt;

  const ScanResult({
    required this.isGenuine,
    required this.mseScore,
    required this.passedVisualCheck,
    this.extractedSerial,
    required this.serialFormatValid,
    required this.serialBlacklisted,
    required this.scannedAt,
  });
}
