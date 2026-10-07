class ExecutorRatingPeriod {
  const ExecutorRatingPeriod([this.period = 'month']) : from = null, to = null;
  ExecutorRatingPeriod.custom(DateTime start, DateTime end)
    : period = 'custom',
      from = start.toUtc(),
      to = end.toUtc() {
    if (!end.isAfter(start)) throw ArgumentError('Invalid rating range');
  }
  final String period;
  final DateTime? from;
  final DateTime? to;
  Map<String, String> get query => from == null
      ? {'period': period}
      : {'from': from!.toIso8601String(), 'to': to!.toIso8601String()};
  String get key => Uri(queryParameters: query).query;
}
