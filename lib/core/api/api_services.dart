import '../../features/references/data/reference_cache.dart';
import '../../features/references/data/reference_storage.dart';
import '../../features/orders/data/recommendations_api.dart';
import '../../features/orders/data/references_api.dart';
import '../../features/orders/data/uploads_api.dart';
import '../../features/orders/data/work_orders_api.dart';

import 'api_client.dart';
import 'package:http/http.dart' as http;
import '../services/master_realtime_service.dart';
import '../../features/analytics/data/analytics_api.dart';
import '../../features/assistant/data/assistant_api.dart';
import '../../features/notifications/data/notifications_api.dart';
import '../../features/reports/data/reports_api.dart';

/// Единая точка доступа ко всем backend API.
///
/// Здесь мы создаём один ApiClient и передаём его
/// во все API-сервисы приложения.
///
/// Благодаря этому:
/// - JWT хранится в одном ApiClient;
/// - baseUrl задаётся один раз;
/// - экраны не создают API-клиенты самостоятельно;
/// - DemoStore постепенно можно полностью убрать.
class ApiServices {
  ApiServices({
    required String baseUrl,
    http.Client? httpClient,
    ReferenceStorage? referenceStorage,
    ReferenceCache? referenceCache,
  }) : _baseUrl = _normalizeBaseUrl(baseUrl) {
    client = ApiClient(baseUrl: _baseUrl, httpClient: httpClient);

    workOrders = WorkOrdersApi(client);
    realtime = MasterRealtimeService(_baseUrl);
    analytics = AnalyticsApi(client);
    assistant = AssistantApi(client);
    notifications = NotificationsApi(client);
    reports = ReportsApi(client);

    references = ReferencesApi(
      client,
      cacheNamespace: _baseUrl,
      storage: referenceStorage,
      referenceCache: referenceCache,
    );

    recommendations = RecommendationsApi(client);

    uploads = UploadsApi(client: client, baseUrl: _baseUrl);
  }

  // MARK: - Base URL

  final String _baseUrl;

  String get baseUrl => _baseUrl;

  // MARK: - Core client

  late final ApiClient client;
  late final MasterRealtimeService realtime;
  late final AnalyticsApi analytics;
  late final AssistantApi assistant;
  late final NotificationsApi notifications;
  late final ReportsApi reports;

  // MARK: - Orders

  late final WorkOrdersApi workOrders;

  // MARK: - References

  late final ReferencesApi references;

  // MARK: - Recommendations

  late final RecommendationsApi recommendations;

  // MARK: - Uploads

  late final UploadsApi uploads;

  // MARK: - Authentication

  /// Вызываем после успешного логина.
  ///
  /// Все API-сервисы используют один ApiClient,
  /// поэтому отдельно передавать JWT каждому сервису
  /// не требуется.
  void setAccessToken(String token) {
    client.setAccessToken(token);
    realtime.setToken(token.trim());
  }

  /// Вызываем при выходе пользователя.
  void clearAccessToken() {
    client.clearAccessToken();
    realtime.setToken(null);
  }

  bool get hasAccessToken {
    final token = client.accessToken;

    return token != null && token.trim().isNotEmpty;
  }

  // MARK: - Lifecycle

  void dispose() {
    realtime.dispose();
    client.dispose();
  }

  // MARK: - Helpers

  static String _normalizeBaseUrl(String value) {
    var normalized = value.trim();

    while (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }

    if (normalized.isEmpty) {
      throw ArgumentError.value(
        value,
        'baseUrl',
        'Base URL не может быть пустым',
      );
    }

    return normalized;
  }
}
