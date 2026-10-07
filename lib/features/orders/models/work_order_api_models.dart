// MARK: - Work order status

enum WorkOrderStatus {
  issued,
  queued,
  accepted,
  inProgress,
  paused,
  completed,
  aiReview,
  rework,
  closed,
  rejected,
  cancelled;

  factory WorkOrderStatus.fromApi(String value) {
    return switch (value.toUpperCase()) {
      'ISSUED' => WorkOrderStatus.issued,
      'QUEUED' => WorkOrderStatus.queued,
      'ACCEPTED' => WorkOrderStatus.accepted,
      'IN_PROGRESS' => WorkOrderStatus.inProgress,
      'PAUSED' => WorkOrderStatus.paused,
      'COMPLETED' => WorkOrderStatus.completed,
      'AI_REVIEW' => WorkOrderStatus.aiReview,
      'REWORK' => WorkOrderStatus.rework,
      'CLOSED' => WorkOrderStatus.closed,
      'REJECTED' => WorkOrderStatus.rejected,
      'CANCELLED' => WorkOrderStatus.cancelled,
      _ => throw FormatException('Unknown work order status: $value'),
    };
  }

  String get apiValue => switch (this) {
    WorkOrderStatus.issued => 'ISSUED',
    WorkOrderStatus.queued => 'QUEUED',
    WorkOrderStatus.accepted => 'ACCEPTED',
    WorkOrderStatus.inProgress => 'IN_PROGRESS',
    WorkOrderStatus.paused => 'PAUSED',
    WorkOrderStatus.completed => 'COMPLETED',
    WorkOrderStatus.aiReview => 'AI_REVIEW',
    WorkOrderStatus.rework => 'REWORK',
    WorkOrderStatus.closed => 'CLOSED',
    WorkOrderStatus.rejected => 'REJECTED',
    WorkOrderStatus.cancelled => 'CANCELLED',
  };

  String get label => switch (this) {
    WorkOrderStatus.issued => 'Выдан',
    WorkOrderStatus.queued => 'В очереди',
    WorkOrderStatus.accepted => 'Принят',
    WorkOrderStatus.inProgress => 'В работе',
    WorkOrderStatus.paused => 'Приостановлен',
    WorkOrderStatus.completed => 'Выполнен',
    WorkOrderStatus.aiReview => 'На проверке',
    WorkOrderStatus.rework => 'На доработке',
    WorkOrderStatus.closed => 'Закрыт',
    WorkOrderStatus.rejected => 'Отклонён',
    WorkOrderStatus.cancelled => 'Отменён',
  };

  bool get isFinished =>
      this == WorkOrderStatus.closed ||
      this == WorkOrderStatus.rejected ||
      this == WorkOrderStatus.cancelled;

  bool get isActive =>
      this == WorkOrderStatus.issued ||
      this == WorkOrderStatus.queued ||
      this == WorkOrderStatus.accepted ||
      this == WorkOrderStatus.inProgress ||
      this == WorkOrderStatus.paused ||
      this == WorkOrderStatus.rework;

  bool get canEdit => isActive;

  bool get canReassign =>
      this != WorkOrderStatus.completed &&
      this != WorkOrderStatus.aiReview &&
      this != WorkOrderStatus.closed &&
      this != WorkOrderStatus.cancelled;

  bool get canCancel =>
      this == WorkOrderStatus.issued ||
      this == WorkOrderStatus.accepted ||
      this == WorkOrderStatus.queued ||
      this == WorkOrderStatus.paused;
}

// MARK: - Priority

enum WorkOrderPriority {
  emergency,
  high,
  normal,
  planned;

  factory WorkOrderPriority.fromApi(String value) {
    return switch (value.toUpperCase()) {
      'EMERGENCY' => WorkOrderPriority.emergency,
      'HIGH' => WorkOrderPriority.high,
      'NORMAL' => WorkOrderPriority.normal,
      'PLANNED' => WorkOrderPriority.planned,
      _ => throw FormatException('Unknown work order priority: $value'),
    };
  }

