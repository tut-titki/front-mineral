import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mineral/core/api/api_client.dart';
import 'package:mineral/features/assistant/data/assistant_api.dart';
import 'package:mineral/app/app.dart';
import 'package:mineral/features/auth/data/auth_session.dart' as auth;
import 'package:mineral/features/references/data/reference_storage_stub.dart';
import 'package:mineral/features/orders/screens/order_detail_screen.dart';
import 'package:mineral/l10n/app_localizations.dart';
import 'helpers/backend_api_fixture.dart';
import 'support/pin_test_helpers.dart';

void main() {
  testWidgets(
    '409 on cancellation refreshes the card and removes stale actions',
    (tester) async {
      var reads = 0;
      final api = testApi(
        handle: (request) async {
          if (request.url.path == '/api/work-orders/773/action') {
            return jsonResponse({'error': 'Наряд уже закрыт'}, status: 409);
          }
          if (request.url.path == '/api/work-orders/773') {
            reads++;
            return jsonResponse(
              orderJson(status: reads == 1 ? 'IN_PROGRESS' : 'CLOSED'),
            );
          }
          return null;
        },
      );
      addTearDown(api.dispose);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ru'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: OrderDetailScreen(api: api, orderId: 773),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.widgetWithText(TextButton, 'Отменить наряд'),
      );
      await tester.tap(find.widgetWithText(TextButton, 'Отменить наряд'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Отменить наряд'));
      await tester.pumpAndSettle();
      expect(reads, greaterThan(1));
      expect(find.widgetWithText(TextButton, 'Отменить наряд'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('expired master API session removes protected routes and token', (
    tester,
  ) async {
    final storage = auth.MemoryTokenStorage();
    await storage.write('master-token');
    final session = auth.AuthSession(
      storage: storage,
      client: MockClient((request) async {
        return request.url.path == '/api/auth/me'
            ? jsonResponse({
                'id': 1,
                'fullName': 'Мастер',
                'role': 'MASTER',
                'language': 'ru',
                'isOnShift': true,
              })
            : jsonResponse([]);
      }),
    );
    final api = testApi(
      handle: (request) async => request.url.path == '/api/expired'
          ? jsonResponse({'error': 'Сессия завершена'}, status: 401)
          : null,
    );
    await tester.pumpWidget(
      MainApp(
        session: session,
        apiServices: api,
        referenceStorage: MemoryReferenceStorage(),
        pinRepository: testPinRepository(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('Создайте ПИН-код'), findsOneWidget);
    await enterPin(tester, '1234');
    await enterPin(tester, '1234');
    expect(session.authenticated, isTrue);
    await expectLater(
      api.client.get('/api/expired'),
      throwsA(isA<ApiException>()),
    );
    await tester.pumpAndSettle();
    expect(session.authenticated, isFalse);
    expect(await storage.read(), isNull);
    expect(find.text('Вход'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    session.dispose();
  });

  test(
    'every protected master API request reports an expired session',
    () async {
      final expired = <String>[];
      final client = ApiClient(
        baseUrl: 'https://backend.test',
        httpClient: MockClient(
          (_) async => jsonResponse({'error': 'Сессия завершена'}, status: 401),
        ),
      )..setAccessToken('master-token');
      client.onUnauthorized = expired.add;
      addTearDown(client.dispose);
      final requests = <Future<Object?> Function()>[
        () => client.get('/api/work-orders'),
        () => client.post('/api/work-orders', body: {}),
        () => client.patch('/api/work-orders/1', body: {}),
        () => client.delete('/api/devices/device'),
        () => client.getBytes('/api/reports/export.pdf'),
        () => client.sendMultipart(
          http.MultipartRequest(
            'POST',
            Uri.parse('https://backend.test/api/ai/transcribe'),
          ),
        ),
      ];
      for (final request in requests) {
        await expectLater(
          request(),
          throwsA(
            isA<ApiException>().having(
              (error) => error.statusCode,
              'status',
              401,
            ),
          ),
        );
      }
      expect(expired, List.filled(requests.length, 'master-token'));
    },
  );

  test('late 401 from an old token cannot expire the new session', () async {
    final response = Completer<http.Response>();
    final sent = Completer<void>();
    final expired = <String>[];
    final client = ApiClient(
      baseUrl: 'https://backend.test',
      httpClient: MockClient((_) {
        sent.complete();
        return response.future;
      }),
    )..setAccessToken('old-token');
    client.onUnauthorized = expired.add;
    addTearDown(client.dispose);
    final pending = client.get('/api/work-orders');
    final expectation = expectLater(pending, throwsA(isA<ApiException>()));
    await sent.future;
    client.setAccessToken('new-token');
    response.complete(jsonResponse({'error': 'expired'}, status: 401));
    await expectation;
    expect(expired, isEmpty);
    expect(client.accessToken, 'new-token');
  });

  test(
    'login rejection and validation errors do not expire the master session',
    () async {
      final expired = <String>[];
      final client = ApiClient(
        baseUrl: 'https://backend.test',
        httpClient: MockClient(
          (request) async => jsonResponse({
            'error': 'Ошибка',
          }, status: request.url.path.endsWith('login') ? 401 : 400),
        ),
      )..setAccessToken('master-token');
      client.onUnauthorized = expired.add;
      addTearDown(client.dispose);
      await expectLater(
        client.post('/api/auth/login', authenticated: false),
        throwsA(isA<ApiException>()),
      );
      await expectLater(
        client.post('/api/work-orders', body: {}),
        throwsA(isA<ApiException>()),
      );
      expect(expired, isEmpty);
    },
  );

  test('assistant accepts the documented structured intent', () async {
    final api = testApi(
      handle: (_) async => jsonResponse({
        'answer': 'Свободен электрик',
        'intent': {'intent': 'FREE_EXECUTORS', 'specialty': 'Электрик'},
        'data': [
          {'id': 4, 'fullName': 'Исполнитель 1'},
        ],
      }),
    );
    addTearDown(api.dispose);
    final reply = await api.assistant.chat('Кто свободен?');
    expect(reply.intent, 'FREE_EXECUTORS');
    expect(reply.answer, 'Свободен электрик');
    expect(reply.data, isA<List>());
    expect(
      AssistantReply.fromJson({'answer': 'Ответ', 'intent': null}).intent,
      isNull,
    );
  });

  test(
    'master photo upload preserves signed URL and sends UTC capture time',
    () async {
      final capturedAt = DateTime.parse('2026-10-08T12:00:00+05:00');
      final api = testApi(
        handle: (request) async {
          expect(request.url.path, '/api/uploads');
          expect(request.headers['Authorization'], 'Bearer test-token');
          final body = latin1.decode(request.bodyBytes);
          expect(body, contains('name="takenAt"'));
          expect(body, contains('2026-10-08T07:00:00.000Z'));
          expect(body, contains('name="file"'));
          return jsonResponse({
            'url': '/uploads/photo?exp=123&sig=test',
            'size': 3,
            'originalName': 'photo.jpg',
          }, status: 201);
        },
      );
      addTearDown(api.dispose);
      final photo = await api.uploads.uploadPhoto(
        bytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'photo.jpg',
        takenAt: capturedAt,
      );
      expect(photo.url, '/uploads/photo?exp=123&sig=test');
    },
  );
}
