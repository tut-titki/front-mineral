import 'package:mineral/shared/models/models.dart';

class ExecutorOrderDto {
  const ExecutorOrderDto({
    required this.id,
    required this.number,
    required this.description,
    required this.status,
    required this.priority,
    required this.type,
    required this.deadline,
    required this.createdAt,
    required this.area,
    required this.equipment,
    required this.assigneeId,
    required this.comment,
    this.details = const {},
  });

  final Map<String, dynamic> details;
  final int id;
  final String number;
  final String description;
  final String status;
  final String priority;
  final String type;
  final DateTime deadline;
  final DateTime createdAt;
  final String area;
  final String equipment;
  final int? assigneeId;
  final String? comment;

  factory ExecutorOrderDto.fromJson(Map<String, dynamic> json) {
    final area = json['area'] as Map<String, dynamic>?;
    final equipment = json['equipment'] as Map<String, dynamic>?;

    return ExecutorOrderDto(
      details: json,
      id: json['id'] as int,
      number: json['number'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      priority: json['priority'] as String,
      type: json['type'] as String,
      deadline: DateTime.parse(json['deadline'] as String).toUtc(),
      createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
      area: area?['name'] as String? ?? '',
      equipment: equipment?['name'] as String? ?? '',
      assigneeId: json['assigneeId'] as int?,
      comment: json['comment'] as String?,
    );
  }
}

extension ExecutorOrderMapping on ExecutorOrderDto {
  WorkOrder toWorkOrder() {
    final employeeId = assigneeId;
    if (employeeId == null) {
      throw const FormatException("У наряда отсутствует исполнитель");
    }
    final mappedStatus = executorOrderStatus(status);

    final mappedPriority = switch (priority) {
      'EMERGENCY' => 'Аварийный',
      'HIGH' => 'Высокий',
      'NORMAL' => 'Обычный',
      'PLANNED' => 'Плановый',
      _ => throw FormatException('Неизвестный приоритет: $priority'),
    };
    return WorkOrder(
      apiId: id,
      apiNumber: number,
      detailsLoaded: details.containsKey('events'),
      number: id,
      title: description,
      description: description,
      area: area,
      equipment: equipment,
      employeeId: employeeId,
      priority: mappedPriority,
      status: mappedStatus,
      planned: type == "PLANNED",
      deadline: deadline.toLocal(),
      createdAt: createdAt.toLocal(),
      comment: comment ?? '',
    );
  }
}

OrderStatus executorOrderStatus(String status) => switch (status) {
  'ISSUED' => OrderStatus.issued,
  'ACCEPTED' => OrderStatus.accepted,
  'QUEUED' => OrderStatus.queued,
  'IN_PROGRESS' => OrderStatus.working,
  'PAUSED' => OrderStatus.paused,
  'COMPLETED' || 'AI_REVIEW' => OrderStatus.review,
  'REWORK' => OrderStatus.rework,
  'CLOSED' => OrderStatus.closed,
  'REJECTED' => OrderStatus.rejected,
  'CANCELLED' => OrderStatus.cancelled,
  _ => throw FormatException('Неизвестный статус: $status'),
};