  String get apiValue => switch (this) {
    WorkOrderPriority.emergency => 'EMERGENCY',
    WorkOrderPriority.high => 'HIGH',
    WorkOrderPriority.normal => 'NORMAL',
    WorkOrderPriority.planned => 'PLANNED',
  };

  String get label => switch (this) {
    WorkOrderPriority.emergency => 'Аварийный',
    WorkOrderPriority.high => 'Высокий',
    WorkOrderPriority.normal => 'Обычный',
    WorkOrderPriority.planned => 'Плановый',
  };
}

// MARK: - Type

enum WorkOrderType {
  emergency,
  planned;

  factory WorkOrderType.fromApi(String value) {
    return switch (value.toUpperCase()) {
      'EMERGENCY' => WorkOrderType.emergency,
      'PLANNED' => WorkOrderType.planned,
      _ => throw FormatException('Unknown work order type: $value'),
    };
  }

  String get apiValue => switch (this) {
    WorkOrderType.emergency => 'EMERGENCY',
    WorkOrderType.planned => 'PLANNED',
  };

  String get label => switch (this) {
    WorkOrderType.emergency => 'Аварийный',
    WorkOrderType.planned => 'Плановый',
  };
}

// MARK: - Area

class WorkOrderArea {
  const WorkOrderArea({required this.id, required this.name});

  final int id;
  final String name;

  factory WorkOrderArea.fromJson(Map<String, dynamic> json) {
    return WorkOrderArea(id: _asInt(json['id']), name: _asString(json['name']));
  }
}

// MARK: - Equipment

class WorkOrderEquipment {
  const WorkOrderEquipment({
    required this.id,
    required this.name,
    required this.areaId,
    this.inventoryNumber,
    this.type,
    this.criticality,
    this.qrToken,
  });

  final int id;
  final String name;
  final String? inventoryNumber;
  final String? type;
  final int? criticality;
  final String? qrToken;
  final int areaId;

  factory WorkOrderEquipment.fromJson(Map<String, dynamic> json) {
    return WorkOrderEquipment(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      inventoryNumber: _asNullableString(json['inventoryNumber']),
      type: _asNullableString(json['type']),
      criticality: _asNullableInt(json['criticality']),
      qrToken: _asNullableString(json['qrToken']),
      areaId: _asInt(json['areaId']),
    );
  }
}

// MARK: - Assignee

class WorkOrderAssignee {
  const WorkOrderAssignee({
    required this.id,
    required this.fullName,
    this.specialty,
    this.employeeStatus,
  });

  final int id;
  final String fullName;
  final String? specialty;
  final String? employeeStatus;

  factory WorkOrderAssignee.fromJson(Map<String, dynamic> json) {
    return WorkOrderAssignee(
      id: _asInt(json['id']),
      fullName: _asString(json['fullName']),
      specialty: _asNullableString(json['specialty']),
      employeeStatus: _asNullableString(json['employeeStatus']),
    );
  }
}

// MARK: - Creator

class WorkOrderCreator {
  const WorkOrderCreator({required this.id, required this.fullName});

  final int id;
  final String fullName;

  factory WorkOrderCreator.fromJson(Map<String, dynamic> json) {
    return WorkOrderCreator(
      id: _asInt(json['id']),
      fullName: _asString(json['fullName']),
    );
  }
}

// MARK: - Fault code

class WorkOrderFaultCode {
  const WorkOrderFaultCode({required this.id, this.code, this.name});

  final int id;
  final String? code;
  final String? name;

  factory WorkOrderFaultCode.fromJson(Map<String, dynamic> json) {
    return WorkOrderFaultCode(
      id: _asInt(json['id']),
      code: _asNullableString(json['code']),
      name: _asNullableString(json['name']),
    );
  }
}

// MARK: - Photo

enum WorkOrderPhotoType {
  before,
  after,
  unknown;

