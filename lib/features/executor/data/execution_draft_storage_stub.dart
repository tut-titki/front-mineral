import 'execution_draft_storage.dart';
import 'executor_repository.dart';

// Native phones use files. Web remains an explicitly in-memory demo.
ExecutionDraftStorage createStorage({String folderName = 'execution_drafts'}) =>
    _MemoryDraftStorage();

class _MemoryDraftStorage implements ExecutionDraftStorage {
  final _drafts = <(int, int), ExecutionDraft>{};
  @override
  Future<ExecutionDraft?> load(int employeeId, int orderNumber) async =>
      _drafts[(employeeId, orderNumber)];
  @override
  Future<void> save(
    int employeeId,
    int orderNumber,
    ExecutionDraft draft,
  ) async {
    _drafts[(employeeId, orderNumber)] = draft;
  }

  @override
  Future<void> remove(int employeeId, int orderNumber) async {
    _drafts.remove((employeeId, orderNumber));
  }
}
