import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mineral/core/api/api_client.dart';
import 'package:mineral/features/orders/data/references_api.dart';
import 'package:mineral/features/references/data/reference_cache.dart';
import 'package:mineral/features/references/data/reference_storage_io.dart';
import 'package:mineral/features/references/data/reference_storage_stub.dart';

void main() {
  test(
    'device cache survives restart and offline; authentication is not hidden',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'mineral_references_',
      );
      addTearDown(() => directory.delete(recursive: true));
      final storage = FileReferenceStorage(directory: () async => directory);
      var count = 0;
      final cache = ReferenceCache(
        scope: 'company|5',
        storage: storage,
        fetch: (_) async {
          count++;
          return [
            {'id': 1, 'name': 'Material', 'unit': 'шт'},
          ];
        },
      );
      final first = await cache.get('materials');
      first.first['name'] = 'changed';
      expect((await cache.get('materials')).first['name'], 'Material');
      expect(count, 1);
      final offline = ReferenceCache(
        scope: 'company|5',
        storage: storage,
        fetch: (_) async => throw http.ClientException('offline'),
      );
      expect((await offline.get('materials')).first['id'], 1);
      final denied = ReferenceCache(
        scope: 'company|5',
        storage: storage,
        fetch: (_) async =>
            throw const ApiException(statusCode: 401, message: 'Expired'),
      );
      await expectLater(denied.get('materials'), throwsA(isA<ApiException>()));
      offline.setScope('company|6');
      await expectLater(
        offline.get('materials'),
        throwsA(isA<http.ClientException>()),
      );
    },
  );
  test(
    'login refreshes all seven references; filtered cache and live executors remain fresh',
    () async {
      final paths = <String>[];
      var revision = 1;
      final cache = ReferenceCache(
        scope: 'company|5',
        storage: MemoryReferenceStorage(),
        fetch: (path) async {
          paths.add(path);
          return [
            {'id': revision, 'name': path},
          ];
        },
      );
      await Future.wait([cache.get('materials'), cache.get('materials')]);
      expect(paths.length, 1);
      await cache.get('equipment?areaId=1');
      revision = 2;
      await cache.refreshAll();
      expect(
        paths.toSet().containsAll([
          '/api/references/areas',
          '/api/references/equipment',
          '/api/references/fault-codes',
          '/api/references/materials',
          '/api/references/brigades',
          '/api/references/normatives',
          '/api/references/executors',
        ]),
        isTrue,
      );
      expect((await cache.get('equipment?areaId=1')).first['id'], 2);
      await cache.get('executors');
      revision = 3;
      expect((await cache.get('executors')).first['id'], 3);
    },
  );
  test(
    'late request from a previous user cannot populate a new session',
    () async {
      final response = Completer<List<Map<String, dynamic>>>();
      final cache = ReferenceCache(
        scope: 'company|5',
        storage: MemoryReferenceStorage(),
        fetch: (_) => response.future,
      );
      final pending = cache.get('areas');
      await Future<void>.delayed(Duration.zero);
      cache.setScope('company|6');
      response.complete([
        {'id': 1},
      ]);
      await expectLater(pending, throwsStateError);
    },
  );
  test(
    'executor filters, nullable fields, statusText and decimal norms follow contract',
    () async {
      Uri? requested;
      final client = ApiClient(
        baseUrl: 'https://test.example',
        httpClient: MockClient((request) async {
          requested = request.url;
          return http.Response(
            jsonEncode([
              {
                'id': 5,
                'fullName': 'Исполнитель',
                'specialty': 'Сварщик',
                'grade': 5,
                'brigadeId': 3,
                'brigade': {'id': 3, 'name': 'Бригада'},
                'employeeStatus': 'BUSY',
                'isOnShift': true,
                'statusText': 'выполняет наряд №Н-00147, в очереди 1',
                'currentOrder': {
                  'id': 773,
                  'number': 'Н-00147',
                  'status': 'IN_PROGRESS',
                  'priority': 'NORMAL',
                  'deadline': '2026-10-05T17:35:16.419Z',
                  'equipment': {'name': 'Насос'},
                },
                'queue': 1,
                'activeOrders': 2,
                '_count': {'assignedOrders': 3},
              },
            ]),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );
      addTearDown(client.dispose);
      client.setAccessToken('jwt');
      final api = ReferencesApi(client, storage: MemoryReferenceStorage());
      final item = (await api.getExecutors(
        specialty: 'Сварщик',
        brigadeId: 3,
        onShift: true,
      )).single;
      expect(requested!.queryParameters, {
        'specialty': 'Сварщик',
        'brigadeId': '3',
        'onShift': '1',
      });
      expect(item.statusLabel, 'выполняет наряд №Н-00147, в очереди 1');
      expect(item.currentOrder!.id, 773);
      expect(item.currentOrder!.deadline.isUtc, isTrue);
      expect(item.brigade!.id, 3);
      expect(item.queue, 1);
      expect(item.activeOrders, 2);
      final nullable = ExecutorReference.fromJson({
        'id': 6,
        'fullName': 'Другой',
        'employeeStatus': 'OFF_SHIFT',
        'isOnShift': false,
        'brigadeId': null,
        'brigade': null,
        'specialty': null,
        'grade': null,
        'currentOrder': null,
        'statusText': null,
      });
      expect(nullable.currentOrder, isNull);
      expect(nullable.brigade, isNull);
      final normative = NormativeReference.fromJson({
        'id': 1,
        'name': 'Ремонт',
        'hours': '1.5',
        'materialNorms': [
          {'materialId': 1, 'quantity': '2.25', 'material': null},
        ],
      });
      expect(normative.hoursValue, 1.5);
      expect(normative.materialNorms.single.quantityValue, 2.25);
    },
  );
}