  factory WorkOrderPhotoType.fromApi(String? value) {
    return switch (value?.toUpperCase()) {
      'BEFORE' => WorkOrderPhotoType.before,
      'AFTER' => WorkOrderPhotoType.after,
      _ => WorkOrderPhotoType.unknown,
    };
  }

  String? get apiValue => switch (this) {
    WorkOrderPhotoType.before => 'BEFORE',
    WorkOrderPhotoType.after => 'AFTER',
    WorkOrderPhotoType.unknown => null,
  };
}

class WorkOrderPhoto {
  const WorkOrderPhoto({
    required this.id,
    required this.type,
    required this.fileUrl,
    this.capturedAt,
    this.authorId,
  });

  final int id;
  final WorkOrderPhotoType type;
  final String fileUrl;
  final DateTime? capturedAt;
  final int? authorId;

  factory WorkOrderPhoto.fromJson(Map<String, dynamic> json) {
    return WorkOrderPhoto(
      id: _asInt(json['id']),
      type: WorkOrderPhotoType.fromApi(_asNullableString(json['type'])),
      fileUrl: _asString(json['fileUrl']),
      capturedAt: _asNullableDate(json['capturedAt']),
      authorId: _asNullableInt(json['authorId']),
    );
  }
}

// MARK: - Material

class WorkOrderMaterial {
  const WorkOrderMaterial({
    required this.id,
    required this.name,
    required this.unit,
  });

  final int id;
  final String name;
  final String unit;

  factory WorkOrderMaterial.fromJson(Map<String, dynamic> json) {
    return WorkOrderMaterial(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      unit: _asString(json['unit']),
    );
  }
}

class WorkOrderMaterialUsage {
  const WorkOrderMaterialUsage({
    required this.materialId,
    required this.quantity,
    this.material,
  });

  final int materialId;

  /// Backend возвращает quantity строкой, например "1" или "2.5".
  final String quantity;

  final WorkOrderMaterial? material;

  factory WorkOrderMaterialUsage.fromJson(Map<String, dynamic> json) {
    return WorkOrderMaterialUsage(
      materialId: _asInt(json['materialId']),
      quantity: _asString(json['quantity']),
      material: _mapOrNull(json['material'], WorkOrderMaterial.fromJson),
    );
  }

  double? get quantityValue => double.tryParse(quantity);
}

// MARK: - AI assessment

enum AiAssessmentVerdict {
  accepted,
  acceptedWithComments,
  reworkRequired,
  unknown;

  factory AiAssessmentVerdict.fromApi(String? value) {
    return switch (value?.toUpperCase()) {
      'ACCEPTED' => AiAssessmentVerdict.accepted,
      'ACCEPTED_WITH_COMMENTS' => AiAssessmentVerdict.acceptedWithComments,
      'REWORK_REQUIRED' => AiAssessmentVerdict.reworkRequired,
      _ => AiAssessmentVerdict.unknown,
    };
  }

  String get label => switch (this) {
    AiAssessmentVerdict.accepted => 'AI: принято',
    AiAssessmentVerdict.acceptedWithComments => 'AI: принято с замечаниями',
    AiAssessmentVerdict.reworkRequired => 'AI: рекомендует доработку',
    AiAssessmentVerdict.unknown => 'AI: нет заключения',
  };
}

class WorkOrderAiAssessment {
  const WorkOrderAiAssessment({
    required this.verdict,
    this.score,
    this.explanation,
    this.strengths = const [],
    this.improvements = const [],
    this.photoScore,
    this.photoComment,
    this.confidence,
    this.masterScore,
    this.masterComment,
    this.reviewedById,
  });

  final AiAssessmentVerdict verdict;

  final double? score;
  final String? explanation;

  final List<String> strengths;
  final List<String> improvements;

  final double? photoScore;
  final String? photoComment;
  final double? confidence;

  final double? masterScore;
  final String? masterComment;
  final int? reviewedById;

