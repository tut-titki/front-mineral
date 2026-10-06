import 'pending_action_storage.dart';

PendingActionStorage createStorage(int employeeId) =>
    MemoryPendingActionStorage();
