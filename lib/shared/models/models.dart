import 'dart:typed_data';
import 'package:mineral/features/executor/models/execution_assessment.dart';

import 'package:flutter/material.dart';
import 'package:mineral/core/theme/app_theme.dart';

enum OrderStatus {
  issued('Выдан', AppColors.primary),
  accepted('Принят', Color(0xFF0284C7)),
  working('В работе', Color(0xFFD97706)),
  queued('В очереди', Color(0xFF2563EB)),
  paused('Приостановлен', Color(0xFF64748B)),
  review('На проверке', AppColors.info),
  rework('На доработке', Color(0xFFEA580C)),
  closed('Закрыт', Color(0xFF059669)),
  rejected('Отклонён', Color(0xFFDC2626)),
  cancelled('Отменён', Color(0xFF94A3B8));

  const OrderStatus(this.label, this.color);

  final String label;
  final Color color;
}

class Employee {
  const Employee({
    required this.id,
    required this.name,
    required this.specialty,
    required this.grade,
    required this.brigade,
    required this.rating,
    this.onShift = true,
  });

  final int id;
  final String name;
  final String specialty;
  final int grade;
  final String brigade;
  final double rating;
  final bool onShift;

  String get initials {
    return name.split(' ').take(2).map((part) => part[0]).join();
  }
}

enum OrderEventKind { issued, status, reassigned, priority, score, deadline }

class OrderEvent {
  const OrderEvent({
    required this.title,
    required this.author,
    required this.time,
    this.kind,
    this.value,
    this.status,
    this.reason = '',
  });

  final String title;
  final String author;
  final DateTime time;
  final OrderEventKind? kind;
  final String? value;
  final OrderStatus? status;
  final String reason;
}

class OrderPhoto {
  const OrderPhoto({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

class WorkOrder {
  WorkOrder({
    required this.number,
    required this.title,
    required this.description,
    required this.area,
    required this.equipment,
    required this.employeeId,
    required this.priority,
    required this.deadline,
    required this.createdAt,
    this.apiId,
    this.apiNumber,
    this.apiStatus,
    this.detailsLoaded = true,
    this.finishedAt,
    this.planned = false,
    this.status = OrderStatus.issued,
    this.comment = '',
    this.beforePhotos = 0,
    this.afterPhotos = 0,
    this.completedWork = '',
    this.faultCode = '',
    this.materials = '',
    this.aiScore = 4.8,
    this.masterScore,
    this.assessment,
    this.aiVerdict = 'Нет заключения',
    this.aiExplanation = 'ИИ пока не подключён.',
    this.downtimeMinutes = 0,
    this.brigade,
    this.normHours,
    this.equipmentStopped = false,
    List<OrderPhoto>? beforeImages,
    List<OrderPhoto>? afterImages,
    List<OrderEvent>? history,
  }) : beforeImages = List.of(beforeImages ?? []),
       afterImages = List.of(afterImages ?? []),
       history = history ?? [];

  final int number;
  final DateTime createdAt;
  final int? apiId;
  final String? apiNumber;
  String? apiStatus;
  bool detailsLoaded;
  DateTime? finishedAt;
  String title;
  String description;
  String area;
  String equipment;
  int employeeId;
  String priority;
  DateTime deadline;
  bool planned;
  OrderStatus status;
  String comment;
  int beforePhotos;
  int afterPhotos;
  final List<OrderPhoto> beforeImages;
  final List<OrderPhoto> afterImages;

  String completedWork;
  String faultCode;
  String materials;
  double aiScore;
  double? masterScore;
  ExecutionAssessment? assessment;
  String aiVerdict;
  String aiExplanation;
  int downtimeMinutes;
  String? brigade;
  double? normHours;
  bool equipmentStopped;

  double get finalScore => masterScore ?? aiScore;
  String get displayNumber => apiNumber ?? '$number';

  final List<OrderEvent> history;

  Duration workDuration(DateTime now) {
    final events = [...history]..sort((a, b) => a.time.compareTo(b.time));
    var total = Duration.zero;
    DateTime? started;
    for (final event in events) {
      if (event.time.isAfter(now)) continue;
      final status =
          event.status ??
          OrderStatus.values
              .where(
                (s) =>
                    event.title == s.label ||
                    event.title.startsWith('${s.label}:'),
              )
              .firstOrNull;
      if (status == null) continue;
      if (status == OrderStatus.working) {
        started ??= event.time;
      } else if (started != null) {
        total += event.time.difference(started);
        started = null;
      }
    }
    if (started != null && status == OrderStatus.working) {
      total += now.difference(started);
    }
    return total;
  }

  bool get emergency => priority == 'Аварийный';

  bool isOverdue(DateTime now) {
    const finished = {
      OrderStatus.closed,
      OrderStatus.cancelled,
      OrderStatus.rejected,
    };
    return !finished.contains(status) && deadline.isBefore(now);
  }

  bool get overdue => isOverdue(DateTime.now());
}

String timeLabel(DateTime date) {
  return '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}

String dateLabel(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.'
      '${date.year}';
}