  factory WorkOrderAiAssessment.fromJson(Map<String, dynamic> json) {
    return WorkOrderAiAssessment(
      verdict: AiAssessmentVerdict.fromApi(_asNullableString(json['verdict'])),
      score: _asNullableDouble(json['score']),
      explanation: _asNullableString(json['explanation']),
      strengths: _stringList(json['strengths']),
      improvements: _stringList(json['improvements']),
      photoScore: _asNullableDouble(json['photoScore']),
      photoComment: _asNullableString(json['photoComment']),
      confidence: _asNullableDouble(json['confidence']),
      masterScore: _asNullableDouble(json['masterScore']),
      masterComment: _asNullableString(json['masterComment']),
      reviewedById: _asNullableInt(json['reviewedById']),
    );
  }

  bool get lowConfidence => confidence != null && confidence! < 0.5;

  bool get hasMasterReview => masterScore != null || masterComment != null;
}

// MARK: - Event

enum WorkOrderEventAction {
  create,
  accept,
  queue,
  reject,
  start,
  pause,
  resume,
  complete,
  aiReview,
  sendToRework,
  close,
  cancel,
  edit,
  reassign,
  unknown;

  factory WorkOrderEventAction.fromApi(String? value) {
    return switch (value?.toUpperCase()) {
      'CREATE' => WorkOrderEventAction.create,
      'ACCEPT' => WorkOrderEventAction.accept,
      'QUEUE' => WorkOrderEventAction.queue,
      'REJECT' => WorkOrderEventAction.reject,
      'START' => WorkOrderEventAction.start,
      'PAUSE' => WorkOrderEventAction.pause,
      'RESUME' => WorkOrderEventAction.resume,
      'COMPLETE' => WorkOrderEventAction.complete,
      'AI_REVIEW' => WorkOrderEventAction.aiReview,
      'SEND_TO_REWORK' => WorkOrderEventAction.sendToRework,
      'CLOSE' => WorkOrderEventAction.close,
      'CANCEL' => WorkOrderEventAction.cancel,
      'EDIT' => WorkOrderEventAction.edit,
      'REASSIGN' => WorkOrderEventAction.reassign,
      _ => WorkOrderEventAction.unknown,
    };
  }

  String get label => switch (this) {
    WorkOrderEventAction.create => 'Наряд создан',
    WorkOrderEventAction.accept => 'Наряд принят',
    WorkOrderEventAction.queue => 'Добавлен в очередь',
    WorkOrderEventAction.reject => 'Наряд отклонён',
    WorkOrderEventAction.start => 'Работа начата',
    WorkOrderEventAction.pause => 'Работа приостановлена',
    WorkOrderEventAction.resume => 'Работа продолжена',
    WorkOrderEventAction.complete => 'Работа выполнена',
    WorkOrderEventAction.aiReview => 'AI-проверка',
    WorkOrderEventAction.sendToRework => 'Возвращён на доработку',
    WorkOrderEventAction.close => 'Наряд закрыт',
    WorkOrderEventAction.cancel => 'Наряд отменён',
    WorkOrderEventAction.edit => 'Наряд изменён',
    WorkOrderEventAction.reassign => 'Исполнитель изменён',
    WorkOrderEventAction.unknown => 'Изменение наряда',
  };
}

class WorkOrderEventActor {
  const WorkOrderEventActor({required this.id, required this.fullName});

  final int id;
  final String fullName;

  factory WorkOrderEventActor.fromJson(Map<String, dynamic> json) {
    return WorkOrderEventActor(
      id: _asInt(json['id']),
      fullName: _asString(json['fullName']),
    );
  }
}

class WorkOrderEvent {
  const WorkOrderEvent({
    required this.id,
    required this.action,
    required this.createdAt,
    this.fromStatus,
    this.toStatus,
    this.comment,
    this.actor,
  });

  final int id;
  final WorkOrderEventAction action;

  final WorkOrderStatus? fromStatus;
  final WorkOrderStatus? toStatus;

