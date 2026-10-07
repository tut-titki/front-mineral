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
  factory ExecutorRating.fromJson(Map<String, dynamic> json) {
    double? number(String key) {
      final value = json[key];
      if (value == null) return null;
      final parsed = double.tryParse('$value');
      if (parsed == null || !parsed.isFinite) {
        throw FormatException('Некорректное поле рейтинга: $key');
      }
      return parsed;
    }

    final score = number('score');
    if (score == null || score < 0 || score > 100 || json['closed'] is! int) {
      throw const FormatException('Некорректный рейтинг исполнителя');
    }
    final points = <String, double>{};
    final rawPoints = json['points'];
    if (rawPoints is Map) {
      for (final entry in rawPoints.entries) {
        final value = double.tryParse('${entry.value}');
        if (value == null || !value.isFinite) {
          throw const FormatException('Некорректные баллы рейтинга');
        }
        points[entry.key as String] = value;
      }
    }
    final returnRate = number('returnRate');
    return ExecutorRating(
      score: score,
      explanation: json['explanation'] as String? ?? '',
      quality: number('quality'),
      onTimePercent: number('onTimeRate') == null
          ? null
          : number('onTimeRate')! * 100,
      reworkPercent: number('reworkRate') == null
          ? null
          : number('reworkRate')! * 100,
      completedCount: json['closed'] as int,
      noReturnPercent: returnRate == null ? null : (1 - returnRate) * 100,
      unjustifiedRejects: json['unjustifiedRejects'] as int?,
      points: Map.unmodifiable(points),
    );
  }

  const ExecutorRating({
    required this.score,
    required this.explanation,
    this.quality,
    this.onTimePercent,
    this.reworkPercent,
    this.completedCount,
    this.noReturnPercent,
    this.unjustifiedRejects,
    Map<String, double>? points,
  }) : _points = points;
  final double score;
  final String explanation;
  final double? quality;
  final double? onTimePercent;
  final double? reworkPercent;
  final int? completedCount;
  final double? noReturnPercent;
  final int? unjustifiedRejects;
  final Map<String, double>? _points;
  Map<String, double> get points => _points ?? const {};
}
