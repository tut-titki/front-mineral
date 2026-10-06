import 'package:mineral/features/executor/screens/executor_order_screen.dart';
import 'package:mineral/features/executor/screens/executor_order_loader.dart';
import 'package:mineral/features/executor/models/executor_order_actions.dart';
import 'package:flutter/material.dart';
import 'package:mineral/features/executor/screens/executor_screen.dart';
import 'package:mineral/l10n/app_localizations.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mineral/features/auth/data/auth_session.dart';
import 'package:mineral/features/executor/data/api_executor_repository.dart';
import 'package:mineral/features/executor/data/executor_api.dart';
import 'package:mineral/features/executor/data/executor_repository.dart';
import 'package:mineral/features/executor/data/execution_draft_storage_io.dart';
import 'package:mineral/shared/models/models.dart';

const user = {
  'id': 5,
  'fullName': 'Worker',
  'role': 'EXECUTOR',
  'language': 'ru',
};
Map<String, dynamic> order(int id, String status, {bool full = false}) => {
  'id': id,
  'number': 'H-00$id',
  'description': 'Repair',
  'status': status,
  'priority': 'EMERGENCY',
  'type': 'PLANNED',
  'assigneeId': 5,
  'deadline': '2026-10-07T10:00:00Z',
  'createdAt': '2026-10-06T09:00:00Z',
  'updatedAt': '2026-10-06T10:00:00Z',
  'comment': null,
  'area': {'name': 'Area'},
  'equipment': {'name': 'Pump'},
  if (full) ...{
    'completionText': 'Completed',
    'faultCode': {'id': 11, 'code': 'P-12', 'name': 'Seal'},
    'normative': {'hours': '1.5'},
    'materialUsages': [
      {
        'materialId': 23,
        'quantity': '1.5',
        'material': {'name': 'Seal', 'unit': 'pcs'},
      },
    ],
    'photos': [],
    'events': [
      {
        'action': 'START',
        'toStatus': 'IN_PROGRESS',
        'createdAt': '2026-10-06T09:00:00Z',
        'actor': {'fullName': 'Worker'},
        'comment': null,
      },
      {
        'action': 'PAUSE',
        'toStatus': 'PAUSED',
        'createdAt': '2026-10-06T09:20:00Z',
        'actor': {'fullName': 'Worker'},
        'comment': 'Break',
      },
      {
        'action': 'RESUME',
        'toStatus': 'IN_PROGRESS',
        'createdAt': '2026-10-06T09:40:00Z',
        'actor': {'fullName': 'Worker'},
        'comment': null,
      },
    ],
  },
};
http.Response json(Object value, [int status = 200]) => http.Response(
  jsonEncode(value),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);
