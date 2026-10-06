import 'package:mineral/shared/models/models.dart';

Set<String> availableExecutorActions(WorkOrder order, int employeeId) {
  if (order.accessErrorStatus != null || order.employeeId != employeeId) {
    return const {};
  }

  return switch (order.status) {
    OrderStatus.issued => const {'ACCEPT', 'QUEUE', 'REJECT'},
    OrderStatus.queued => const {'ACCEPT', 'START'},
    OrderStatus.accepted || OrderStatus.rework => const {'START'},
    OrderStatus.working => const {'PAUSE', 'COMPLETE'},
    OrderStatus.paused => const {'RESUME'},
    _ => const {},
  };
}
