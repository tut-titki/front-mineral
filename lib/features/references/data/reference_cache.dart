import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'reference_storage.dart';

class ReferenceCache {
  ReferenceCache({
    required this.fetch,
    required String scope,
    ReferenceStorage? storage,
  }) : _scope = scope,
       _storage = storage ?? createReferenceStorage();
  final Future<List<Map<String, dynamic>>> Function(String path) fetch;
  final ReferenceStorage _storage;
  String _scope;
  final _fresh = <String>{};
  final _memory = <String, List<Map<String, dynamic>>>{};
  final _pending = <String, Future<List<Map<String, dynamic>>>>{};
  void setScope(String scope) {
    if (scope == _scope) return;
    _scope = scope;
    _memory.clear();
    _fresh.clear();
    _pending.clear();
  }

  Future<List<Map<String, dynamic>>> get(
    String name, {
    bool refresh = false,
  }) async {
    final key = '$_scope|$name';
    final result = await (_pending[key] ??= _load(name, key, refresh)
        .whenComplete(() {
          _pending.remove(key);
        }));
    if (key != '$_scope|$name') throw StateError('Reference session changed');
    // Callers cannot mutate the cached JSON, including nested values.
    return (jsonDecode(jsonEncode(result)) as List)
        .cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> _load(
    String name,
    String key,
    bool refresh,
  ) async {
    var cached = _memory[key];
    if (cached == null) {
      try {
        cached = await _storage.read(key);
      } catch (_) {
        /* Invalid cache is refetched. */
      }
      if (cached != null) _memory[key] = cached;
    }
    if (!refresh &&
        !name.startsWith('executors') &&
        cached != null &&
        _fresh.contains(key)) {
      return cached;
    }
    try {
      final items = await fetch('/api/references/$name');
      if (key != '$_scope|$name') throw StateError('Reference session changed');
      _memory[key] = items;
      _fresh.add(key);
      try {
        await _storage.write(key, items);
      } catch (_) {
        /* Network data remains usable. */
      }
      return items;
    } catch (error) {
      if (key != '$_scope|$name') throw StateError('Reference session changed');
      // Authentication, permissions and validation errors must never be hidden.
      if (cached != null &&
          (error is http.ClientException || error is TimeoutException)) {
        return cached;
      }
      rethrow;
    }
  }

  Future<void> refreshAll() async {
    _fresh.clear();
    final results = await Future.wait([
      for (final name in [
        'areas',
        'equipment',
        'fault-codes',
        'materials',
        'brigades',
        'normatives',
        'executors',
      ])
        get(
          name,
          refresh: true,
        ).then<Object?>((_) => null, onError: (Object error) => error),
    ]);
    final failure = results.whereType<Object>().firstOrNull;
    if (failure != null) throw failure;
  }
}
