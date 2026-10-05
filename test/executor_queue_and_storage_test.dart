import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/features/executor/data/execution_draft_storage_io.dart';
import 'package:mineral/features/executor/data/executor_repository.dart';
import 'package:mineral/features/executor/models/executor_order_queue.dart';
import 'package:mineral/shared/data/demo_store.dart';
import 'package:mineral/shared/models/models.dart';

void main() {
  test(
    'FIFO queue uses enqueue time regardless of urgency and deadline',
    () async {
      var now = DateTime(2026, 10, 5, 10);
      final store = DemoStore(clock: () => now);
      addTearDown(store.dispose);
      final first = store.assignedTo(1).first;
      final second = store.assignedTo(1)[1];
      first.status = second.status = OrderStatus.issued;
      await store.executorAction(1, first, OrderStatus.queued);
      now = now.add(const Duration(minutes: 1));
      await store.executorAction(1, second, OrderStatus.queued);
      second.deadline = now.subtract(const Duration(hours: 1));
      second.priority = 'Аварийный';
      final queue = ExecutorOrderQueue([second, first]);
      expect(queue.queued, [first, second]);
      expect(queue.position(first), 1);
      expect(queue.position(second), 2);
      await store.executorAction(1, first, OrderStatus.working);
      expect(ExecutorOrderQueue([second, first]).orders.first, first);
      await expectLater(
        store.executorAction(1, second, OrderStatus.working),
        throwsStateError,
      );
      await store.executorAction(
        1,
        first,
        OrderStatus.paused,
        reason: 'Waiting',
      );
      await store.executorAction(1, second, OrderStatus.working);
      expect(second.status, OrderStatus.working);
    },
  );

  group('persistent drafts', () {
    late Directory directory;
    setUp(() async {
      directory = await Directory.systemTemp.createTemp('mineral_drafts_test_');
    });
    tearDown(() async {
      // Only delete the unique directory created by this test under system temp.
      expect(
        directory.absolute.path.startsWith(Directory.systemTemp.absolute.path),
        isTrue,
      );
      expect(
        directory.path
            .split(Platform.pathSeparator)
            .last
            .startsWith('mineral_drafts_test_'),
        isTrue,
      );
      await directory.delete(recursive: true);
    });
    FileExecutionDraftStorage storage() =>
        FileExecutionDraftStorage(directory: () async => directory);

    test(
      'restores work, materials and photos in a new store; clears after report',
      () async {
        final first = DemoStore(draftStorage: storage());
        final number = first.assignedTo(1).first.number;
        final draft = ExecutionDraft(
          work: 'Repair complete',
          faultCode: first.executorFaultCodes.first,
          comment: 'Checked',
          materials: {first.executorMaterials.first: 2},
          photos: [
            OrderPhoto(name: 'after.jpg', bytes: Uint8List.fromList([1, 2, 3])),
          ],
        );
        await first.saveExecutionDraft(1, number, draft);
        first.dispose();
        final restored = DemoStore(draftStorage: storage());
        addTearDown(restored.dispose);
        final loaded = (await restored.restoreExecutionDraft(1, number))!;
        expect(loaded.work, draft.work);
        expect(loaded.comment, draft.comment);
        expect(loaded.materials, draft.materials);
        expect(loaded.photos.single.bytes, [1, 2, 3]);
        expect(await restored.restoreExecutionDraft(2, number), isNull);
        await restored.submitExecution(1, restored.assignedTo(1).first, loaded);
        expect(await storage().load(1, number), isNull);
      },
    );

    test(
      'serial writes replace existing snapshots; removal cannot resurrect them',
      () async {
        final local = storage();
        await Future.wait([
          local.save(1, 147, ExecutionDraft(work: 'first')),
          local.save(1, 147, ExecutionDraft(work: 'latest')),
        ]);
        expect((await storage().load(1, 147))!.work, 'latest');
        await Future.wait([
          local.save(1, 147, ExecutionDraft(work: 'last')),
          local.remove(1, 147),
        ]);
        expect(await storage().load(1, 147), isNull);
      },
    );

    test(
      'corrupt draft is reported and never overwritten during restore',
      () async {
        final folder = await Directory(
          '${directory.path}/execution_drafts',
        ).create();
        final file = File('${folder.path}/1_147.json');
        await file.writeAsString('{broken');
        final store = DemoStore(draftStorage: storage());
        addTearDown(store.dispose);
        await expectLater(
          store.restoreExecutionDraft(1, 147),
          throwsFormatException,
        );
        expect(await file.readAsString(), '{broken');
      },
    );
  });
}
