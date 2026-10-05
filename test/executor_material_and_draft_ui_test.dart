import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/features/executor/data/execution_draft_storage.dart';
import 'package:mineral/features/executor/data/executor_repository.dart';
import 'package:mineral/features/executor/screens/completion_screen.dart';
import 'package:mineral/features/executor/widgets/executor_material_tile.dart';
import 'package:mineral/shared/data/demo_store.dart';

class _Storage implements ExecutionDraftStorage {
  bool failLoad = false;
  bool failSave = false;
  int writes = 0;
  ExecutionDraft? draft;
  @override
  Future<ExecutionDraft?> load(int employeeId, int orderNumber) async {
    if (failLoad) throw StateError('disk');
    return draft;
  }

  @override
  Future<void> save(
    int employeeId,
    int orderNumber,
    ExecutionDraft value,
  ) async {
    if (failSave) throw StateError('disk');
    writes++;
    draft = value;
  }

  @override
  Future<void> remove(int employeeId, int orderNumber) async {
    draft = null;
  }
}

void main() {
  testWidgets(
    'large quantity buttons, integer validation and confirmed removal',
    (tester) async {
      var quantity = 2.0;
      var removed = false;
      tester.view.physicalSize = const Size(320, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => ExecutorMaterialTile(
                name: 'Подшипник · шт',
                quantity: quantity,
                onChanged: (value) => setState(() => quantity = value),
                onRemove: () => setState(() => removed = true),
              ),
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byTooltip('Увеличить')).width, 60);
      expect(tester.getSize(find.byTooltip('Увеличить')).height, 60);
      await tester.tap(find.byTooltip('Уменьшить'));
      await tester.pump();
      expect(quantity, 1);
      expect(removed, isFalse);
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '0,5');
      await tester.tap(find.text('Подтвердить'));
      await tester.pump();
      expect(
        find.text('Для штучного материала укажите целое количество'),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextFormField), '3');
      await tester.tap(find.text('Подтвердить'));
      await tester.pumpAndSettle();
      expect(quantity, 3);
      await tester.tap(find.byTooltip('Удалить материал'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();
      expect(removed, isFalse);
      await tester.tap(find.byTooltip('Удалить материал'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Удалить материал'));
      await tester.pumpAndSettle();
      expect(removed, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('corrupt draft shows retry without overwriting it', (
    tester,
  ) async {
    final local = _Storage()..failLoad = true;
    final store = DemoStore(draftStorage: local);
    addTearDown(store.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: CompletionScreen(
          store: store,
          order: store.assignedTo(1).first,
          employeeId: 1,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Не удалось восстановить черновик'),
      findsOneWidget,
    );
    expect(local.writes, 0);
    local.failLoad = false;
    local.draft = ExecutionDraft(work: 'Recovered');
    await tester.tap(find.text('Повторить'));
    await tester.pumpAndSettle();
    expect(find.text('Recovered'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('autosave keeps edits and retries failed writes', (tester) async {
    final local = _Storage();
    final store = DemoStore(draftStorage: local);
    addTearDown(store.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: CompletionScreen(
          store: store,
          order: store.assignedTo(1).first,
          employeeId: 1,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Repaired');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    expect(local.draft!.work, 'Repaired');
    local.failSave = true;
    await tester.enterText(find.byType(TextFormField).first, 'Final report');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    expect(local.draft!.work, 'Repaired');
    expect(
      find.text('Черновик не сохранён. Нажмите, чтобы повторить.'),
      findsOneWidget,
    );
    local.failSave = false;
    await tester.tap(
      find.text('Черновик не сохранён. Нажмите, чтобы повторить.'),
    );
    await tester.pump();
    expect(local.draft!.work, 'Final report');
    await tester.pumpWidget(const SizedBox());
  });
}
