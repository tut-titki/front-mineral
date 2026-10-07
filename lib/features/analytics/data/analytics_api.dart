import '../../../core/api/api_client.dart';
import '../../../core/api/backend_document.dart';

class DashboardAnalytics {
  DashboardAnalytics.fromJson(Map<String, dynamic> json)
    : active = _number(json['active']),
      overdue = _number(json['overdue']),
      equipmentInDowntime = _number(json['equipmentInDowntime']),
      averageReactionMinutes = _number(json['averageReactionMinutes']),
      averageCompletionMinutes = _number(json['averageCompletionMinutes']),
      topEquipment = BackendDocument.fromJson(json['topEquipment']),
      topExecutors = BackendDocument.fromJson(json['topExecutors']);

  final num? active, overdue, equipmentInDowntime;
  final num? averageReactionMinutes, averageCompletionMinutes;
  final BackendDocument topEquipment, topExecutors;

  static num? _number(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    final number = num.tryParse(value.toString());
    if (number == null) throw const FormatException('Invalid analytics number');
    return number;
  }
}

class AnalyticsApi {
  const AnalyticsApi(this._client);
  final ApiClient _client;

  Future<DashboardAnalytics> getDashboard() async {
    final response = await _client.get('/api/analytics/dashboard');
    if (response.data is! Map) {
      throw const ApiException(
        statusCode: 502,
        message: 'Сервер вернул неверный формат аналитики',
      );
    }
    return DashboardAnalytics.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<BackendDocument> getFailureForecast({int days = 30}) async =>
      BackendDocument.fromJson(
        (await _client.get(
          '/api/analytics/failure-forecast',
          queryParameters: {'days': days},
        )).data,
      );

  Future<BackendDocument> getAnomalies() async => BackendDocument.fromJson(
    (await _client.get('/api/analytics/anomalies')).data,
  );
}
