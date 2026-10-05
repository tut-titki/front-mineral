import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/features/executor/screens/executor_screen.dart';
import 'package:mineral/features/executor/screens/executor_result_screen.dart';
import 'package:mineral/shared/data/demo_store.dart';
import 'package:mineral/shared/models/models.dart';

void main() {
  testWidgets('tabs separate history and open result with back navigation', (
    tester,
  ) async {
    final store = DemoStore();
    addTearDown(store.dispose);
    final order = store.assignedTo(1).first;
    order.status = OrderStatus.closed;
    await tester.pumpWidget(
      MaterialApp(home: ExecutorScreen(store: store, employeeId: 1)),
    );
    await tester.tap(find.text('История'));
    await tester.pumpAndSettle();
    expect(find.text('История нарядов'), findsOneWidget);
    await tester.tap(find.text('Наряд №${order.number}'));
    await tester.pumpAndSettle();
    expect(find.byType(ExecutorResultScreen), findsOneWidget);
    expect(find.text('Оценка мастера пока не выставлена'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('История нарядов'), findsOneWidget);
    await tester.tap(find.text('Профиль').last);
    await tester.pumpAndSettle();
    expect(find.text('Мой рейтинг'), findsOneWidget);
    await tester.tap(find.text('Наряды').last);
    await tester.pumpAndSettle();
    expect(find.text('Мои наряды'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