  final String? comment;
  final DateTime createdAt;
  final WorkOrderEventActor? actor;

  factory WorkOrderEvent.fromJson(Map<String, dynamic> json) {
    return WorkOrderEvent(
      id: _asInt(json['id']),
      action: WorkOrderEventAction.fromApi(_asNullableString(json['action'])),
      fromStatus: _statusOrNull(json['fromStatus']),
      toStatus: _statusOrNull(json['toStatus']),
      comment: _asNullableString(json['comment']),
      createdAt: _asDate(json['createdAt']),
      actor: _mapOrNull(json['actor'], WorkOrderEventActor.fromJson),
    );
  }
}

// MARK: - Work order

class WorkOrderApiModel {
  const WorkOrderApiModel({
    required this.id,
    required this.number,
    required this.type,
    required this.description,
    required this.priority,
    required this.deadline,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.areaId,
    required this.equipmentId,
    required this.creatorId,
    required this.assigneeId,
    required this.area,
    required this.equipment,
    required this.assignee,
    this.comment,
    this.completionText,
    this.pauseReason,
    this.rejectionReason,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.closedAt,
    this.faultCodeId,
    this.normativeId,
    this.actualDowntimeMinutes,
    this.creator,
    this.faultCode,
    this.aiAssessment,
    this.photos = const [],
    this.materialUsages = const [],
    this.events = const [],
  });

  final int id;

  /// Например H-0076 / N-xxxxxxxx.
  final String number;

  final WorkOrderType type;
  final String description;
  final WorkOrderPriority priority;
  final DateTime deadline;
  final WorkOrderStatus status;

  final String? comment;
  final String? completionText;
  final String? pauseReason;
  final String? rejectionReason;

  final DateTime createdAt;
  final DateTime updatedAt;

  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? closedAt;

  final int areaId;
  final int equipmentId;
  final int creatorId;
  final int assigneeId;

  final int? faultCodeId;
  final int? normativeId;
  final int? actualDowntimeMinutes;

  final WorkOrderArea area;
  final WorkOrderEquipment equipment;
  final WorkOrderAssignee assignee;

  final WorkOrderCreator? creator;
  final WorkOrderFaultCode? faultCode;

  final WorkOrderAiAssessment? aiAssessment;

  final List<WorkOrderPhoto> photos;
  final List<WorkOrderMaterialUsage> materialUsages;
  final List<WorkOrderEvent> events;

  factory WorkOrderApiModel.fromJson(Map<String, dynamic> json) {
    return WorkOrderApiModel(
      id: _asInt(json['id']),
      number: _asString(json['number']),
      type: WorkOrderType.fromApi(_asString(json['type'])),
      description: _asString(json['description']),
      priority: WorkOrderPriority.fromApi(_asString(json['priority'])),
      deadline: _asDate(json['deadline']),
      status: WorkOrderStatus.fromApi(_asString(json['status'])),
      comment: _asNullableString(json['comment']),
      completionText: _asNullableString(json['completionText']),
      pauseReason: _asNullableString(json['pauseReason']),
      rejectionReason: _asNullableString(json['rejectionReason']),
      createdAt: _asDate(json['createdAt']),
      updatedAt: _asDate(json['updatedAt']),
      acceptedAt: _asNullableDate(json['acceptedAt']),
      startedAt: _asNullableDate(json['startedAt']),
      completedAt: _asNullableDate(json['completedAt']),
      closedAt: _asNullableDate(json['closedAt']),
      areaId: _asInt(json['areaId']),
      equipmentId: _asInt(json['equipmentId']),
      creatorId: _asInt(json['creatorId']),
      assigneeId: _asInt(json['assigneeId']),
      faultCodeId: _asNullableInt(json['faultCodeId']),
      normativeId: _asNullableInt(json['normativeId']),
      actualDowntimeMinutes: _asNullableInt(json['actualDowntimeMinutes']),
      area: WorkOrderArea.fromJson(_asMap(json['area'])),
      equipment: WorkOrderEquipment.fromJson(_asMap(json['equipment'])),
      assignee: WorkOrderAssignee.fromJson(_asMap(json['assignee'])),
      creator: _mapOrNull(json['creator'], WorkOrderCreator.fromJson),
      faultCode: _mapOrNull(json['faultCode'], WorkOrderFaultCode.fromJson),
      aiAssessment: _mapOrNull(
        json['aiAssessment'],
        WorkOrderAiAssessment.fromJson,
      ),
      photos: _mapList(json['photos'], WorkOrderPhoto.fromJson),
      materialUsages: _mapList(
        json['materialUsages'],
        WorkOrderMaterialUsage.fromJson,
      ),
      events: _mapList(json['events'], WorkOrderEvent.fromJson),
    );
  }

