import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mineral/core/services/push_payload.dart';
import 'package:mineral/features/auth/data/auth_session.dart';

void main() {
  late AuthSession session;
  late MemoryTokenStorage storage;
  late List<http.Request> requests;
  late Future<http.Response> Function(http.Request) handle;
  const token = 'fcm-token-with-at-least-20-characters:/+';
  setUp(() async {
    storage = MemoryTokenStorage();
    await storage.write('jwt');
    requests = [];
    handle = (request) async => http.Response(
      jsonEncode(
        request.url.path == '/api/auth/me'
            ? {
                'id': 5,
                'fullName': 'Worker',
                'role': 'EXECUTOR',
                'language': 'ru',
              }
            : {'deleted': 1},
      ),
      200,
      headers: {'content-type': 'application/json'},
    );
    session = AuthSession(
      storage: storage,
      client: MockClient((r) async {
        requests.add(r);
        return handle(r);
      }),
    );
    await session.restore();
    requests.clear();
  });
  tearDown(() => session.dispose());

  test(
    'register uses documented body; rotation and logout detach before JWT removal',
    () async {
      await session.registerPushDevice(token, 'android');
      expect(jsonDecode(requests.single.body), {
        'token': token,
        'platform': 'android',
      });
      expect(requests.single.method, 'POST');
      expect(requests.single.url.path, '/api/devices');
      expect(requests.single.headers['Authorization'], 'Bearer jwt');
      final rotated = '${token}new';
      await session.registerPushDevice(rotated, 'android');
      expect(requests.map((r) => r.method), ['POST', 'DELETE', 'POST']);
      expect(requests[1].url.pathSegments.last, token);
      final previous = handle;
      handle = (r) async {
        expect(await storage.read(), 'jwt');
        return previous(r);
      };
      await session.logout();
      expect(requests.last.url.pathSegments.last, rotated);
      expect(session.authenticated, isFalse);
      expect(await storage.read(), isNull);
    },
  );

  test('invalid device token and platform never reach API', () async {
    await expectLater(
      session.registerPushDevice('short', 'android'),
      throwsArgumentError,
    );
    await expectLater(
      session.registerPushDevice(token, 'windows'),
      throwsArgumentError,
    );
    expect(requests, isEmpty);
  });

  test('logout removes local session even if token detachment fails', () async {
    await session.registerPushDevice(token, 'android');
    handle = (_) async => http.Response('{"error":"Unavailable"}', 503);
    await expectLater(session.logout(), throwsA(isA<ApiException>()));
    expect(await storage.read(), isNull);
    expect(session.authenticated, isFalse);
    expect(session.pushToken, isNull);
  });

  test('logout waits for in-flight registration then detaches it', () async {
    final started = Completer<void>();
    final finish = Completer<void>();
    handle = (r) async {
      if (r.method == 'POST') {
        started.complete();
        await finish.future;
      }
      return http.Response('{}', 200);
    };
    final registration = session.registerPushDevice(token, 'android');
    await started.future;
    final logout = session.logout();
    expect(requests.map((r) => r.method), ['POST']);
    finish.complete();
    await registration;
    await logout;
    expect(requests.map((r) => r.method), ['POST', 'DELETE']);
    expect(session.authenticated, isFalse);
  });

  test(
    'only a new emergency order selects the alarm channel; IDs are validated',
    () {
      final emergency = PushPayload({
        'type': 'NEW_ORDER',
        'priority': 'EMERGENCY',
        'workOrderId': '76',
      });
      expect(emergency.channelId, 'emergency_orders');
      expect(emergency.category, 'EMERGENCY_ORDER');
      expect(emergency.workOrderId, 76);
      final ordinary = PushPayload({
        'type': 'OVERDUE',
        'priority': 'EMERGENCY',
        'workOrderId': 76,
      });
      expect(ordinary.channelId, 'orders');
      expect(ordinary.category, 'ORDER');
      expect(ordinary.workOrderId, 76);
      for (final value in [null, 'bad', 0, -1, 1.5]) {
        expect(PushPayload({'workOrderId': value}).workOrderId, isNull);
      }
    },
  );
}
