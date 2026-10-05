import 'package:mineral/shared/models/models.dart';

/// Current work first, then actionable assignments, then FIFO queue and review.
class ExecutorOrderQueue {
  ExecutorOrderQueue(Iterable<WorkOrder> orders)
    : orders = List.of(orders)..sort(compare);
  final List<WorkOrder> orders;

  List<WorkOrder> get queued =>
      orders.where((order) => order.status == OrderStatus.queued).toList();
  int? position(WorkOrder order) {
    final index = queued.indexOf(order);
    return index < 0 ? null : index + 1;
  }

  static DateTime queuedAt(WorkOrder order) => order.history
      .where(
        (event) =>
            event.status == OrderStatus.queued ||
            event.title == OrderStatus.queued.label,
      )
      .map((event) => event.time)
      .fold(
        order.createdAt,
        (latest, time) => time.isAfter(latest) ? time : latest,
      );

  static int _group(OrderStatus status) => switch (status) {
    OrderStatus.working => 0,
    OrderStatus.paused => 1,
    OrderStatus.issued || OrderStatus.accepted || OrderStatus.rework => 2,
    OrderStatus.queued => 3,
    _ => 4,
  };

  static int compare(WorkOrder a, WorkOrder b) {
    final group = _group(a.status).compareTo(_group(b.status));
    if (group != 0) return group;
    if (a.status == OrderStatus.queued && b.status == OrderStatus.queued) {
      final time = queuedAt(a).compareTo(queuedAt(b));
      return time != 0 ? time : a.number.compareTo(b.number);
    }
    if (a.emergency != b.emergency) return a.emergency ? -1 : 1;
    final due = a.deadline.compareTo(b.deadline);
    return due != 0 ? due : a.number.compareTo(b.number);
  }
}
