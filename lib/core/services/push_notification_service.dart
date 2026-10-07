import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mineral/features/auth/data/auth_session.dart';
import 'push_payload.dart';

@pragma('vm:entry-point')
Future<void> firebasePushBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Notification payloads are displayed by Android/iOS, without a duplicate.
}

class PushNotificationService {
  PushNotificationService({required this.session, required this.onOrderTap});
  final AuthSession session;
  final void Function(int) onOrderTap;
  final _local = FlutterLocalNotificationsPlugin();
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  FirebaseMessaging? _messaging;
  Timer? _retry;
  String? _deviceToken;
  String? _registeredFor;
  Future<void>? _registration;
  bool _disposed = false;

  Future<void> initialize() async {
    if (kIsWeb ||
        !{
          TargetPlatform.android,
          TargetPlatform.iOS,
        }.contains(defaultTargetPlatform)) {
      return;
    }
    try {
      await _local.initialize(
        settings: InitializationSettings(
          android: const AndroidInitializationSettings('ic_notification'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestSoundPermission: false,
            requestBadgePermission: false,
            notificationCategories: [
              DarwinNotificationCategory('EMERGENCY_ORDER'),
              DarwinNotificationCategory('ORDER'),
            ],
          ),
        ),
        onDidReceiveNotificationResponse: (response) {
          final value = response.payload;
          if (value != null) {
            _tap(Map<String, dynamic>.from(jsonDecode(value) as Map));
          }
        },
      );
      final android = _local
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          'emergency_orders',
          'Аварийные наряды',
          importance: Importance.max,
          sound: RawResourceAndroidNotificationSound('emergency_order'),
          playSound: true,
          enableVibration: true,
          description: 'Новые аварийные наряды, требующие ответа',
        ),
      );
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          'orders',
          'Наряды',
          importance: Importance.high,
          playSound: true,
        ),
      );
      await Firebase.initializeApp();
      if (_disposed) return;
      FirebaseMessaging.onBackgroundMessage(firebasePushBackgroundHandler);
      _messaging = FirebaseMessaging.instance;
      await _messaging!.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: false,
        sound: false,
      );
      session.addListener(_sessionChanged);
      _subscriptions.add(
        FirebaseMessaging.onMessage.listen((message) {
          unawaited(_show(message).catchError(_logError));
        }),
      );
      _subscriptions.add(
        FirebaseMessaging.onMessageOpenedApp.listen(
          (message) => _tap(message.data),
        ),
      );
      _subscriptions.add(
        _messaging!.onTokenRefresh.listen((token) {
          _deviceToken = token;
          _sessionChanged();
        }),
      );
      _retry = Timer.periodic(
        const Duration(seconds: 30),
        (_) => _sessionChanged(),
      );
      final initial = await _messaging!.getInitialMessage();
      if (_disposed) return;
      if (initial != null) _tap(initial.data);
      final localLaunch = await _local.getNotificationAppLaunchDetails();
      final payload = localLaunch?.notificationResponse?.payload;
      if (localLaunch?.didNotificationLaunchApp == true && payload != null) {
        _tap(Map<String, dynamic>.from(jsonDecode(payload) as Map));
      }
      _sessionChanged();
    } catch (error) {
      debugPrint('Push unavailable; check Firebase configuration: $error');
    }
  }

  void _sessionChanged() {
    if (_disposed) return;
    if (!session.authenticated) {
      _registeredFor = null;
      return;
    }
    _registration ??= _register()
        .catchError(_logError)
        .whenComplete(() => _registration = null);
  }

  Future<void> _register() async {
    final messaging = _messaging;
    if (messaging == null) return;
    final userId = session.user?.id;
    if (_deviceToken == null) {
      final permission = await messaging.requestPermission();
      if (permission.authorizationStatus != AuthorizationStatus.authorized &&
          permission.authorizationStatus != AuthorizationStatus.provisional) {
        return;
      }
      _deviceToken = await messaging.getToken();
    }
    final token = _deviceToken;
    if (_disposed ||
        token == null ||
        !session.authenticated ||
        userId != session.user?.id) {
      return;
    }
    final key = '$userId:$token';
    if (_registeredFor == key) return;
    await session.registerPushDevice(
      token,
      defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
    );
    if (!_disposed &&
        session.authenticated &&
        session.user?.id == userId &&
        _deviceToken == token) {
      _registeredFor = key;
    }
  }

  void _tap(Map<String, dynamic> data) {
    if (_disposed) return;
    final id = PushPayload(data).workOrderId;
    if (id != null) onOrderTap(id);
  }

  Future<void> _show(RemoteMessage message) async {
    if (_disposed || !session.authenticated || message.notification == null) {
      return;
    }
    final payload = PushPayload(message.data);
    await _local.show(
      id:
          message.messageId?.hashCode.abs() ??
          DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
      title: message.notification!.title,
      body: message.notification!.body,
      payload: jsonEncode(message.data),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          payload.channelId,
          payload.emergency ? 'Аварийные наряды' : 'Наряды',
          icon: 'ic_notification',
          importance: payload.emergency ? Importance.max : Importance.high,
          priority: payload.emergency ? Priority.max : Priority.high,
          sound: payload.emergency
              ? const RawResourceAndroidNotificationSound('emergency_order')
              : null,
        ),
        iOS: DarwinNotificationDetails(
          categoryIdentifier: payload.category,
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
        ),
      ),
    );
  }

  void _logError(Object error) => debugPrint('Push operation failed: $error');
  void dispose() {
    _disposed = true;
    session.removeListener(_sessionChanged);
    _retry?.cancel();
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
  }
}
