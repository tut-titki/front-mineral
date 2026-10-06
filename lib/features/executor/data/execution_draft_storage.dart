import 'executor_repository.dart';
import 'execution_draft_storage_stub.dart'
    if (dart.library.io) 'execution_draft_storage_io.dart'
    as platform;

abstract interface class ExecutionDraftStorage {
  Future<ExecutionDraft?> load(int employeeId, int orderNumber);
  Future<void> save(int employeeId, int orderNumber, ExecutionDraft draft);
  Future<void> remove(int employeeId, int orderNumber);
}

ExecutionDraftStorage createExecutionDraftStorage({
  String folderName = 'execution_drafts',
}) => platform.createStorage(folderName: folderName);
