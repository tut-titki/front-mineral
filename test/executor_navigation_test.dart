import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mineral/core/theme/app_theme.dart';
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
      MaterialApp(
        theme: buildAppTheme(),
        home: ExecutorScreen(store: store, employeeId: 1),
      ),
    );
    await tester.tap(find.text('История'));
    await tester.pumpAndSettle();
    expect(find.text('История нарядов'), findsOneWidget);
    await tester.tap(find.text('Наряд №${order.number}'));
    await tester.pumpAndSettle();
    expect(find.byType(ExecutorResultScreen), findsOneWidget);
    final resultTitle = find.descendant(
      of: find.byType(AppBar),
      matching: find.byType(Text),
    );
    final paragraph = tester.renderObject<RenderParagraph>(resultTitle);
    expect(paragraph.text.style!.fontSize, 20);
    expect(paragraph.text.style!.fontWeight, FontWeight.w700);
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
