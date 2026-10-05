import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/shared/data/demo_store.dart';
import 'package:mineral/shared/models/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'order notifications cover changes, without seed, duplicates or failures',
    () {
      final events = <OrderEventKind>[];
      final store = DemoStore(onOrderChanged: events.add);
      addTearDown(store.dispose);
      expect(store.orders, isNotEmpty);
      expect(events, isEmpty);
      final order = store.issueOrder(
        title: 'Ремонт',
        description: 'Течь',
        area: 'Обогащение',
        equipment: 'Насос Н-12',
        employeeId: 3,
        priority: 'Обычный',
        planned: false,
        normHours: 2,
      );
      store.changeStatus(order, OrderStatus.accepted);
      store.changeStatus(order, OrderStatus.accepted);
      store.reassign(order, 2);
      store.reassign(order, 2);
      expect(() => store.reassign(order, 5), throwsArgumentError);
      store.reassignBrigade(order, 'Бригада №1');
      store.reassignBrigade(order, 'Бригада №1');
      store.changePriority(order, 'Высокий');
      store.changePriority(order, 'Высокий');
      store.setMasterScore(order, 4.5);
      store.setMasterScore(order, 4.5);
      store.changeStatus(order, OrderStatus.cancelled, reason: 'Отмена');
      expect(events, [
        OrderEventKind.issued,
        OrderEventKind.status,
        OrderEventKind.reassigned,
        OrderEventKind.reassigned,
        OrderEventKind.priority,
        OrderEventKind.score,
        OrderEventKind.status,
      ]);
      expect(order.history.length, events.length);
    },
  );

  test('notification WAV files are included in the asset bundle', () async {
    for (final name in ['order_created', 'order_changed']) {
      final bytes = await rootBundle.load('assets/$name.wav');
      expect(String.fromCharCodes(bytes.buffer.asUint8List(0, 4)), 'RIFF');
      expect(bytes.lengthInBytes, greaterThan(1000));
    }
  });
}
