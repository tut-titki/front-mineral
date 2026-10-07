import '../models/executor_rating_period.dart';
import '../../references/data/reference_storage.dart';
import '../../references/data/reference_cache.dart';
import 'package:mineral/features/auth/data/auth_session.dart';
import 'package:mineral/shared/models/models.dart';
import '../models/executor_order_dto.dart';

class ExecutorApi {
  ExecutorApi(
    this.session, {
    ReferenceCache? referencesCache,
    ReferenceStorage? referenceStorage,
  }) : referenceCache =
           referencesCache ??
           ReferenceCache(
             scope: '${session.baseUrl}|${session.user?.id}',
             storage: referenceStorage,
             fetch: session.requestList,
           );
  final ReferenceCache referenceCache;
  final AuthSession session;
  Future<Map<String, dynamic>> loadRating({
    ExecutorRatingPeriod period = const ExecutorRatingPeriod(),
  }) => session.request('GET', '/api/reports/my-rating?${period.key}');
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
      referenceCache.get(name);
  Future<Map<String, dynamic>> action(int id, Map<String, dynamic> body) =>
      session.request(
        'POST',
        '/api/work-orders/$id/action',
        body: body,
        timeout: const Duration(seconds: 270),
      );
  Future<String> upload(OrderPhoto photo) async =>
      (await session.uploadPhoto(photo.name, photo.bytes))['url'] as String;
  Future<List<Map<String, dynamic>>> loadNotification() =>
      session.requestList('/api/notifications');
  Future<void> markNotificationRead(int id) async {
    final result = await session.request(
      'PATCH',
      '/api/notifications/$id/read',
    );
    if (result['updated'] != 1) {
      throw const FormatException(
        "Не удалось отметить уведомление прочитанным",
      );
    }
  }
}
