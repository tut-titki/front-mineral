import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/shared/data/demo_store.dart';
import 'package:mineral/shared/models/models.dart';

void main() {
  test('issuance stamps actual time, derives deadline and records history', () {
    var time = DateTime(2026, 10, 5, 10, 15);
    final store = DemoStore(clock: () => time);
    addTearDown(store.dispose);
    store.orders.clear();
    time = time.add(const Duration(minutes: 7));
    final order = store.issueOrder(
      title: 'Ремонт',
      description: 'Течь',
      area: 'Обогащение',
      equipment: 'Насос Н-12',
      employeeId: 1,
      priority: 'Аварийный',
      planned: false,
      normHours: 1.5,
      equipmentStopped: true,
    );
    expect(order.createdAt, time);
    expect(order.deadline, time.add(const Duration(minutes: 90)));
    expect(order.history.single.time, time);
    expect(store.stoppedEquipmentCount, 1);
    time = time.add(const Duration(hours: 1));
    expect(order.createdAt, DateTime(2026, 10, 5, 10, 22));
    store.changeStatus(order, OrderStatus.closed);
    expect(store.stoppedEquipmentCount, 0);
  });

  test('employee colors follow work, queue and off-shift state', () {
    final store = DemoStore();
    addTearDown(store.dispose);
    expect(store.employeeColor(store.employee(1)), const Color(0xFFD97706));
    expect(store.employeeStatus(store.employee(1)), contains('147'));
    expect(store.employeeStatus(store.employee(1)), contains('очередь 1'));
    expect(store.employeeColor(store.employee(3)), const Color(0xFF059669));
    expect(store.employeeColor(store.employee(5)), const Color(0xFF94A3B8));
    store.changeStatus(
      store.orders.firstWhere((o) => o.number == 147),
      OrderStatus.closed,
    );
    expect(store.employeeColor(store.employee(1)), const Color(0xFF2563EB));
  });

  test('brigade assignments affect members and reassignments keep history', () {
    final store = DemoStore();
    addTearDown(store.dispose);
    store.orders.clear();
    final order = store.issueOrder(
      title: 'Ремонт',
      description: 'Течь',
      area: 'Обогащение',
      equipment: 'Насос Н-12',
      brigade: 'Бригада №1',
      priority: 'Обычный',
      planned: false,
      normHours: 2,
    );
    expect(store.assignmentLabel(order), 'Бригада №1');
    expect(store.assignedTo(1), contains(order));
    expect(store.assignedTo(3), contains(order));
    store.reassign(order, 2);
    expect(order.brigade, isNull);
    expect(store.assignedTo(3), isEmpty);
    store.changePriority(order, 'Высокий');
    store.changeStatus(order, OrderStatus.cancelled, reason: 'План изменён');
    expect(order.history, hasLength(4));
    expect(order.history.last.title, contains('План изменён'));
    expect(() => store.reassign(order, 5), throwsArgumentError);
  });
}
