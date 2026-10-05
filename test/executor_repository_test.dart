import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/features/executor/data/executor_repository.dart';
import 'package:mineral/shared/data/demo_store.dart';
import 'package:mineral/shared/models/models.dart';

void main() {
  late DemoStore store;
  setUp(() => store = DemoStore());
  tearDown(() => store.dispose());

  test(
    'invalid transitions and missing reasons leave order unchanged',
    () async {
      final order = store.assignedTo(1).first;
      order.status = OrderStatus.issued;
      await expectLater(
        store.executorAction(1, order, OrderStatus.working),
        throwsStateError,
      );
      await expectLater(
        store.executorAction(1, order, OrderStatus.rejected),
        throwsArgumentError,
      );
      expect(order.status, OrderStatus.issued);
    },
  );

  test(
    'draft is isolated by employee and cleared after successful report',
    () async {
      final order = store.assignedTo(1).first;
      order.status = OrderStatus.working;
      order.planned = true;
      final draft = ExecutionDraft(
        work: 'Repair completed',
        faultCode: store.executorFaultCodes.first,
        materials: {store.executorMaterials.first: 2},
      );
      store.saveExecutionDraft(1, order.number, draft);
      expect(store.executionDraft(2, order.number), isNull);
      expect(store.executionDraft(1, order.number), same(draft));
      await store.submitExecution(1, order, draft);
      expect(order.status, OrderStatus.review);
      expect(order.completedWork, draft.work);
      expect(store.executionDraft(1, order.number), isNull);
      await expectLater(
        store.submitExecution(1, order, draft),
        throwsStateError,
      );
    },
  );

  test('invalid quantities do not submit or discard draft', () async {
    final order = store.assignedTo(1).first;
    order.status = OrderStatus.working;
    order.planned = true;
    final draft = ExecutionDraft(
      work: 'Repair completed',
      faultCode: store.executorFaultCodes.first,
      materials: {store.executorMaterials.first: double.nan},
    );
    store.saveExecutionDraft(1, order.number, draft);
    await expectLater(
      store.submitExecution(1, order, draft),
      throwsArgumentError,
    );
    expect(order.status, OrderStatus.working);
    expect(store.executionDraft(1, order.number), same(draft));
  });
}
