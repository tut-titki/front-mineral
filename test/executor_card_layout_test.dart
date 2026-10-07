import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/features/executor/widgets/executor_history_tile.dart';
import 'package:mineral/shared/data/demo_store.dart';
import 'package:mineral/shared/models/models.dart';

void main() {
  for (final width in [320.0, 390.0]) {
    testWidgets('home completed number reaches right inset at $width', (
      tester,
    ) async {
      final store = DemoStore();
      addTearDown(store.dispose);
      final order = store.assignedTo(1).first;
      order.status = OrderStatus.closed;
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ExecutorHistoryTile(
                    compact: true,
                    order: order,
                    now: store.now,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      final card = tester.getRect(find.byType(ExecutorHistoryTile));
      final number = tester.getRect(find.text('Наряд №${order.displayNumber}'));
      expect(card.right - number.right, closeTo(8, 0.5));
      expect(tester.takeException(), isNull);
    });
  }
}
