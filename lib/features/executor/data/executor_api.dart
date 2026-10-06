import 'package:mineral/features/auth/data/auth_session.dart';
import 'package:mineral/shared/models/models.dart';
import '../models/executor_order_dto.dart';

class ExecutorApi {
  ExecutorApi(this.session);
  final AuthSession session;
  Future<List<ExecutorOrderDto>> loadOrders(
    String statuses, {
    int offset = 0,
  }) async {
    final items = await session.requestList(
      '/api/work-orders?compact=1&status=$statuses&limit=200&offset=$offset',
    );
    return items.map(ExecutorOrderDto.fromJson).toList();
  }

  Future<List<ExecutorOrderDto>> localActiveOrder({int offset = 0}) =>
      loadOrders(
        'ISSUED,QUEUED,ACCEPTED,IN_PROGRESS,PAUSED,REWORK',
        offset: offset,
      );
  Future<ExecutorOrderDto> loadOrder(int id) async => ExecutorOrderDto.fromJson(
    await session.request('GET', '/api/work-orders/$id'),
  );
  Future<List<Map<String, dynamic>>> references(String name) =>
      session.requestList('/api/references/$name');
  Future<Map<String, dynamic>> action(int id, Map<String, dynamic> body) =>
      session.request(
        'POST',
        '/api/work-orders/$id/action',
        body: body,
        timeout: const Duration(seconds: 270),
      );
  Future<String> upload(OrderPhoto photo) async =>
      (await session.uploadPhoto(photo.name, photo.bytes))['url'] as String;
}
