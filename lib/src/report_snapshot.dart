import 'package:flutter/material.dart';

import 'demo_store.dart';
import 'models.dart';

class ReportSnapshot {
  ReportSnapshot(DemoStore store, DateTimeRange? period) {
    final start = period == null
        ? null
        : DateTime(period.start.year, period.start.month, period.start.day);
    final end = period == null
        ? null
        : DateTime(period.end.year, period.end.month, period.end.day + 1);
    orders = store.orders
        .where(
          (order) =>
              (start == null || !order.createdAt.isBefore(start)) &&
              (end == null || order.createdAt.isBefore(end)),
        )
        .toList();
    ranking =
        store.employees
            .where(
              (employee) => store.assignedTo(employee.id).any(orders.contains),
            )
            .toList()
          ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  late final List<WorkOrder> orders;
  late final List<Employee> ranking;
}
