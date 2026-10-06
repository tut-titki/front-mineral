import 'action_sender.dart';
import 'pending_action_storage.dart';
import '../models/pending_action.dart';

class OfflineActionQueue {
  final PendingActionStorage storage;
  final ActionSender sender;
  final void Function(PendingAction action) onConflict;

  OfflineActionQueue({
    required this.storage,
    required this.sender,
    required this.onConflict,
  });

  bool _syncing = false;

  Future<void> enqueue(PendingAction action) async {
    await storage.add(action);
  }

  Future<void> sync() async {
    if (_syncing) return;
    _syncing = true;

    try {
      final actions = await storage.load();
      for (final action in actions) {
        SendResult result;
        try {
          result = await sender.send(action);
        } catch (_) {
          break;
        }

        if (result == SendResult.accepted) {
          await storage.remove(action.id);
        } else if (result == SendResult.needsReview) {
          onConflict(action);
          break;
        } else {
          break;
        }
      }
    } finally {
      _syncing = false;
    }
  }
}
