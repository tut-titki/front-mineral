import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/features/executor/screens/executor_order_screen.dart';
import 'package:mineral/shared/data/demo_store.dart';
import 'package:mineral/shared/models/models.dart';

void main() {
  testWidgets('executor accepts, starts and pauses with a required reason', (
    tester,
  ) async {
    final store = DemoStore();
    final order = store.assignedTo(1).first;
    order.status = OrderStatus.issued;
    addTearDown(store.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ExecutorOrderScreen(store: store, order: order, employeeId: 1),
      ),
    );
    await tester.ensureVisible(find.text('Принять в работу'));
    await tester.tap(find.text('Принять в работу'));
    await tester.pumpAndSettle();
    expect(order.status, OrderStatus.accepted);
    await tester.ensureVisible(find.text('Начать исполнение'));
    await tester.tap(find.text('Начать исполнение'));
    await tester.pumpAndSettle();
    expect(order.history.last.author, store.employee(1).name);
    await tester.ensureVisible(find.text('Приостановить'));
    await tester.tap(find.text('Приостановить'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Подтвердить'));
    await tester.pump();
    expect(find.text('Укажите причину'), findsOneWidget);
    expect(order.status, OrderStatus.working);
    await tester.enterText(find.byType(TextFormField), 'Жду запчасти');
    await tester.tap(find.text('Подтвердить'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 350));
    expect(order.status, OrderStatus.paused);
    expect(order.history.last.reason, 'Жду запчасти');
  });
}
