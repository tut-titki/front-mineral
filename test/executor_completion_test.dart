import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/features/executor/screens/completion_screen.dart';
import 'package:mineral/shared/data/demo_store.dart';
import 'package:mineral/shared/models/models.dart';

void main() {
  for (final planned in [true, false]) {
    testWidgets('completion enforces photos for unplanned=$planned', (
      tester,
    ) async {
      final store = DemoStore();
      addTearDown(store.dispose);
      final order = store.assignedTo(1).first;
      order.status = OrderStatus.working;
      order.planned = planned;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompletionScreen(store: store, order: order, employeeId: 1),
          ),
        ),
      );
      await tester.enterText(
        find.byType(TextFormField).first,
        'Заменено уплотнение',
      );
      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(DemoStore.faultCodes.first).last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Отправить на проверку'));
      await tester.tap(find.text('Отправить на проверку'));
      await tester.pumpAndSettle();
      expect(order.status, planned ? OrderStatus.review : OrderStatus.working);
      if (planned) {
        expect(order.completedWork, 'Заменено уплотнение');
        expect(order.history.last.author, store.employee(1).name);
      } else {
        expect(
          find.text('Для внепланового наряда нужно фото после'),
          findsOneWidget,
        );
      }
      expect(tester.takeException(), isNull);
    });
  }
}
