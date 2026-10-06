import 'dart:typed_data';
import '../../../core/api/api_client.dart';
import '../../../core/api/backend_document.dart';

class ReportsApi {
  const ReportsApi(this._client);
  final ApiClient _client;

  Future<BackendDocument> _get(String path) async =>
      BackendDocument.fromJson((await _client.get('/api/reports/$path')).data);
  Future<BackendDocument> getShift() => _get('shift');
  Future<BackendDocument> getRatings() => _get('ratings');
  Future<BackendDocument> getBrigadeRatings() => _get('brigade-ratings');
  Future<BackendDocument> getMaterials() => _get('materials');
  Future<BackendDocument> getDowntime() => _get('downtime');
  Future<BackendDocument> getWorkOrder(int id) => _get('work-order/$id');
  Future<Uint8List> export({required bool pdf}) =>
      _client.getBytes('/api/reports/export.${pdf ? 'pdf' : 'xlsx'}');
}