  // MARK: Derived values

  bool get isEmergency =>
      priority == WorkOrderPriority.emergency ||
      type == WorkOrderType.emergency;

  bool get isOverdue {
    if (status == WorkOrderStatus.closed ||
        status == WorkOrderStatus.cancelled ||
        status == WorkOrderStatus.rejected) {
      return false;
    }

    return deadline.isBefore(DateTime.now());
  }

  Duration get overdueBy {
    if (!isOverdue) {
      return Duration.zero;
    }

    return DateTime.now().difference(deadline);
  }

  bool get waitingForMasterReview => status == WorkOrderStatus.aiReview;

  bool get canMasterEdit => status.canEdit;

  bool get canMasterReassign => status.canReassign;

  bool get canMasterCancel => status.canCancel;

  List<WorkOrderPhoto> get beforePhotos => photos
      .where((photo) => photo.type == WorkOrderPhotoType.before)
      .toList(growable: false);

  List<WorkOrderPhoto> get afterPhotos => photos
      .where((photo) => photo.type == WorkOrderPhotoType.after)
      .toList(growable: false);
}

// MARK: - JSON helpers

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  throw FormatException('Expected JSON object, got ${value.runtimeType}');
}

T? _mapOrNull<T>(dynamic value, T Function(Map<String, dynamic>) parser) {
  if (value == null) {
    return null;
  }

  return parser(_asMap(value));
}

List<T> _mapList<T>(dynamic value, T Function(Map<String, dynamic>) parser) {
  if (value == null) {
    return const [];
  }

  if (value is! List) {
    throw FormatException('Expected JSON list, got ${value.runtimeType}');
  }

  return value.map((item) => parser(_asMap(item))).toList(growable: false);
}

List<String> _stringList(dynamic value) {
  if (value == null) {
    return const [];
  }

  if (value is! List) {
    return const [];
  }

  return value
      .where((item) => item != null)
      .map((item) => item.toString())
      .toList(growable: false);
}

String _asString(dynamic value) {
  if (value == null) {
    throw const FormatException('Expected non-null String value');
  }

  return value.toString();
}

String? _asNullableString(dynamic value) {
  if (value == null) {
    return null;
  }

  return value.toString();
}

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  final parsed = int.tryParse(value?.toString() ?? '');

  if (parsed != null) {
    return parsed;
  }

  throw FormatException('Expected int value, got $value');
}

int? _asNullableInt(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value.toString());
}

double? _asNullableDouble(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is double) {
    return value;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value.toString());
}

DateTime _asDate(dynamic value) {
  if (value is DateTime) {
    return value;
  }

  final parsed = DateTime.tryParse(value?.toString() ?? '');

  if (parsed == null) {
    throw FormatException('Invalid DateTime value: $value');
  }

  return parsed;
}

DateTime? _asNullableDate(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is DateTime) {
    return value;
  }

  return DateTime.tryParse(value.toString());
}

WorkOrderStatus? _statusOrNull(dynamic value) {
  if (value == null) {
    return null;
  }

  return WorkOrderStatus.fromApi(value.toString());
}
