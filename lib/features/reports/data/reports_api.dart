import 'dart:typed_data';
import '../../../core/api/api_client.dart';
import '../../../core/api/backend_document.dart';

class ReportsApi {
  const ReportsApi(this._client);
  final ApiClient _client;

  Future<BackendDocument> getReport(
    String report, {
    Map<String, dynamic>? filters,
  }) async => BackendDocument.fromJson(
    (await _client.get('/api/reports/$report', queryParameters: filters)).data,
  );
  Future<BackendDocument> getShift({Map<String, dynamic>? filters}) =>
      getReport('shift', filters: filters);
  Future<BackendDocument> getRatings({Map<String, dynamic>? filters}) =>
      getReport('ratings', filters: filters);
  Future<BackendDocument> getBrigadeRatings({Map<String, dynamic>? filters}) =>
      getReport('brigade-ratings', filters: filters);
  Future<BackendDocument> getMaterials({Map<String, dynamic>? filters}) =>
      getReport('materials', filters: filters);
  Future<BackendDocument> getDowntime({Map<String, dynamic>? filters}) =>
      getReport('downtime', filters: filters);
  Future<BackendDocument> getWorkOrder(int id) => getReport('work-order/$id');
  Future<Uint8List> export({
    required bool pdf,
    String report = 'orders',
    Map<String, dynamic>? filters,
  }) => _client.getBytes(
    '/api/reports/export.${pdf ? 'pdf' : 'xlsx'}',
    queryParameters: {'report': report, ...?filters},
  );
  Future<Uint8List> exportWorkOrder(int id) =>
      _client.getBytes('/api/reports/work-order/$id.pdf');
}
