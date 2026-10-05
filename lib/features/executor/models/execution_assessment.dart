class ExecutionAssessment {
  const ExecutionAssessment({
    required this.verdict,
    this.score,
    this.strengths = '',
    this.improvements = '',
    this.explanation = '',
  });
  final String verdict;
  final double? score;
  final String strengths;
  final String improvements;
  final String explanation;
}

class ExecutorRating {
  const ExecutorRating({
    required this.score,
    required this.explanation,
    this.quality,
    this.onTimePercent,
    this.reworkPercent,
    this.completedCount,
  });
  final double score;
  final String explanation;
  final double? quality;
  final double? onTimePercent;
  final double? reworkPercent;
  final int? completedCount;
}
