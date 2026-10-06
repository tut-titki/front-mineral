import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/pending_action.dart';
import 'pending_action_storage.dart';

PendingActionStorage createStorage(int employeeId) =>
    FilePendingActionStorage(employeeId);

class FilePendingActionStorage implements PendingActionStorage {
  FilePendingActionStorage(
    this.employeeId, {
    Future<Directory> Function()? directory,
  }) : _directory = directory ?? getApplicationSupportDirectory;
  final int employeeId;
  final Future<Directory> Function() _directory;
  Future<void> _pending = Future.value();
  Future<T> _serial<T>(Future<T> Function() operation) {
    final result = _pending.then((_) => operation());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<File> _file() async {
    final root = await _directory();
    final folder = Directory('${root.path}/executor_action_queue');
    await folder.create(recursive: true);
    return File('${folder.path}/$employeeId.json');
  }

  Future<List<PendingAction>> _read(File file) async {
    if (!await file.exists()) return [];
    return (jsonDecode(await file.readAsString()) as List)
        .map((a) => PendingAction.fromJson(Map<String, dynamic>.from(a as Map)))
        .toList();
  }

  Future<void> _write(File file, List<PendingAction> actions) async {
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(
      jsonEncode(actions.map((a) => a.toJson()).toList()),
      flush: true,
    );
    await temporary.rename(file.path);
  }

  @override
  Future<List<PendingAction>> load() =>
      _serial(() async => _read(await _file()));
  @override
  Future<void> add(PendingAction action) => _serial(() async {
    if (action.employeeId != employeeId) {
      throw StateError('Queue owner mismatch');
    }
    final file = await _file();
    final actions = await _read(file);
    final index = actions.indexWhere((a) => a.id == action.id);
    if (index < 0) {
      actions.add(action);
    } else {
      actions[index] = action;
    }
    await _write(file, actions);
  });
  @override
  Future<void> remove(String id) => _serial(() async {
    final file = await _file();
    final actions = await _read(file);
    actions.removeWhere((a) => a.id == id);
    await _write(file, actions);
  });
}
