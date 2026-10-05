import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/features/executor/widgets/work_timer.dart';
import 'package:mineral/features/executor/screens/executor_order_screen.dart';
import 'package:mineral/features/executor/screens/completion_screen.dart';
import 'package:mineral/shared/data/demo_store.dart';
import 'package:mineral/shared/models/models.dart';

void main() {
  testWidgets('timer excludes pauses and resumes', (tester) async {
    var now = DateTime(2026, 10, 5, 10);
    final store = DemoStore(clock: () => now);
    addTearDown(store.dispose);
    final order = store.assignedTo(1).first;
    order.history.clear();
    order.status = OrderStatus.accepted;
    store.changeStatus(order, OrderStatus.working);
    now = now.add(const Duration(minutes: 10));
    store.changeStatus(order, OrderStatus.paused);
    now = now.add(const Duration(minutes: 20));
    expect(order.workDuration(now), const Duration(minutes: 10));
    store.changeStatus(order, OrderStatus.working);
    now = now.add(const Duration(minutes: 5));
    await tester.pumpWidget(
      MaterialApp(
        home: WorkTimer(order: order, store: store),
      ),
    );
    expect(find.text('00:15:00'), findsOneWidget);
    now = now.add(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('00:15:01'), findsOneWidget);
    store.changeStatus(order, OrderStatus.review);
    now = now.add(const Duration(hours: 1));
    expect(order.workDuration(now), const Duration(minutes: 15, seconds: 1));
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('completion is a route with back navigation', (tester) async {
    final store = DemoStore();
    addTearDown(store.dispose);
    final order = store.assignedTo(1).first;
    order.status = OrderStatus.working;
    await tester.pumpWidget(
      MaterialApp(
        home: ExecutorOrderScreen(store: store, order: order, employeeId: 1),
      ),
    );
    await tester.tap(find.text('Исполнено'));
    await tester.pumpAndSettle();
    expect(find.byType(CompletionScreen), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(CompletionScreen), findsNothing);
    expect(find.text('Исполнено'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
