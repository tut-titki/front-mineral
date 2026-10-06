import '../models/pending_action.dart';

abstract interface class PendingActionStorage {
  Future<List<PendingAction>> load();

  Future<void> add(PendingAction action);

  Future<void> remove(String id);
}