void main() {
  late Directory directory;
  late AuthSession session;
  late ApiExecutorRepository repository;
  late FileExecutionDraftStorage drafts;
  late List<http.Request> requests;
  late Future<http.Response> Function(http.Request) handler;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('executor_api_test');
    drafts = FileExecutionDraftStorage(directory: () async => directory);
    requests = [];
    handler = (request) async {
      final path = request.url.path;
      if (path.endsWith('/auth/me')) return json(user);
      if (path.endsWith('/fault-codes')) {
        return json([
          {'id': 11, 'code': 'P-12', 'name': 'Seal'},
        ]);
      }
      if (path.endsWith('/materials')) {
        return json([
          {'id': 23, 'name': 'Seal', 'unit': 'pcs'},
        ]);
      }
      if (path == '/api/work-orders') {
        return json([
          order(
            request.url.queryParameters['status']!.startsWith('ISSUED')
                ? 76
                : 77,
            request.url.queryParameters['status']!.startsWith('ISSUED')
                ? 'IN_PROGRESS'
                : 'CLOSED',
          ),
        ]);
      }
      if (path == '/api/work-orders/76') {
        return json(order(76, 'IN_PROGRESS', full: true));
      }
      if (path.endsWith('/action')) {
        return json({'order': order(76, 'AI_REVIEW', full: true)});
      }
      if (path == '/api/uploads') {
        return json({'url': '/uploads/photo.jpg?signed=yes'}, 201);
      }
      throw StateError('Unexpected request: $path');
    };
    final storage = MemoryTokenStorage();
    await storage.write('jwt');
    session = AuthSession(
      storage: storage,
      client: MockClient((request) {
        requests.add(request);
        return handler(request);
      }),
    );
    await session.restore();
    repository = ApiExecutorRepository(
      api: ExecutorApi(session),
      draftStorage: drafts,
    );
  });
  tearDown(() async {
    repository.dispose();
    session.dispose();
    await directory.delete(recursive: true);
  });
  test(
    'active and archive stay separate; failed refresh preserves both',
    () async {
      await repository.refreshExecutor(5);
      expect(repository.activeOrders.single.displayNumber, 'H-0076');
      expect(repository.historyOrders.single.displayNumber, 'H-0077');
      expect(repository.activeOrders.single.emergency, isTrue);
      final previous = handler;
      handler = (r) async =>
          r.url.queryParameters['status']?.contains('CLOSED') == true
          ? json({'error': 'Failed'}, 500)
          : await previous(r);
      await expectLater(
        repository.refreshExecutor(5),
        throwsA(isA<ApiException>()),
      );
      expect(repository.activeOrders.single.number, 76);
      expect(repository.historyOrders.single.number, 77);
    },
  );
  test(
    'detail loads before use; decimal strings and pause-aware clock map correctly',
    () async {
      await repository.refreshExecutor(5);
      final compact = repository.activeOrders.single;
      final loaded = await repository.loadExecutorOrder(5, compact);
      expect(loaded, same(compact));
      expect(loaded.detailsLoaded, isTrue);
      expect(loaded.normHours, 1.5);
      expect(loaded.materials, 'Seal · pcs: 1.5');
      expect(
        loaded.workDuration(DateTime.parse('2026-10-06T10:00:00Z')),
        const Duration(minutes: 40),
      );
      expect(requests.last.url.path, '/api/work-orders/76');
    },
  );
  test(
    'pause uses server ID, UUID and comment; errors never change status',
    () async {
      await repository.refreshExecutor(5);
      final work = repository.activeOrders.single;
      final previous = handler;
      final bodies = <Map>[];
      var attempts = 0;
      handler = (r) async {
        if (!r.url.path.endsWith('/action')) return previous(r);
        bodies.add(jsonDecode(r.body) as Map);
        attempts++;
        return attempts == 1
            ? json({'error': 'Failed'}, 500)
            : json({'order': order(76, 'PAUSED')});
      };
      await expectLater(
        repository.executorAction(
          5,
          work,
          OrderStatus.paused,
          reason: ' Break ',
        ),
        throwsA(isA<ApiException>()),
      );
      expect(work.status, OrderStatus.working);
      await repository.executorAction(
        5,
        work,
        OrderStatus.paused,
        reason: ' Break ',
      );
      expect(bodies.first['action'], 'PAUSE');
      expect(bodies.first['comment'], 'Break');
      expect(bodies.first['clientActionId'], bodies.last['clientActionId']);
      expect(work.status, OrderStatus.paused);
    },
  );
  test(
    'failed COMPLETE keeps disk draft; retry reuses uploaded photo and action ID',
    () async {
      await repository.refreshExecutor(5);
      final work = repository.activeOrders.single;
      final report = ExecutionDraft(
        work: 'Repair done',
        faultCode: repository.executorFaultCodes.single,
        materials: {repository.executorMaterials.single: 1.5},
        photos: [
          OrderPhoto(name: 'after.jpg', bytes: Uint8List.fromList([1, 2, 3])),
        ],
      );
      final previous = handler;
      final bodies = <Map>[];
      var attempts = 0;
      handler = (r) async {
        if (!r.url.path.endsWith('/action')) return previous(r);
        bodies.add(jsonDecode(r.body) as Map);
        attempts++;
        return attempts == 1
            ? json({'error': 'Report rejected'}, 500)
            : previous(r);
      };
      await expectLater(
        repository.submitExecution(5, work, report),
        throwsA(isA<ApiException>()),
      );
      expect(
        (await FileExecutionDraftStorage(
          directory: () async => directory,
        ).load(5, 76))!.work,
        'Repair done',
      );
      expect(work.status, OrderStatus.working);
      await repository.submitExecution(5, work, report);
      expect(bodies.last['faultCodeId'], 11);
      expect((bodies.last['materials'] as List).single, {
        'materialId': 23,
        'quantity': 1.5,
      });
      expect(bodies.last['afterPhotoUrls'], ['/uploads/photo.jpg?signed=yes']);
      expect(bodies.first['clientActionId'], bodies.last['clientActionId']);
      final uploads = requests
          .where((r) => r.url.path == '/api/uploads')
          .toList();
      expect(uploads.length, 1);
      expect(uploads.single.headers['Authorization'], 'Bearer jwt');
      expect(
        uploads.single.headers['content-type'],
        startsWith('multipart/form-data'),
      );
      expect(await drafts.load(5, 76), isNull);
      expect(repository.activeOrders.single.status, OrderStatus.review);
      expect(
        repository.historyOrders.map((o) => o.number),
        isNot(contains(76)),
      );
    },
  );
  test('pagination collects active orders and history independently', () async {
    final previous = handler;
    handler = (r) async {
      if (r.url.path != '/api/work-orders') return previous(r);
      final active = r.url.queryParameters['status']!.startsWith('ISSUED');
      final offset = int.parse(r.url.queryParameters['offset']!);
      if (!active) return json([order(999, 'CLOSED')]);
      return json(
        offset == 0
            ? List.generate(200, (i) => order(i + 1, 'ISSUED'))
            : [order(201, 'QUEUED')],
      );
    };
    await repository.refreshExecutor(5);
    expect(repository.activeOrders.length, 201);
    expect(repository.historyOrders.single.number, 999);
    expect(
      requests.where((r) => r.url.queryParameters['offset'] == '200').length,
      1,
    );
  });
  test('409 refreshes detail; 404 removes inaccessible order', () async {
    await repository.refreshExecutor(5);
    final work = repository.activeOrders.single;
    final previous = handler;
    handler = (r) async {
      if (r.url.path.endsWith('/action')) {
        return json({'error': 'Status changed'}, 409);
      }
      if (r.url.path == '/api/work-orders/76') {
        return json(order(76, 'PAUSED', full: true));
      }
      return previous(r);
    };
    await expectLater(
      repository.executorAction(5, work, OrderStatus.paused, reason: 'Break'),
      throwsA(isA<ApiException>()),
    );
    expect(work.status, OrderStatus.paused);
    handler = (r) async => json({'error': 'Not found'}, 404);
    await expectLater(
      repository.loadExecutorOrder(5, work),
      throwsA(isA<ApiException>()),
    );
    expect(repository.activeOrders, isEmpty);
  });
  test(
    'null values stay unfilled; explicit zero stays zero; removed norm clears',
    () async {
      await repository.refreshExecutor(5);
      final work = repository.activeOrders.single;
      final previous = handler;
      var empty = false;
      handler = (r) async {
        if (r.url.path != '/api/work-orders/76') return previous(r);
        return json({
          ...order(76, 'IN_PROGRESS', full: true),
          'normative': empty ? null : {'hours': '1.5'},
          'actualDowntimeMinutes': empty ? null : 0,
          'aiAssessment': empty
              ? null
              : {'verdict': 'ACCEPTED', 'score': '0', 'masterScore': null},
        });
      };
      await repository.loadExecutorOrder(5, work);
      expect(work.normHours, 1.5);
      expect(work.aiScore, 0);
      expect(work.downtimeMinutes, 0);
      empty = true;
      await repository.loadExecutorOrder(5, work);
      expect(work.normHours, isNull);
      expect(work.aiScore, isNull);
      expect(work.finalScore, isNull);
      expect(work.assessment, isNull);
      expect(work.downtimeMinutes, isNull);
      expect(repository.employee(5).grade, isNull);
      expect(AuthUser.fromJson({...user, 'grade': 0}).grade, 0);
    },
  );
  testWidgets('refresh preserves Russian server error in Kazakh interface', (
    tester,
  ) async {
    await repository.refreshExecutor(5);
    handler = (r) async => json({'error': 'Сервер временно недоступен'}, 503);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('kk'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ExecutorScreen(store: repository, employeeId: 5),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Сервер временно недоступен'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  for (final code in [403, 404]) {
    test('action $code removes order and prevents repeated requests', () async {
      await repository.refreshExecutor(5);
      final work = repository.activeOrders.single;
      handler = (r) async => json({'error': 'Недоступный наряд'}, code);
      await expectLater(
        repository.executorAction(5, work, OrderStatus.paused, reason: 'Break'),
        throwsA(isA<ApiException>()),
      );
      expect(repository.activeOrders, isEmpty);
      expect(work.accessErrorStatus, code);
      expect(availableExecutorActions(work, 5), isEmpty);
      final count = requests.length;
      await expectLater(
        repository.executorAction(5, work, OrderStatus.paused, reason: 'Break'),
        throwsA(isA<ApiException>()),
      );
      expect(requests.length, count);
    });
  }
  test('failed detail refresh after 409 blocks stale action buttons', () async {
    await repository.refreshExecutor(5);
    final work = repository.activeOrders.single;
    final previous = handler;
    handler = (r) async => r.url.path.endsWith('/action')
        ? json({'error': 'Статус изменился'}, 409)
        : json({'error': 'Нет связи'}, 503);
    await expectLater(
      repository.executorAction(5, work, OrderStatus.paused, reason: 'Break'),
      throwsA(isA<ApiException>()),
    );
    expect(availableExecutorActions(work, 5), isEmpty);
    handler = previous;
    await repository.loadExecutorOrder(5, work);
    expect(work.accessErrorStatus, isNull);
    expect(availableExecutorActions(work, 5), contains('PAUSE'));
  });
  testWidgets(
    '400 keeps reason sheet open, preserves text and permits correction',
    (tester) async {
      await repository.refreshExecutor(5);
      final work = repository.activeOrders.single;
      final previous = handler;
      var attempt = 0;
      handler = (r) async {
        if (!r.url.path.endsWith('/action')) return previous(r);
        if (++attempt == 1) {
          return json({
            'error': 'Уточните причину',
            'details': [
              {
                'path': ['comment'],
                'message': 'Опишите причину подробнее',
              },
            ],
          }, 400);
        }
        return json({'order': order(76, 'PAUSED', full: true)});
      };
      await tester.pumpWidget(
        MaterialApp(
          home: ExecutorOrderScreen(
            store: repository,
            order: work,
            employeeId: 5,
          ),
        ),
      );
      await tester.tap(find.text('Приостановить'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Жду');
      await tester.tap(find.text('Подтвердить'));
      await tester.pumpAndSettle();
      expect(find.text('Опишите причину подробнее'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller!
            .text,
        'Жду',
      );
      expect(work.status, OrderStatus.working);
      await tester.enterText(
        find.byType(TextFormField),
        'Жду запчасти со склада',
      );
      await tester.tap(find.text('Подтвердить'));
      await tester.pumpAndSettle();
      expect(find.byType(TextFormField), findsNothing);
      expect(work.status, OrderStatus.paused);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets('404 loader shows server error and removes retry button', (
    tester,
  ) async {
    await repository.refreshExecutor(5);
    final work = repository.activeOrders.single;
    handler = (r) async => json({'error': 'Наряд не найден'}, 404);
    await tester.pumpWidget(
      MaterialApp(
        home: ExecutorOrderLoader(
          store: repository,
          order: work,
          employeeId: 5,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Наряд не найден'), findsOneWidget);
    expect(find.text('Повторить'), findsNothing);
    expect(find.text('Назад'), findsOneWidget);
    expect(repository.activeOrders, isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  test('protected 401 expires session; image 401 does not', () async {
    final previous = handler;
    handler = (r) async => r.url.path == '/uploads/old.jpg'
        ? json({'error': 'Expired image'}, 401)
        : await previous(r);
    await expectLater(
      session.downloadPhoto('/uploads/old.jpg'),
      throwsA(isA<ApiException>()),
    );
    expect(session.authenticated, isTrue);
    handler = (r) async => json({'error': 'Expired token'}, 401);
    await expectLater(
      repository.refreshExecutor(5),
      throwsA(isA<ApiException>()),
    );
    expect(session.authenticated, isFalse);
  });
}
