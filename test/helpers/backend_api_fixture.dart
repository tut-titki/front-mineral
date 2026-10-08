import 'package:mineral/features/references/data/reference_storage_stub.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mineral/core/api/api_services.dart';

/// HTTP fixtures are restricted to tests; production never reads these values.
ApiServices testApi({Future<http.Response?> Function(http.Request)? handle}) {
  final api = ApiServices(
    baseUrl: 'https://backend.test',
    referenceStorage: MemoryReferenceStorage(),
    httpClient: MockClient((request) async {
      final response = await handle?.call(request);
      if (response != null) return response;
      if (request.url.path == '/api/work-orders/board') {
        return jsonResponse(boardJson());
      }
      if (request.url.path == '/api/analytics/dashboard') {
        return jsonResponse({
          'active': 0,
          'overdue': 0,
          'equipmentInDowntime': 0,
          'averageReactionMinutes': null,
          'averageCompletionMinutes': null,
          'topEquipment': [],
          'topExecutors': [],
        });
      }
      if (request.url.path.startsWith('/api/work-orders/')) {
        return jsonResponse(orderJson());
      }
      return jsonResponse([]);
    }),
  );
  // Avoid opening a real socket in widget tests.
  api.client.setAccessToken('test-token');
  return api;
}

http.Response jsonResponse(Object? data, {int status = 200}) => http.Response(
  jsonEncode(data),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

Map<String, dynamic> boardJson({
  List<Map<String, dynamic>> issued = const [],
  List<Map<String, dynamic>> inProgress = const [],
}) => {
  'since': DateTime.now()
      .subtract(const Duration(hours: 12))
      .toUtc()
      .toIso8601String(),
  'counters': {
    'issued': issued.length,
    'completed': 0,
    'overdue': 0,
    'equipmentInDowntime': 0,
  },
  'columns': {
    'issued': issued,
    'accepted': [],
    'inProgress': inProgress,
    'queued': [],
    'completed': [],
    'overdue': [],
  },
};

Map<String, dynamic> orderJson({
  int id = 773,
  String status = 'ISSUED',
  DateTime? createdAt,
}) {
  final created = createdAt ?? DateTime.now();
  return {
    'id': id,
    'number': 'N-$id',
    'type': 'PLANNED',
    'description': 'Test maintenance $id',
    'priority': 'NORMAL',
    'deadline': DateTime.now()
        .add(const Duration(days: 1))
        .toUtc()
        .toIso8601String(),
    'status': status,
    'createdAt': created.toUtc().toIso8601String(),
    'updatedAt': created.toUtc().toIso8601String(),
    'areaId': 1,
    'equipmentId': 2,
    'creatorId': 5,
    'assigneeId': 7,
    'area': {'id': 1, 'name': 'Area'},
    'equipment': {
      'id': 2,
      'name': 'Equipment',
      'inventoryNumber': 'INV-2',
      'areaId': 1,
    },
    'assignee': {
      'id': 7,
      'fullName': 'Test Executor',
      'specialty': 'Specialty',
    },
    'photos': [],
    'materialUsages': [],
    'events': [],
  };
}

Map<String, dynamic> executorJson() => {
  'id': 7,
  'fullName': 'Test Executor',
  'specialty': 'Specialty',
  'grade': 5,
  'employeeStatus': 'AVAILABLE',
  'isOnShift': true,
  '_count': {'assignedOrders': 3},
};

ApiServices createFormApi({void Function(Map<String, dynamic>)? onCreate}) =>
    testApi(
      handle: (request) async {
        switch (request.url.path) {
          case '/api/references/areas':
            return jsonResponse([
              {'id': 1, 'name': 'Area'},
            ]);
          case '/api/references/equipment':
            return jsonResponse([
              {'id': 2, 'name': 'Equipment', 'areaId': 1},
            ]);
          case '/api/references/executors':
            return jsonResponse([executorJson()]);
          case '/api/references/brigades':
            return jsonResponse([{'id': 1, 'name': 'Brigade A', 'members': [{'id': 7, 'fullName': 'Test Executor', 'specialty': 'Specialty'}]}]);
          case '/api/references/normatives':
            return jsonResponse([
              {'id': 3, 'name': 'Normative', 'hours': '2'},
            ]);
          case '/api/recommendations/executors':
            return jsonResponse([
              {
                'id': 7,
                'fullName': 'Test Executor',
                'employeeStatus': 'AVAILABLE',
                'queue': 0,
                'score': 80,
              },
            ]);
          case '/api/uploads':
            return jsonResponse({
              'url': '/uploads/photo?exp=123&sig=test',
              'originalName': 'test.png',
              'size': 100,
            });
          case '/api/work-orders':
            if (request.method == 'POST') {
              onCreate?.call(
                Map<String, dynamic>.from(jsonDecode(request.body) as Map),
              );
              return jsonResponse(orderJson());
            }
        }
        return null;
      },
    );
