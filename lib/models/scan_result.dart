class ScanResult {
  final bool isGenuine;
  final bool isOutOfScope;
  final double mseScore;
  final bool passedVisualCheck;
  final String? extractedSerial;
  final bool serialFormatValid;
  final bool serialBlacklisted;
  final DateTime scannedAt;
  final String verdictReason;

  const ScanResult({
    required this.isGenuine,
    this.isOutOfScope = false,
    required this.mseScore,
    required this.passedVisualCheck,
    this.extractedSerial,
    required this.serialFormatValid,
    required this.serialBlacklisted,
    required this.scannedAt,
    required this.verdictReason,
  });
}
