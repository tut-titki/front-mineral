import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/features/executor/models/execution_assessment.dart';

void main() {
  test('missing rating components have a safe empty map', () {
    const legacy = ExecutorRating(score: 79, explanation: '', points: null);
    expect(legacy.points, isEmpty);
    for (final points in [null, <String, dynamic>{}]) {
      final rating = ExecutorRating.fromJson({
        'score': 79,
        'closed': 12,
        'points': points,
      });
      expect(rating.points, isEmpty);
    }
  });

  test('server rating components preserve numeric values', () {
    final rating = ExecutorRating.fromJson({
      'score': 79,
      'closed': 12,
      'points': {'quality': '40.5', 'onTime': 20, 'rejects': -2},
    });
    expect(rating.points, {'quality': 40.5, 'onTime': 20.0, 'rejects': -2.0});
  });
}
