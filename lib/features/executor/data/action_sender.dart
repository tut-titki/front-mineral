import '../models/pending_action.dart';

enum SendResult { accepted, retryLater, needsReview }

abstract interface class ActionSender {
  Future<SendResult> send(PendingAction action);
}
