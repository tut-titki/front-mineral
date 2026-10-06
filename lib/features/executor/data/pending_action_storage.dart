import '../models/pending_action.dart';
import 'pending_action_storage_stub.dart'
    if (dart.library.io) 'pending_action_storage_io.dart'
    as platform;

PendingActionStorage createPendingActionStorage(int employeeId) =>
    platform.createStorage(employeeId);

class MemoryPendingActionStorage implements PendingActionStorage {
  final List<PendingAction> actions = [];
  @override
  Future<List<PendingAction>> load() async => List.of(actions);
  @override
  Future<void> add(PendingAction action) async {
    final index = actions.indexWhere((a) => a.id == action.id);
    if (index < 0) {
      actions.add(action);
    } else {
      actions[index] = action;
    }
  }

  @override
  Future<void> remove(String id) async =>
      actions.removeWhere((a) => a.id == id);
}

abstract interface class PendingActionStorage {
  Future<List<PendingAction>> load();

  Future<void> add(PendingAction action);

  Future<void> remove(String id);
}
