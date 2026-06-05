class QualityCheckResult {
  final bool passedBlur;
  final bool passedBrightness;
  final bool passedNotePresence;
  final String feedbackMessage;

  const QualityCheckResult({
    required this.passedBlur,
    required this.passedBrightness,
    required this.passedNotePresence,
    required this.feedbackMessage,
  });

  bool get allPassed => passedBlur && passedBrightness && passedNotePresence;
}
